import 'package:baby_name/model/name.dart';
import 'package:baby_name/utils/universal_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reorderables/reorderables.dart';

import 'name_edit_bloc.dart';
import 'package:baby_name/utils/easy_stream_builder.dart';

class NameEditPage extends StatefulWidget {
  final int type;

  const NameEditPage({Key key, @required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NameEditState(type);
}

class NameEditState extends State<NameEditPage> {
  final double _kDefaultHorizontalPadding = 12.0;
  final int type;
  NameEditBloc bloc;

  NameEditState(this.type) : bloc = NameEditBloc(type);

  @override
  void initState() {
    super.initState();
    bloc.loadNames((value) {
      return _buildEditItem(value);
    });
  }

  Future _save() async {
    await bloc.save();
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
                child: EasyStreamBuilder<List<Widget>>(
                    stream: bloc.widgetSubject,
                    builder: (context, snapshot) {
                      return CustomScrollView(
                        slivers: <Widget>[
                          // 这里不用官方的ReorderableListView，在Expanded里面有bug，拖动item悬浮不动时，listview会抖动
                          ReorderableSliverList(
                            delegate: ReorderableSliverChildListDelegate(
                                snapshot.data),
                            onReorder: bloc.handleReorder,
                          )
                        ],
                      );
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

  Widget _buildEditItem(Name name) {
    return Container(
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
                    flex: 2,
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
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10.0, 8.0, 15.0, 8.0),
                      child: Image.asset(
                        'images/ic_drag.png',
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
            onTap: () => bloc.deleteName(name),
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
  }
}
