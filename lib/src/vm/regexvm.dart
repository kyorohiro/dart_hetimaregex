part of hetimaregex;

class RegexVM {
  List<RegexCommand> _commands = [];
  List<RegexTask> _tasks = [];

  RegexVM.createFromCommand(List<RegexCommand> command) {
    _commands = new List.from(command);
  }

  void addCommand(RegexCommand command) {
    _commands.add(command);
  }

  void insertTask(int index, RegexTask task) {
    _tasks.insert(index, task);
  }

  void addTask(RegexTask task, [bool isFirst = false]) {
    if (isFirst && _tasks.length > 0) {
      _tasks.insert(0, task);
    } else {
      _tasks.add(task);
    }
  }

  bool get haveCurrentTask {
    if (_tasks.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  RegexTask get currentTask {
    if (haveCurrentTask) {
      return _tasks[0];
    } else {
      throw new Exception("");
    }
  }

  RegexTask eraseCurrentTask() {
    if (haveCurrentTask) {
      RegexTask prevTask = _tasks[0];
      _tasks.removeAt(0);
      return prevTask;
    } else {
      throw new Exception("");
    }
  }

  async.Future<List<List<int>>> match(List<int> text) {
    async.Completer completer = new async.Completer();
    heti.EasyParser parser = new heti.EasyParser(new heti.ArrayBuilder.fromList(text, true));
    _tasks.add(new RegexTask.fromCommnadPos(0, parser));

    loop() {
      if (!haveCurrentTask) {
        completer.completeError(new Exception());
      }
      currentTask.match(this).then((List<List<int>> v) {
        completer.complete(v);
      }).catchError((e) {
        eraseCurrentTask();
        loop();
      });
    }
    loop();
    return completer.future;
  }
}
