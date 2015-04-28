part of hetimaregex;


class RegexParser {
  async.Future<RegexVM> compile(String source) {
    async.Completer<RegexVM> completer = new async.Completer();
    RegexLexer lexer = new RegexLexer();

    lexer.scan(conv.UTF8.encode(source)).then((List<RegexToken> tokens) {
      RegexGroup root = new RegexGroup();
      root.isRoot = true;
      List<RegexGroup> stack = [root];

      for (RegexToken t in tokens) {
        switch (t.kind) {
          case RegexToken.character:
            stack.last.elements.add(new CharCommand.createFromList([t.value]));
            break;
          case RegexToken.lparan:
            RegexGroup l = new RegexGroup();
            stack.last.elements.add(l);
            stack.add(l);
            break;
          case RegexToken.rparen:
            stack.removeLast();
            break;
          case RegexToken.star:
            if (stack.last.elements.last is RegexGroup) {
              RegexGroup p = stack.last.elements.last;
              stack.last.elements.insert(stack.last.elements.length - 1, new SplitTaskCommand.create(1, p.convertRegexCommands().length + 2));
              stack.last.elements.add(new JumpTaskCommand.create(-1 * (p.convertRegexCommands().length + 1)));
            } else {
              stack.last.elements.insert(stack.last.elements.length - 1, new SplitTaskCommand.create(1, 3));
              stack.last.elements.add(new JumpTaskCommand.create(-2));
            }
            break;
          case RegexToken.union:
            //
            // '|'は次のパターン決まるまで確定しないので、コマンドの生成は後回し。
            stack.last.elementsPerOrgroup.add([]);
            break;
        }
      }
      List<RegexCommand> ret = [];
      ret.addAll(root.convertRegexCommands());
      ret.add(new MatchCommand());
      RegexVM vm = new RegexVM.createFromCommand(ret);

      completer.complete(vm);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}
