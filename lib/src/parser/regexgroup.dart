part of hetimaregex;


class GroupPattern extends RegexGroup {

  List<List<Object>> elementsPerOrgroup = [[]];
  List<Object> get elements => elementsPerOrgroup[elementsPerOrgroup.length - 1];
  bool isRoot = false;

  List<RegexCommand> convertRegexCommands() {
    List<RegexCommand> ret = [];
    List<List<RegexCommand>> commandPerOrgroup = [];

    for (int i = 0; i < elementsPerOrgroup.length; i++) {
      commandPerOrgroup.add(_toRegexCommandPerGroup(i));
    }

    if (!isRoot) {
      ret.add(new MemoryStartCommand());
    }

    ret.addAll(_combineRegexCommand(commandPerOrgroup));

    if (!isRoot) {
      ret.add(new MemoryStopCommand());
    }
    return ret;
  }

  List<RegexCommand> _combineRegexCommand(List<List<RegexCommand>> tmp) {
    List<RegexCommand> ret = [];

    if (elementsPerOrgroup.length == 1) {
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
    return ret;
  }
  List<RegexCommand> _toRegexCommandPerGroup(int index) {
    List<RegexCommand> ret = [];
    List<Object> stack = [];
    stack.insertAll(0, elementsPerOrgroup[index]);
    while (stack.length > 0) {
      Object current = stack.removeAt(0);
      if (current is RegexGroup) {
        stack.insertAll(0, (current as RegexGroup).convertRegexCommands());
      } else {
        ret.add(current);
      }
    }
    return ret;
  }
}

abstract class RegexGroup {
  List<List<Object>> elementsPerOrgroup = [[]];
  List<Object> get elements => elementsPerOrgroup[elementsPerOrgroup.length - 1];
  bool isRoot = false;
  List<RegexCommand> convertRegexCommands();
}

class CharacterPattern extends RegexGroup {
  List<int> _characters = [];
  CharacterPattern.fromBytes(List<int> v) {
    _characters.addAll(v);
  }
  List<RegexCommand> convertRegexCommands() {
    return [new CharCommand.createFromList(_characters)];
  }
}

class StarPattern extends RegexGroup {
  RegexGroup e1 = null;

  StarPattern.fromPattern(RegexGroup e1) {
    this.e1 = e1;
  }

  List<RegexCommand> convertRegexCommands() {
    List<RegexCommand> e1List = e1.convertRegexCommands();

    List<RegexCommand> ret = [];
    ret.add(new SplitTaskCommand.create(1, (e1List.length)+2));
    ret.addAll(e1List);
    ret.add(new JumpTaskCommand.create(-1*(e1List.length)-1));
    return ret;
  }
}
