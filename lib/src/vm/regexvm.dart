part of hetimaregex;

class RegexVM {
  List<Command> _commands = [];
  List<RegexTask> _tasks = [];

  RegexVM.createFromCommand(List<Command> command) {
    _commands = new List.from(command);
  }

  void addCommand(Command command) {
    _commands.add(command);
  }

  void insertTask(int index, RegexTask task) {
    _tasks.insert(index, task);
  }

  void addTask(RegexTask task,[bool isFirst=false]) {
    if(isFirst && _tasks.length > 0) {
      _tasks.insert(0, task);
    } else {
      _tasks.add(task);
    }
  }

  RegexTask getCurrentTask() {
    if (_tasks.length > 0) {
      return _tasks[0];
    } else {
      return null;
    }
  }

  RegexTask popCurrentTask() {
    if (_tasks.length > 0) {
      RegexTask t = _tasks[0];
      _tasks.removeAt(0);
      return t;
    } else {
      return null;
    }
  }

  async.Future<List<List<int>>> match(List<int> text) {
    async.Completer completer = new async.Completer();
    heti.EasyParser parser = new heti.EasyParser(new heti.ArrayBuilder.fromList(text, true));
    _tasks.add(new RegexTask.fromCommnadPos(0, parser));

    loop() {
      RegexTask task = getCurrentTask();
      if (task == null) {
        completer.completeError(new Exception());
        return;
      }
      task.match(this).then((List<List<int>> v) {
        completer.complete(v);
      }).catchError((e) {
        popCurrentTask();
        loop();
      });
    }
    loop();
    return completer.future;
  }
}
