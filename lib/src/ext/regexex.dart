part of hetimaregex;

class AllCharCommand extends RegexCommand {
  
  @override
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    parser.readByte().then((int v) {
      vm._currentTask._nextCommandLocation += 1;
      c.complete([v]);      
    }).catchError((e){
      c.completeError(e);
    });
    return c.future;
  }
  String toString() {
    return "<all char>";
  }
}

class RegexBuilder {
  GroupPattern root = new GroupPattern(isSaveInMemory: false);
  List<GroupPattern> stack = [];
  RegexBuilder() {
    stack.add(root);
  }
  

  RegexBuilder addRegexLeaf(RegexLeaf leaf) {
    stack.last.addRegexNode(leaf);
    return this;
  }
  
  RegexBuilder addRegexCommand(RegexCommand comm) {
    stack.last.addRegexCommand(comm);
    return this;
  }
  
  RegexBuilder push(bool isSaveInMemory) {
    GroupPattern p = new GroupPattern(isSaveInMemory: isSaveInMemory);
    stack.last.addRegexNode(p);
    stack.add(p);
    return this;
  }

  RegexBuilder pop() {
    stack.removeLast();
    return this;
  }
  
  List<RegexCommand> done() {
    List<RegexCommand> ret = root.convertRegexCommands();
    ret.add(new MatchCommand());
    return ret;
  }
}