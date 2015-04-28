library dart_hetimaparser_test_parser;

import 'package:hetimaregex/hetimaregex.dart' as regex;
import 'package:unittest/unittest.dart';
import 'package:hetima/hetima.dart' as heti;

import 'dart:convert' as conv;
import 'dart:typed_data' as tdata;

void main() => script00();

void script00() {
  group('parser00', () {
    test('char true a', () {
      regex.RegexParser parser = new regex.RegexParser();
      parser.compile("aa").then((regex.RegexVM vm) {
        return vm.match(conv.UTF8.encode("aabb")).then((List<List<int>> v){
          expect(true, true);          
        });
      }).catchError((e) {
        expect(true, false);
      });
    });
    test('char true b', () {
      regex.RegexParser parser = new regex.RegexParser();
      parser.compile("(aa)").then((regex.RegexVM vm) {
        return vm.match(conv.UTF8.encode("aabb")).then((List<List<int>> v){
          //expect(true, true);
          expect(conv.UTF8.decode(v[0]),"aa");
        });
      }).catchError((e) {
        expect(true, false);
      });
    });
    test('char true c', () {
      regex.RegexParser parser = new regex.RegexParser();
      parser.compile("(a*)").then((regex.RegexVM vm) {
        return vm.match(conv.UTF8.encode("aaabb")).then((List<List<int>> v){
          expect(conv.UTF8.decode(v[0]),"aaa");
        });
      }).catchError((e) {
        expect(true, false);
      });
    });
/*
    test('char true d', () {
      regex.RegexParser parser = new regex.RegexParser();
      parser.compile("(ab)*").then((regex.RegexVM vm) {
        return vm.match(conv.UTF8.encode("ababc")).then((List<List<int>> v){
          expect(conv.UTF8.decode(v[0]),"abab");
        });
      }).catchError((e) {
        expect(true, false);
      });
    });
    */
  });
}

//commentLong()
