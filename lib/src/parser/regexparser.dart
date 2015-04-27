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

class RegexParser {
  async.Future<RegexVM> compile(String source) {
    RegexVM vm = new RegexVM.createFromCommand([]);

    async.Completer<RegexVM> completer = new async.Completer();
    RegexLexer lexer = new RegexLexer();
    lexer.scan(conv.UTF8.encode(source)).then((List<RegexToken> tokens){
      for(RegexToken t in tokens) {
        switch(t.kind) {
          case RegexToken.character:
            vm.addCommand(new CharCommand.createFromList([t.value]));
            break;
          case RegexToken.lparan:
            vm.addCommand(new MemoryStartCommand());
            break;
          case RegexToken.rparen:
            vm.addCommand(new MemoryStopCommand());
            break;
        }
      }
      vm.addCommand(new MatchCommand());
      completer.complete(vm);
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }
}

