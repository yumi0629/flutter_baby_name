import 'package:baby_name/model/name.dart';
import 'package:baby_name/utils/universal_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'name_edit.dart';
import 'name_setting_bloc.dart';
import 'package:baby_name/utils/easy_stream_builder.dart';

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
  final NameSettingBloc bloc = NameSettingBloc();
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

  final TextEditingController _boysTextController = TextEditingController();
  final TextEditingController _girlsTextController = TextEditingController();
  final TextEditingController _firstNameTextController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    bloc.loadNames(0);
    bloc.loadNames(1);
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

  void _addNames(String namesStr, int type) {
    bloc.addNames(namesStr, _firstNameTextController.text, type, () {
      if (type == 0)
        _girlsTextController.clear();
      else if (type == 1) _boysTextController.clear();
    });
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
                  bloc.loadNames(type);
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
                        child: EasyStreamBuilder<bool>(
                          initialData: bloc.needFirstName,
                          stream: bloc.firstNameSubject,
                          builder: (context, snapshot) {
                            return Checkbox(
                                value: snapshot.data,
                                onChanged: (isChecked) {
                                  bloc.switchFirstNameStatus();
                                });
                          },
                        ),
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
            child: EasyStreamBuilder<List<Name>>(
              stream: index == 0 ? bloc.girlsSubject : bloc.boysSubject,
              builder: (context, snapshot) {
                return Container(
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.8,
                    crossAxisCount: 4,
                    children: List.generate(snapshot.data.length, (i) {
                      var name =
                          '${snapshot.data[i].firstName}${snapshot.data[i].name}';
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
              },
            ),
          )
        ],
      ),
    );
  }

  Color _getColor(int index) {
    return _colors[index % _colors.length];
  }
}
