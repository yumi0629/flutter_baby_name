// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_name/main.dart';
import 'package:baby_name/model/name.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  var names = [
    Name('', '阿香'),
    Name('', '阿香'),
    Name('张', '阿香'),
    Name('', ''),
    Name('', '阿红'),
    Name('', '阿紫'),
    Name('', '阿香'),
    Name('', '阿香'),
    Name('', '阿香'),
    Name('', '')
  ];

  Observable.fromIterable(names.where((value){
    return !value.isEmpty();
  }))
      .distinctUnique()
      .toList()
      .then((value) {
        print('筛选后的list：$value');
      });
}
