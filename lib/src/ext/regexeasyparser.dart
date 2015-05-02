part of hetimaregex;

class RegexEasyParser extends heti.EasyParser {
  RegexEasyParser(heti.HetimaBuilder builder) : super(builder) {}

  async.Future<List<List<int>>> readFromCommand(List<RegexCommand> command) {
    RegexVM vm = new RegexVM.createFromCommand([]);
    return vm.lookingAtFromEasyParser(this);
  }
}

