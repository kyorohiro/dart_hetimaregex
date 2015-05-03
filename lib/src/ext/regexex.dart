part of hetimaregex;

class AllCharCommand extends RegexCommand {
  
  @override
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    parser.readByte().then((int v) {
      c.complete([v]);      
    }).catchError((e){
      c.completeError(e);
    });
    return c.future;
  }
}