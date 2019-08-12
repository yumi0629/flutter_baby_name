import 'dart:convert';

import 'package:baby_name/model/name.dart';
import 'package:baby_name/utils/universal_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'name_edit.dart';

class NameSettingPage extends StatefulWidget {
  final int index;

  const NameSettingPage({Key key, @required this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NameSettingState();
}

class TabTitle {
  String title;
  int id;

  TabTitle(this.title, this.id);
}

class NameSettingState extends State<NameSettingPage>
    with SingleTickerProviderStateMixin {
  final _tabList = [TabTitle('女宝宝', 0), TabTitle('男宝宝', 1)];
  final _colors = [
    Colors.amberAccent.shade100,
    Colors.lightBlueAccent.shade100,
    Colors.pinkAccent.shade100,
    Colors.limeAccent.shade100,
    Colors.greenAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.lightGreenAccent.shade100,
    Colors.orangeAccent.shade100,
    Colors.redAccent.shade100,
    Colors.deepPurpleAccent.shade100,
    Colors.tealAccent.shade100,
    Colors.deepOrangeAccent.shade100,
    Colors.indigoAccent.shade100
  ];
  TabController _tabController;
  PageController _pageController;

  var _isPageCanChanged = true;
  var _needFirstName = false;

  List<Name> _boys = [];
  List<Name> _girls = [];
  Future _boysFuture;
  Future _girlsFuture;
  final TextEditingController _boysTextController = TextEditingController();
  final TextEditingController _girlsTextController = TextEditingController();
  final TextEditingController _firstNameTextController =
      TextEditingController();

  Future _loadNames(int type) async {
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
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _girlsFuture = _loadNames(0);
    _boysFuture = _loadNames(1);
    _tabController = TabController(
        initialIndex: widget.index, length: _tabList.length, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          //判断TabBar是否切换
          _onPageChange(_tabController.index, pageController: _pageController);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChange(int index,
      {PageController pageController, TabController tabController}) async {
    if (pageController != null) {
      //判断是哪一个切换
      _isPageCanChanged = false;
      await _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease); //等待pageview切换完毕,再释放pageivew监听
      _isPageCanChanged = true;
    } else {
      _tabController.animateTo(index); //切换Tabbar
    }
  }

  Future _addNames(String namesStr, int type) async {
    if (namesStr == null || namesStr.trim() == '') return;
    List<Name> names = namesStr.split(' ').map((value) {
      if (_needFirstName) {
        return Name(_firstNameTextController.text, value.trim());
      }
      return Name('', value.trim());
    }).toList();

    var db = await openDatabase('names.db');
    if (type == 0) {
      _girls.addAll(names);
      _girls = _girls.where((value) => !value.isEmpty()).toSet().toList();
      _girlsTextController.clear();
      await db.delete('Girls');
      _girls.forEach((name) async {
        await db.insert('Girls', name.toMap());
      });
    } else if (type == 1) {
      _boys.addAll(names);
      _boys = _boys.where((value) => !value.isEmpty()).toSet().toList();
      _boysTextController.clear();
      await db.delete('Boys');
      _boys.forEach((name) async {
        await db.insert('Boys', name.toMap());
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Center(
            child: FlatButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return NameEditPage(
                        type: _tabController.index,
                      );
                    }).then((type) {
                  _loadNames(type).then((_) {
                    setState(() {});
                  });
                });
              },
              child: Text(
                '编辑',
                style: TextStyle(fontSize: 16.0, color: Colors.black87),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        title: TabBar(
          isScrollable: true,
          controller: _tabController,
          indicatorWeight: 4.0,
          tabs: _tabList.map((value) {
            return Tab(
              child: Text(
                value.title,
                style: TextStyle(fontSize: 18.0, fontFamily: 'Lolita'),
              ),
            );
          }).toList(),
        ),
      ),
      body: PageView.builder(
          itemCount: _tabList.length,
          controller: _pageController,
          onPageChanged: (index) {
            if (_isPageCanChanged) {
              //由于pageview切换是会回调这个方法,又会触发切换tabbar的操作,所以定义一个flag,控制pageview的回调
              _onPageChange(index);
            }
          },
          itemBuilder: (_, index) {
            return _buildPageItem(index);
          }),
    );
  }

  Widget _buildPageItem(int index) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller:
                        index == 0 ? _girlsTextController : _boysTextController,
                    maxLines: 5,
                    inputFormatters: [
                      BlacklistingTextInputFormatter.singleLineFormatter
                    ],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        hintText: '多个名字请用空格隔开，重复名字会自动去重',
                        hintStyle: TextStyle(fontSize: 14.0)),
                  ),
                  Row(
                    children: <Widget>[
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.black12,
                          disabledColor: Colors.black12,
                        ),
                        child: Checkbox(
                            value: _needFirstName,
                            onChanged: (isChecked) {
                              setState(() {
                                _needFirstName = isChecked;
                              });
                            }),
                      ),
                      Text('是否添加姓氏'),
                      Container(
                        margin: EdgeInsets.only(left: 10.0),
                        width: 60.0,
                        height: 30.0,
                        child: TextField(
                          controller: _firstNameTextController,
                          decoration: kDefaultInputDecoration,
                        ),
                      )
                    ],
                  ),
                  FlatButton(
                    onPressed: () {
                      if (index == 0) {
                        _addNames(_girlsTextController.text, 0);
                      } else if (index == 1) {
                        _addNames(_boysTextController.text, 1);
                      }
                    },
                    child: Text(
                      '添加',
                      style: TextStyle(fontFamily: 'Lolita', fontSize: 16.0),
                    ),
                    color: Colors.amberAccent,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: FutureBuilder(
                future: index == 0 ? _girlsFuture : _boysFuture,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasError) return Container();
                      return Container(
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.8,
                          crossAxisCount: 4,
                          children: List.generate(
                              index == 0 ? _girls.length : _boys.length, (i) {
                            var name = index == 0
                                ? '${_girls[i].firstName}${_girls[i].name}'
                                : '${_boys[i].firstName}${_boys[i].name}';
                            return Center(
                              child: Chip(
                                label: Text(
                                  name,
                                  style: TextStyle(color: Colors.black87),
                                ),
                                backgroundColor: _getColor(i),
                              ),
                            );
                          }),
                        ),
                      );
                      break;
                    default:
                      return Container();
                      break;
                  }
                }),
          )
        ],
      ),
    );
  }

  Color _getColor(int index) {
    return _colors[index % _colors.length];
  }
}
