import 'dart:async';
import 'package:baby_name/model/name.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class NameSettingBloc {
  List<Name> _boys = [];
  List<Name> _girls = [];
  bool needFirstName = false;

  final PublishSubject<List<Name>> girlsSubject = PublishSubject();
  final PublishSubject<List<Name>> boysSubject = PublishSubject();
  final PublishSubject<bool> firstNameSubject = PublishSubject();

  void switchFirstNameStatus() {
    needFirstName = !needFirstName;
    firstNameSubject.add(needFirstName);
  }

  void loadNames(int type) async {
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
    type == 0 ? _girls = names : _boys = names;
    type == 0 ? girlsSubject.add(names) : boysSubject.add(names);
  }

  void addNames(String namesStr, String firstName, int type,
      void clearTextController()) async {
    if (namesStr == null || namesStr.trim() == '') return;
    List<Name> names = namesStr.split(' ').map((value) {
      if (needFirstName) {
        return Name(firstName, value.trim());
      }
      return Name('', value.trim());
    }).toList();

    var db = await openDatabase('names.db');
    if (type == 0) {
      _girls.addAll(names);
      _girls = _girls.where((value) => !value.isEmpty()).toSet().toList();
      clearTextController();
      await db.delete('Girls');
      _girls.forEach((name) async {
        await db.insert('Girls', name.toMap());
      });
      girlsSubject.add(_girls);
    } else if (type == 1) {
      _boys.addAll(names);
      _boys = _boys.where((value) => !value.isEmpty()).toSet().toList();
      clearTextController();
      await db.delete('Boys');
      _boys.forEach((name) async {
        await db.insert('Boys', name.toMap());
      });
      boysSubject.add(_boys);
    }
  }
}
