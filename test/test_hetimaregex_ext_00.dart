library dart_hetimaparser_test_ext;

import 'package:hetimaregex/hetimaregex.dart' as regex;
import 'package:unittest/unittest.dart';

import 'dart:convert' as conv;

void main() => script00();


void script00() {
  group('parser00', () {
    test('char true a', () {
      regex.RegexBuilder builder = new regex.RegexBuilder();
      builder
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("[[")))
      .push(true)
      .addRegexLeaf(new regex.StarPattern.fromCommand(new regex.AllCharCommand()))
      .pop()
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("]]")));
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(builder.done());

      print(vm.toString());
      return vm.lookingAt(conv.UTF8.encode("[[aabb]]")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"aabb");
      }).catchError((e) {
        expect(true, false);
      });
    });
    
    test('char true a', () {
      regex.RegexBuilder builder = new regex.RegexBuilder();
      builder
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("[[")))
      .push(true)
      .addRegexLeaf(new regex.StarPattern.fromCommand(new regex.UncharacterCommand(conv.UTF8.encode("]]"))))
      .pop()
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("]]")));
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(builder.done());

      print(vm.toString());
      return vm.lookingAt(conv.UTF8.encode("[[aabb]]")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"aabb");
      }).catchError((e) {
        expect(true, false);
      });
    });
    
    test('char true a', () {
      regex.RegexBuilder builder = new regex.RegexBuilder();
      builder
      .push(true)
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("+")))
      .or()
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode("-")))
      .or()
      .addRegexCommand(new regex.EmptyCommand())
      .pop()
      .push(true)
      .addRegexLeaf(new regex.StarPattern.fromCommand(new regex.MatchByteCommand([0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39])))
      .or()
      .addRegexCommand(new regex.EmptyCommand())
      .pop()
      .push(true)
      .addRegexCommand(new regex.CharCommand.createFromList(conv.UTF8.encode(".")))
      .or()
      .addRegexCommand(new regex.EmptyCommand())
      .pop()
      .push(true)
      .addRegexLeaf(new regex.StarPattern.fromCommand(new regex.MatchByteCommand([0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39])))
      .or()
      .addRegexCommand(new regex.EmptyCommand())
      .pop();
      regex.RegexVM vm = new regex.RegexVM.createFromCommand(builder.done());

      print(vm.toString());
      return vm.lookingAt(conv.UTF8.encode("+1000.11")).then((List<List<int>> v) {
        expect(conv.UTF8.decode(v[0]),"+");
        expect(conv.UTF8.decode(v[1]),"1000");
      }).catchError((e) {
        expect(true, false);
      });
    });
  });
}

//commentLong()
