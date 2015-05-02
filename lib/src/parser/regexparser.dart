part of hetimaregex;


class RegexParser {
  async.Future<RegexVM> compile(String source) {
    async.Completer<RegexVM> completer = new async.Completer();
    RegexLexer lexer = new RegexLexer();

    lexer.scan(conv.UTF8.encode(source)).then((List<RegexToken> tokens) {
      GroupPattern root = new GroupPattern(isSaveInMemory:false);
      List<GroupPattern> stack = [root];

      for (RegexToken t in tokens) {
        switch (t.kind) {
          case RegexToken.character:
            stack.last.elements.add(new CharacterPattern.fromBytes([t.value]));
            break;
          case RegexToken.lparan:
            RegexNode l = new GroupPattern(isSaveInMemory:true);
            stack.last.elements.add(l);
            stack.add(l);
            break;
          case RegexToken.rparen:
            stack.removeLast();
            break;
          case RegexToken.star:
            stack.last.elements.add(new StarPattern.fromPattern(stack.last.elements.removeLast()));
            break;
          case RegexToken.union:
            stack.last.elementsList.add([]);
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
