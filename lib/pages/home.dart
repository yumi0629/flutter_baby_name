import 'dart:convert';

import 'package:baby_name/model/name.dart';
import 'package:baby_name/utils/route.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_name/utils/app_config.dart';
import 'package:sqflite/sqflite.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var index = -1;

  @override
  void initState() {
    super.initState();
    __loadDefaultAppConfig();
    _loadDefaultNamesIfNeeded();
  }

  Future __loadDefaultAppConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String config = '';
    if (prefs.getBool('hasAppConfig') ?? true) {
      config = await DefaultAssetBundle.of(context)
          .loadString('assets/appConfig.json');
      await prefs.setString('appConfig', config);
      await prefs.setBool('hasAppConfig', false);
    } else {
      config = prefs.getString('appConfig');
    }
    AppConfig.instance.init(config);
  }

  Future _loadDefaultNamesIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isFirst') ?? true) {
      String boysStr =
          await DefaultAssetBundle.of(context).loadString('assets/boys.json');
      String girlsStr =
          await DefaultAssetBundle.of(context).loadString('assets/girls.json');
      List<Name> boys = getNamesList(json.decode(boysStr));
      List<Name> girls = getNamesList(json.decode(girlsStr));
      var db = await openDatabase('names.db', version: 1,
          onCreate: (db, version) async {
        await db.execute(
            "create table Boys(id integer primary key autoincrement,first_name text,name text not null,weight integer not null default 1)");
        await db.execute(
            "create table Girls(id integer primary key autoincrement,first_name text,name text not null,weight integer not null default 1)");
        print("Table is created");
      });
      boys.forEach((boy) {
        db.insert('Boys', boy.toMap());
      });
      girls.forEach((girl) {
        db.insert('Girls', girl.toMap());
      });
      prefs.setBool('isFirst', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        onPressed: () {
          Navigator.of(context).pushNamed(UIRoute.appSetting);
        },
        child: Icon(Icons.settings),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(40.0, 60.0, 40.0, 20.0),
        child: Center(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Image.asset(
                              'images/ic_girl.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              index = 0;
                            });
                          },
                        ),
                        Positioned(
                          left: 0.0,
                          top: 0.0,
                          right: 0.0,
                          bottom: 0.0,
                          child: Visibility(
                            visible: index == 0,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.fromBorderSide(BorderSide(
                                    color: Colors.pinkAccent, width: 2.0)),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Image.asset(
                              'images/ic_boy.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              index = 1;
                            });
                          },
                        ),
                        Positioned(
                          left: 0.0,
                          top: 0.0,
                          right: 0.0,
                          bottom: 0.0,
                          child: Visibility(
                            visible: index == 1,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.fromBorderSide(BorderSide(
                                    color: Colors.lightBlue, width: 2.0)),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: FlatButton(
                    onPressed: () {
                      if (index == -1) {
                        showToast('请先选择宝宝性别哦~');
                        return;
                      }
                      Navigator.of(context)
                          .pushNamed(UIRoute.nameChoose, arguments: index);
                    },
                    child: Text(
                      '下一步',
                      style: TextStyle(fontFamily: 'Lolita', fontSize: 18),
                    ),
                    color: Colors.amberAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
