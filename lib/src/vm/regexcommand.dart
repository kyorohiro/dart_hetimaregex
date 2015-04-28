part of hetimaregex;

abstract class Command {
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser);
}

class MemoryStartCommand extends Command {
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    RegexTask currentTask = vm.getCurrentTask();
    int index = currentTask._nextMemoryId;
    currentTask._nextMemoryId++;
    currentTask._memory.add([]);
    currentTask._memoryWritable.add(index);
    currentTask._commandPos++;
    c.complete([]);
    return c.future;
  }

  String toString() {
    return "<memory start>";
  }
}

class MemoryStopCommand extends Command {
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    RegexTask currentTask = vm.getCurrentTask();
    currentTask._memoryWritable.removeLast();
    currentTask._commandPos++;
    c.complete([]);
    return c.future;
  }

  String toString() {
    return "<memory stop>";
  }

}


class MatchCommandNotification extends Error {
  MatchCommandNotification(dynamic mes) {}
}

class MatchCommand extends Command {
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    c.completeError(new MatchCommandNotification(""));
    return c.future;
  }
  String toString() {
    return "<match>";
  }
}

class JumpTaskCommand extends Command {
  static final int LM1 = -1;
  static final int L0 = 0;
  static final int L1 = 1;
  static final int L2 = 2;
  static final int L3 = 3;
  int _pos1 = 0;

  JumpTaskCommand.create(int pos1) {
    _pos1 = pos1;
  }

  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    RegexTask currentTask = vm.getCurrentTask();
    if (currentTask == null) {
      throw new Exception("");
    }

    int currentPos = currentTask._commandPos;
    currentTask._commandPos = currentPos + _pos1;
    c.complete([]);
    return c.future;
  }
  
  String toString() {
    return "<jump ${_pos1}>";
  }
}

class SplitTaskCommand extends Command {
  static final int LM1 = -1;
  static final int L0 = 0;
  static final int L1 = 1;
  static final int L2 = 2;
  static final int L3 = 3;
  int _pos1 = 0;
  int _pos2 = 0;

  SplitTaskCommand.create(int pos1, int pos2) {
    _pos1 = pos1;
    _pos2 = pos2;
  }

  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    RegexTask currentTask = vm.getCurrentTask();
    if (currentTask == null) {
      throw new Exception("");
    }

    int currentPos = currentTask._commandPos;
    currentTask._commandPos = currentPos + _pos1;
//  vm.addTask(new RegexTask.fromCommnadPos(currentPos + _pos2, parser));
  vm.addTask(new RegexTask.clone(currentTask, currentPos + _pos2));

    c.complete([]);
    return c.future;
  }

  String toString() {
    return "<split ${_pos1} ${_pos2}>";
  }
}

class CharCommand extends Command {
  List<int> _expect = [];
  CharCommand.createFromList(List<int> v) {
    _expect = new List.from(v);
  }

  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    int length = _expect.length;
    parser.push();
    parser.nextBuffer(length).then((List<int> v) {
      if (v.length != length) {
        parser.back();
        parser.pop();
        c.completeError(new Exception(""));
        return;
      }
      for (int i = 0; i < length; i++) {
        if (_expect[i] != v[i]) {
          parser.back();
          parser.pop();
          c.completeError(new Exception(""));
          return;
        }
      }
      parser.pop();
      RegexTask t = vm.getCurrentTask();
      t._commandPos++;
      c.complete(v);
    });
    return c.future;
  }

  String toString() {
    return "<char ${_expect}>";
  }
}
