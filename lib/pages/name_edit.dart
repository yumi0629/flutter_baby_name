import 'dart:convert';

import 'package:baby_name/model/name.dart';
import 'package:baby_name/utils/universal_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reorderables/reorderables.dart';
import 'package:sqflite/sqflite.dart';

class NameEditPage extends StatefulWidget {
  final int type;

  const NameEditPage({Key key, @required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NameEditState();
}

class NameEditState extends State<NameEditPage> {
  final double _kDefaultHorizontalPadding = 12.0;
  List<Name> _names = [];
  List<Widget> _widgets = [];

  Future _future;

  @override
  void initState() {
    super.initState();
    _future = _loadNames();
  }

  Future _loadNames() async {
    var db = await openDatabase('names.db');
    String table = widget.type == 0 ? 'Girls' : 'Boys';
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
  }

  void _handleReorder(int oldIndex, int newIndex) {
//    setState(() {
//      if (oldIndex < newIndex) {
//        newIndex -= 1;
//      }
//      final Name name = _names.removeAt(oldIndex);
//      _names.insert(newIndex, name);
//    });
    final Name name = _names.removeAt(oldIndex);
    _names.insert(newIndex, name);
    setState(() {
      final Widget row = _widgets.removeAt(oldIndex);
      _widgets.insert(newIndex, row);
    });
  }

  void _deleteName(Name name) {
    setState(() {
      _names.remove(name);
    });
  }

  Future _save() async {
    var db = await openDatabase('names.db');
    String table = widget.type == 0 ? 'Girls' : 'Boys';
    await db.delete(table);
    _names.forEach((name) async {
      await db.insert(table, name.toMap());
    });
    Navigator.of(context).pop(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 40.0),
      color: Colors.white,
      child: Material(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 8.0,
              ),
              child: Text(
                '上下拖动排序，侧滑删除',
                style: TextStyle(
                    fontFamily: 'Lolita', fontSize: 10.0, color: Colors.grey),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_kDefaultHorizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      '姓',
                      style: TextStyle(fontFamily: 'Lolita', fontSize: 14.0),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '名',
                      style: TextStyle(fontFamily: 'Lolita', fontSize: 14.0),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text(
                            '权重',
                            style:
                                TextStyle(fontFamily: 'Lolita', fontSize: 14.0),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '（权重越大，出现的概率越高哦~）',
                            style: TextStyle(
                                fontFamily: 'Lolita',
                                fontSize: 10.0,
                                color: Colors.grey),
                            maxLines: 2,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: FutureBuilder(
                    future: _future,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.done:
                          if (snapshot.hasError) return Container();
                          // 这里不用官方的ReorderableListView，在Expanded里面有bug，拖动item悬浮不动时，listview会抖动
//                          return ReorderableListView(
//                              padding: EdgeInsets.all(0.0),
//                              children: _names.map((value) {
//                                return _buildEditItem(value);
//                              }).toList(),
//                              onReorder: _handleReorder);
                          _widgets.clear();
                          _names.forEach((value) {
                            _buildEditItem(value);
                          });
                          print(_widgets);
                          return CustomScrollView(
                            slivers: <Widget>[
                              ReorderableSliverList(
                                delegate: ReorderableSliverChildListDelegate(
                                    _widgets),
                                onReorder: _handleReorder,
                              )
                            ],
                          );
                          break;
                        default:
                          return Container();
                          break;
                      }
                    }),
              ),
            ),
            Divider(
              color: Colors.blueGrey.shade100,
              height: 1.0,
            ),
            FlatButton(
              onPressed: () => _save(),
              child: Text(
                '保存',
                style: TextStyle(fontFamily: 'Lolita', fontSize: 18),
              ),
              color: Colors.amberAccent,
            ),
          ],
        ),
      ),
    );
  }

  void _buildEditItem(Name name) {
    var item = Container(
      padding: EdgeInsets.only(left: _kDefaultHorizontalPadding),
      key: Key('${name.firstName}${name.name}'),
      height: 40.0,
      child: Slidable(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0.0, 2.0, 5.0, 2.0),
                      child: TextField(
                        onChanged: (value) {
                          name.firstName = value;
                        },
                        controller:
                            TextEditingController(text: '${name.firstName}'),
                        decoration: kDefaultInputDecoration,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0.0, 2.0, 5.0, 2.0),
                      child: TextField(
                        onChanged: (value) {
                          name.name = value;
                        },
                        controller: TextEditingController(text: '${name.name}'),
                        decoration: kDefaultInputDecoration,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0.0, 2.0, 5.0, 2.0),
                      child: TextField(
                        onChanged: (value) {
                          print('weight onChanged :$value');
                          name.weight = int.parse(value);
                        },
                        keyboardType: TextInputType.number,
                        controller:
                            TextEditingController(text: '${name.weight}'),
                        decoration: kDefaultInputDecoration,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          GestureDetector(
            onTap: () => _deleteName(name),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              color: Colors.red,
              child: Text(
                '删除',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
    _widgets.add(item);
  }
}
