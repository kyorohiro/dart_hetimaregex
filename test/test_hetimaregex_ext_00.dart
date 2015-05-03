library dart_hetimaparser_test_ext;

import 'package:hetimaregex/hetimaregex.dart' as regex;
import 'package:unittest/unittest.dart';

import 'dart:convert' as conv;

void main() => script00();

void script00() {
  group('parser00', () {
    test('char true a', () {
      regex.GroupPattern root = new regex.GroupPattern(isSaveInMemory: false);
      regex.CharacterPattern commentS = new regex.CharacterPattern.fromBytes(conv.UTF8.encode("[["));
      regex.CharacterPattern commentE = new regex.CharacterPattern.fromBytes(conv.UTF8.encode("]]"));
      regex.GroupPattern comment = new regex.GroupPattern(isSaveInMemory: true);

      root.addRegexNode(commentS);
      root.addRegexNode(comment);
      comment.addRegexNode(new regex.StarPattern.fromCommand(new regex.AllCharCommand()));
      root.addRegexNode(commentE);
      root.addRegexCommand(new regex.MatchCommand());
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(root.convertRegexCommands());
      print(vm.toString());
      return vm.lookingAt(conv.UTF8.encode("[[aabb]]")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"aabb");
      }).catchError((e) {
        expect(true, false);
      });
    });
  });
}

//commentLong()
