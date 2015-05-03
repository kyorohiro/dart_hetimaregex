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

a() {
  GroupPattern root = new GroupPattern(isSaveInMemory:false);
  CharacterPattern commentS = new CharacterPattern.fromBytes(conv.UTF8.encode("[["));
  CharacterPattern commentE = new CharacterPattern.fromBytes(conv.UTF8.encode("]]"));
  GroupPattern comment = new GroupPattern(isSaveInMemory:false);
  
  root.addRegexNode(commentS);
  root.addRegexNode(comment);
  comment.addRegexNode(new StarPattern.fromCommand(new AllCharCommand()));
  root.addRegexNode(commentE);
}