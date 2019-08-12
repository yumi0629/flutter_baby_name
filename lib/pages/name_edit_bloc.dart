import 'dart:async';

import 'package:baby_name/model/name.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class NameEditBloc {
  final int type;

  NameEditBloc(this.type);

  List<Name> _names = [];
  List<Widget> _widgets = [];

  final PublishSubject<List<Widget>> widgetSubject = PublishSubject();

  Future loadNames(Widget buildEditItem(Name value)) async {
    var db = await openDatabase('names.db');
    String table = type == 0 ? 'Girls' : 'Boys';
    List<Map<String, dynamic>> results =
        await db.query(table, columns: ['first_name', 'name', 'weight']);
    List<Name> names = [];
    results.forEach((value) {
      names.add(Name(
        value['first_name'],
        value['name'],
        weight: value['weight'],
      ));
    });
    this._names = names;
    _widgets.clear();
    _names.forEach((value) {
      _widgets.add(buildEditItem(value));
    });
    widgetSubject.add(_widgets);
  }

  void handleReorder(int oldIndex, int newIndex) {
    final Name name = _names.removeAt(oldIndex);
    _names.insert(newIndex, name);
    final Widget row = _widgets.removeAt(oldIndex);
    _widgets.insert(newIndex, row);
    widgetSubject.add(_widgets);
  }

  void deleteName(Name name) {
    _widgets.removeAt(_names.indexOf(name));
    _names.remove(name);
    widgetSubject.add(_widgets);
  }

  Future save() async {
    var db = await openDatabase('names.db');
    String table = type == 0 ? 'Girls' : 'Boys';
    await db.delete(table);
    _names.forEach((name) async {
      await db.insert(table, name.toMap());
    });
  }
}
