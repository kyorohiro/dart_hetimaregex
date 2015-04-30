part of hetimaregex;

class GroupPattern extends RegexNode {
  List<GroupPattern> elementsPerOrgroup = [];
  bool dontMemory = false;

  GroupPattern({isRoot: false, List<Object> elements: null}) {
    this.dontMemory = isRoot;
    if (elements == null) {
      this.elements = [];
    } else {
      this.elements = new List.from(elements);
    }
  }

  List<RegexCommand> convertRegexCommands() {
    List<RegexCommand> ret = [];
    List<List<RegexCommand>> commandPerOrgroup = [];

    for (GroupPattern p in elementsPerOrgroup) {
      commandPerOrgroup.add(p.convertRegexCommands());
    }
    {
      List<RegexCommand> t = [];
      for (RegexNode n in elements) {
        t.addAll(n.convertRegexCommands());
      }
      commandPerOrgroup.add(t);
    }

    if (!dontMemory) {
      ret.add(new MemoryStartCommand());
    }

    ret.addAll(_combineRegexCommand(commandPerOrgroup));

    if (!dontMemory) {
      ret.add(new MemoryStopCommand());
    }
    return ret;
  }

  List<RegexCommand> _combineRegexCommand(List<List<RegexCommand>> tmp) {
    List<RegexCommand> ret = [];

    if (tmp.length == 1) {
      ret.addAll(tmp[0]);
      return ret;
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
}

abstract class RegexNode {
  List<Object> elements = [];
  List<RegexCommand> convertRegexCommands();
}

class CharacterPattern extends RegexNode {
  List<int> _characters = [];
  CharacterPattern.fromBytes(List<int> v) {
    _characters.addAll(v);
  }
  List<RegexCommand> convertRegexCommands() {
    return [new CharCommand.createFromList(_characters)];
  }
}

class StarPattern extends RegexNode {
  RegexNode e1 = null;

  StarPattern.fromPattern(RegexNode e1) {
    this.e1 = e1;
  }

  List<RegexCommand> convertRegexCommands() {
    List<RegexCommand> e1List = e1.convertRegexCommands();

    List<RegexCommand> ret = [];
    ret.add(new SplitTaskCommand.create(1, (e1List.length) + 2));
    ret.addAll(e1List);
    ret.add(new JumpTaskCommand.create(-1 * (e1List.length) - 1));
    return ret;
  }
}
