part of hetimaregex;

class RegexToken {
  static final int none = 0;
  static final int character = 1;
  static final int star = 2;
  static final int union = 3;
  static final int lparan = 4;
  static final int rparen = 5;
  static final int eof = 6;

  int value = none;
  int kind = none;
  RegexToken.fromChar(int value, int kind) {
    this.value = value;
    this.kind = kind;
  }
}

class RegexParser {
  async.Future<RegexVM> compile(String source) {
    RegexLexer lexer = new RegexLexer();
    lexer.scan(conv.UTF8.encode(source));
  }
  
}

class RegexLexer {
  //
  //
  //
  //
  async.Future<List<RegexToken>> scan(List<int> text) {
    async.Completer completer = new async.Completer();
    heti.EasyParser parser =
        new heti.EasyParser(new heti.ArrayBuilder.fromList(text, true));

    List<RegexToken> tokens = [];
    a() {
      parser.readByte().then((int v) {
        switch (v) {
          case 0x2a: // *
            tokens.add(new RegexToken.fromChar(v, RegexToken.star));
            break;
          case 0x5c: // \
            parser.readByte().then((int v) {
              tokens.add(new RegexToken.fromChar(v, RegexToken.character));
              a();
            });
            return;
          case 0x28: // (
            tokens.add(new RegexToken.fromChar(v, RegexToken.lparan));
            break;
          case 0x29: // )
            tokens.add(new RegexToken.fromChar(v, RegexToken.rparen));
            break;
          case 0x7c: // |
            tokens.add(new RegexToken.fromChar(v, RegexToken.union));
            break;
          default:
            tokens.add(new RegexToken.fromChar(v, RegexToken.character));
            break;
        }
        a();
      }).catchError((e) {
        completer.complete(tokens);
      });
    }
    a();
    return completer.future;
  }
}
