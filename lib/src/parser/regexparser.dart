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

class SignS extends Command {
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
class SignE extends Command {
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
class RegexParser {
  async.Future<RegexVM> compile(String source) {
    async.Completer<RegexVM> completer = new async.Completer();
    RegexLexer lexer = new RegexLexer();

    lexer.scan(conv.UTF8.encode(source)).then((List<RegexToken> tokens) {
      List<Command> ret = [];
      List<SignS> stackMemoryStartStop = [];
      List<Command> cashMemoryStartStop = [];
      int id = 0;

      for (RegexToken t in tokens) {
        switch (t.kind) {
          case RegexToken.character:
            ret.add(new CharCommand.createFromList([t.value]));
            break;
          case RegexToken.lparan:
            {
              SignS s = new SignS(id++);
              ret.add(s);
              stackMemoryStartStop.add(s);
              cashMemoryStartStop.add(s);
            }
            ret.add(new MemoryStartCommand());
            break;
          case RegexToken.rparen:
            ret.add(new MemoryStopCommand());
            {
              SignE e = new SignE(stackMemoryStartStop.last);
              ret.add(e);
              cashMemoryStartStop.add(e);
              stackMemoryStartStop.removeLast();
            }
            break;
          case RegexToken.star:
            if (ret.last is SignE) {
              int a1 = ret.length-cashMemoryStartStop.length;
              int index = ret.indexOf((ret.last as SignE).s);
              ret.insert(index, new SplitTaskCommand.create(1, a1 - index+2));
              ret.add(new JumpTaskCommand.create(-1 * (a1 - index+1)));
            } else {
              ret.insert(ret.length - 1, new SplitTaskCommand.create(1, 3));
              ret.add(new JumpTaskCommand.create(-2));
            }
            break;
          case RegexToken.union:
            if (stackMemoryStartStop.length == 0) {
              int a1 = ret.length;
              ret.insert(0, new SplitTaskCommand.create(1, a1));
            } else {
              int a1 = ret.length;
              int index = ret.indexOf((ret.last as SignE).s);
              ret.insert(index, new SplitTaskCommand.create(1, a1 - index));
            }
            break;
        }
      }

      ret.add(new MatchCommand());
      for (Command c in cashMemoryStartStop) {
        ret.remove(c);
      }
      print("--");
      for (Command c in ret) {
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
