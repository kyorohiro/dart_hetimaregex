library dart_hetimaregex_test;

import 'package:hetimaregex/hetimaregex.dart' as regex;
import 'package:unittest/unittest.dart';
import 'package:hetima/hetima.dart' as heti;

import 'dart:convert' as conv;
import 'dart:typed_data' as tdata;

void main() => script00();

void script00() {
  group('regex00', () {
    
    test('char true', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("aa")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("aa")).then((List<List<int>> v){
        expect(true, true);
      }).catchError((e) {
        expect(true, false);        
      });
    });
    test('char true2', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("aa")),
        new regex.CharCommand.createFromList(conv.UTF8.encode("bb")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("aabbc")).then((List<List<int>> v){
        expect(true, true);
      }).catchError((e) {
        expect(true, false);        
      });
    });

    test('char false', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("aa")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("ab")).then((List<List<int>> v){
        expect(true, false);
      }).catchError((e) {
        expect(true, true);        
      });
    });

    test('split true', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("a")),
        new regex.SplitTaskCommand.create(regex.SplitTaskCommand.LM1, regex.SplitTaskCommand.L1),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("ab")).then((List<List<int>> v){
        expect(true, true);
      }).catchError((e) {
        expect(true, false);        
      });
    });

    test('split true2', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("a")),
        new regex.SplitTaskCommand.create(regex.SplitTaskCommand.LM1, regex.SplitTaskCommand.L1),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("aab")).then((List<List<int>> v){
        expect(true, true);
      }).catchError((e) {
        expect(true, false);        
      });
    });
    test('split true2', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("a")),
        new regex.SplitTaskCommand.create(regex.SplitTaskCommand.LM1, regex.SplitTaskCommand.L1),
        new regex.CharCommand.createFromList(conv.UTF8.encode("b")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("ab")).then((List<List<int>> v){
        expect(true, true);
      }).catchError((e) {
        expect(true, false);        
      });
    });
    test('split true3', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("a")),
        new regex.SplitTaskCommand.create(regex.SplitTaskCommand.LM1, regex.SplitTaskCommand.L1),
        new regex.CharCommand.createFromList(conv.UTF8.encode("b")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("aab")).then((List<List<int>> v){
        expect(true, true);
      }).catchError((e) {
        expect(true, false);        
      });
    });
    test('split true3', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.CharCommand.createFromList(conv.UTF8.encode("a")),
        new regex.SplitTaskCommand.create(regex.SplitTaskCommand.LM1, regex.SplitTaskCommand.L1),
        new regex.CharCommand.createFromList(conv.UTF8.encode("b")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("aac")).then((List<List<int>> v){
        expect(true, false);
      }).catchError((e) {
        expect(true, true);        
      });
    });

    test('jump true3', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.SplitTaskCommand.create(regex.SplitTaskCommand.L1, regex.SplitTaskCommand.L3),
        new regex.CharCommand.createFromList(conv.UTF8.encode("a")),
        new regex.JumpTaskCommand.create(regex.SplitTaskCommand.L2),
        new regex.CharCommand.createFromList(conv.UTF8.encode("b")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("ab")).then((List<List<int>> v){
        expect(true, true);
      }).catchError((e) {
        expect(true, false);        
      });
    });
    
    test('jump true4', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.SplitTaskCommand.create(regex.SplitTaskCommand.L1, regex.SplitTaskCommand.L3),
        new regex.CharCommand.createFromList(conv.UTF8.encode("a")),
        new regex.JumpTaskCommand.create(regex.SplitTaskCommand.L2),
        new regex.CharCommand.createFromList(conv.UTF8.encode("b")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("b")).then((List<List<int>> v){
        expect(true, true);
      }).catchError((e) {
        expect(true, false);        
      });
    });
    test('jump true4', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.SplitTaskCommand.create(regex.SplitTaskCommand.L1, regex.SplitTaskCommand.L3),
        new regex.CharCommand.createFromList(conv.UTF8.encode("a")),
        new regex.JumpTaskCommand.create(regex.SplitTaskCommand.L2),
        new regex.CharCommand.createFromList(conv.UTF8.encode("b")),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("c")).then((List<List<int>> v){
        expect(true, false);
      }).catchError((e) {
        expect(true, true);        
      });
    });
    test('char memory true', () {
      regex.RegexVM vm = new regex.RegexVM.createFromCommand([
        new regex.MemoryStartCommand(),
        new regex.CharCommand.createFromList(conv.UTF8.encode("aa")),
        new regex.CharCommand.createFromList(conv.UTF8.encode("bb")),
        new regex.MemoryStopCommand(),
        new regex.MatchCommand(),
        ]);

      return vm.match(conv.UTF8.encode("aabbc")).then((List<List<int>> v){
        expect(true, true);
        expect(conv.UTF8.decode(v[0]), "aabb");
      }).catchError((e) {
        expect(true, false);        
      });
    });
  });
}

//commentLong() 