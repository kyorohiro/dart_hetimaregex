part of hetimaregex;

class RegexTask {
  int _commandPos = 0;
  heti.EasyParser _parser = null;
  int get commandPos => _commandPos;

  List<List<int>> _memory = [];
  List<int> _memoryWritable = [];
  int _nextMemoryId = 0;

  RegexTask.fromCommnadPos(int commandPos, heti.EasyParser parser) {
    _commandPos = commandPos;
    _parser = parser.toClone();
  }

  void tryAddMemory(List<int> v) {
    if(_memoryWritable.length > 0) {
      _memory[_memoryWritable.last].addAll(v);
    }
  }
  
  async.Future<List<int>> executeNextCommand(RegexVM vm) {
    async.Completer<List<int>> completer = new async.Completer();
    if (_commandPos >= vm._commands.length) {
      completer.completeError(new Exception(""));
      return completer.future;
    }
    Command c = vm._commands[_commandPos];
    c.check(vm, _parser).then((List<int> v) {
        completer.complete(v);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<List<List<int>>> match(RegexVM vm) {
    async.Completer<List<List<int>>> completer = new async.Completer();
    loop() {
      return executeNextCommand(vm).then((List<int> v) {
        tryAddMemory(v);
        return loop();
      }).catchError((e) {
        if (e is MatchCommandNotification) {
          completer.complete(_memory);
        } else {
          completer.completeError(e);
        }
      });
    }
    loop();
    return completer.future;
  }
}
