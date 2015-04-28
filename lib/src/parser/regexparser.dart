part of hetimaregex;

class RegexToken {
  static const int none = 0;
  static const int character = 1;
  static const int star = 2;
  static const int union = 3;
  static const int lparan = 4;
  static const int rparen = 5;
  static const int eof = 6;

  int value = none;
  int kind = none;
  RegexToken.fromChar(int value, int kind) {
    this.value = value;
    this.kind = kind;
  }
}

class SignS extends RegexCommand {
  int id = 0;
  SignS(int id) {
    this.id = id;
  }
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer c = new async.Completer();
    c.complete([]);
    return c.future;
  }
}

class SignE extends RegexCommand {
  SignS s = null;
  SignE(SignS s) {
    this.s = s;
  }

  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer c = new async.Completer();
    c.complete([]);
    return c.future;
  }
}

class Pat {
  List<List<Object>> commandList = [[]];
  List<Object> get command => commandList[commandList.length - 1];
  bool isRoot = false;
  List<RegexCommand> serialize() {
    List<RegexCommand> ret = [];
    List<List<RegexCommand>> tmp = [];
    for (int i = 0; i < commandList.length; i++) {
      tmp.add(serializePart(i));
    }

    if (!isRoot) {
      ret.add(new MemoryStartCommand());
    }
    if (commandList.length == 1) {
      ret.addAll(tmp[0]);
    } else {
      int commandLength = (tmp.length - 1) * 2 + 1;
      for (int i = 0; i < tmp.length; i++) {
        commandLength += tmp[i].length;
      }

      int currentLength = 0;
      for (int i = 0; i < tmp.length; i++) {
        if (i < (tmp.length - 1)) {
          ret.add(new SplitTaskCommand.create(1, tmp[i].length + 2));
          currentLength += 1;
          ret.addAll(tmp[i]);
          currentLength += tmp[i].length;
          ret.add(new JumpTaskCommand.create(commandLength - currentLength));
          currentLength += 1;
        } else {
          ret.add(new SplitTaskCommand.create(1, tmp[i].length + 1));
          currentLength += 1;
          ret.addAll(tmp[i]);
          currentLength += tmp[i].length;
        }
      }
    }
    if (!isRoot) {
      ret.add(new MemoryStopCommand());
    }
    return ret;
  }
  List<RegexCommand> serializePart(int index) {
    List<RegexCommand> ret = [];
    List<Object> stack = [];
    stack.insertAll(0, commandList[index]);
    while (stack.length > 0) {
      Object current = stack.removeAt(0);
      if (current is Pat) {
        stack.insertAll(0, (current as Pat).serialize());
      } else {
        ret.add(current);
      }
    }
    return ret;
  }
}

class RegexParser {
  async.Future<RegexVM> compile2(String source) {
    async.Completer<RegexVM> completer = new async.Completer();
    RegexLexer lexer = new RegexLexer();

    lexer.scan(conv.UTF8.encode(source)).then((List<RegexToken> tokens) {
      Pat root = new Pat();
      root.isRoot = true;
      List<Pat> stack = [root];

      for (RegexToken t in tokens) {
        switch (t.kind) {
          case RegexToken.character:
            stack.last.command.add(new CharCommand.createFromList([t.value]));
            break;
          case RegexToken.lparan:
            Pat l = new Pat();
            stack.last.command.add(l);
            stack.add(l);
            break;
          case RegexToken.rparen:
            stack.removeLast();
            break;
          case RegexToken.star:
            if (stack.last.command.last is Pat) {
              Pat p = stack.last.command.last;
              stack.last.command.insert(stack.last.command.length - 1, new SplitTaskCommand.create(1, p.serialize().length + 2));
              stack.last.command.add(new JumpTaskCommand.create(-1 * (p.serialize().length + 1)));
            } else {
              stack.last.command.insert(stack.last.command.length - 1, new SplitTaskCommand.create(1, 3));
              stack.last.command.add(new JumpTaskCommand.create(-2));
            }
            break;
          case RegexToken.union:
            //
            // '|'は次のパターン決まるまで確定しないので、後でコンパイルする。
            stack.last.commandList.add([]);
            break;
        }
      }
      List<RegexCommand> ret = [];
      ret.addAll(root.serialize());
      ret.add(new MatchCommand());
      print("--");
      for (RegexCommand c in ret) {
        print("${c.toString()}");
      }
      RegexVM vm = new RegexVM.createFromCommand(ret);

      completer.complete(vm);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}
