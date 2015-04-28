part of hetimaregex;


class RegexGroup {
  List<List<Object>> commandList = [[]];
  List<Object> get command => commandList[commandList.length - 1];
  bool isRoot = false;
  List<RegexCommand> serialize() {
    List<RegexCommand> ret = [];
    List<List<RegexCommand>> tmp = [];
    for (int i = 0; i < commandList.length; i++) {
      tmp.add(serializePart(i));
    }

    if (!isRoot) {
      ret.add(new MemoryStartCommand());
    }
    if (commandList.length == 1) {
      ret.addAll(tmp[0]);
    } else {
      int commandLength = (tmp.length - 1) * 2 + 1;
      for (int i = 0; i < tmp.length; i++) {
        commandLength += tmp[i].length;
      }

      int currentLength = 0;
      for (int i = 0; i < tmp.length; i++) {
        if (i < (tmp.length - 1)) {
          ret.add(new SplitTaskCommand.create(1, tmp[i].length + 2));
          currentLength += 1;
          ret.addAll(tmp[i]);
          currentLength += tmp[i].length;
          ret.add(new JumpTaskCommand.create(commandLength - currentLength));
          currentLength += 1;
        } else {
          ret.add(new SplitTaskCommand.create(1, tmp[i].length + 1));
          currentLength += 1;
          ret.addAll(tmp[i]);
          currentLength += tmp[i].length;
        }
      }
    }
    if (!isRoot) {
      ret.add(new MemoryStopCommand());
    }
    return ret;
  }
  List<RegexCommand> serializePart(int index) {
    List<RegexCommand> ret = [];
    List<Object> stack = [];
    stack.insertAll(0, commandList[index]);
    while (stack.length > 0) {
      Object current = stack.removeAt(0);
      if (current is RegexGroup) {
        stack.insertAll(0, (current as RegexGroup).serialize());
      } else {
        ret.add(current);
      }
    }
    return ret;
  }
}
