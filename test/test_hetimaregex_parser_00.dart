library dart_hetimaparser_test;

import 'package:hetimaregex/hetimaregex.dart' as regex;
import 'package:unittest/unittest.dart';
import 'package:hetima/hetima.dart' as heti;

import 'dart:convert' as conv;
import 'dart:typed_data' as tdata;

void main() => script00();

void script00() {
  group('regex00', () {

    test('char true', () {
      regex.RegexParser parser = new regex.RegexParser();

      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("aa")),
        new regex.MatchCommand(),
      ]);

      return vm.match(conv.UTF8.encode("aa")).then((List<List<int>> v) {
        expect(true, true);
      }).catchError((e) {
        expect(true, false);
      });
    });

  });
}

//commentLong()
