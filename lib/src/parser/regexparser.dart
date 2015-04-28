part of hetimaregex;


class RegexParser {
  async.Future<RegexVM> compile2(String source) {
    async.Completer<RegexVM> completer = new async.Completer();
    RegexLexer lexer = new RegexLexer();

    lexer.scan(conv.UTF8.encode(source)).then((List<RegexToken> tokens) {
      RegexGroup root = new RegexGroup();
      root.isRoot = true;
      List<RegexGroup> stack = [root];

      for (RegexToken t in tokens) {
        switch (t.kind) {
          case RegexToken.character:
            stack.last.command.add(new CharCommand.createFromList([t.value]));
            break;
          case RegexToken.lparan:
            RegexGroup l = new RegexGroup();
            stack.last.command.add(l);
            stack.add(l);
            break;
          case RegexToken.rparen:
            stack.removeLast();
            break;
          case RegexToken.star:
            if (stack.last.command.last is RegexGroup) {
              RegexGroup p = stack.last.command.last;
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
