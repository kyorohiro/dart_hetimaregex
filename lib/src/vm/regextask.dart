part of hetimaregex;

class RegexTask {
  int _commandPos = 0;
  heti.EasyParser _parser = null;
  int get commandPos => _commandPos;

  List<List<int>> _memory = [];
  List<int> _memoryWritable = [];
  int _nextMemoryId = 0;

  RegexTask.clone(RegexTask tasl, [int commandPos = -1]) {
    if (commandPos != -1) {
      this._commandPos = commandPos;
    } else {
      this._commandPos = tasl._commandPos;
    }
    this._parser = tasl._parser.toClone();
    this._memory = new List.from(tasl._memory);
    this._memoryWritable = new List.from(tasl._memoryWritable);
    this._nextMemoryId = tasl._nextMemoryId;
  }

  RegexTask.fromCommnadPos(int commandPos, heti.EasyParser parser) {
    _commandPos = commandPos;
    _parser = parser.toClone();
  }

  void tryAddMemory(List<int> v) {
    if (_memoryWritable.length > 0) {
      for (int i in _memoryWritable) {
        _memory[i].addAll(v);
      }
    }
  }

  async.Future<List<int>> executeNextCommand(RegexVM vm) {
    async.Completer<List<int>> completer = new async.Completer();
    if (_commandPos >= vm._commands.length) {
      completer.completeError(new Exception(""));
      return completer.future;
    }
    RegexCommand c = vm._commands[_commandPos];
    c.check(vm, _parser).then((List<int> v) {
      completer.complete(v);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<List<List<int>>> lookingAt(RegexVM vm) {
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
