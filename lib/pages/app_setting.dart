import 'package:baby_name/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AppSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppSettingState();
}

class AppSettingState extends State<AppSettingPage> {
  AppConfig appConfig = AppConfig.instance;
  String musicUrl = AppConfig.instance.musicUrl ?? '';

  String get musicName => musicUrl.lastIndexOf('/') == -1
      ? ''
      : musicUrl.substring(musicUrl.lastIndexOf('/') + 1);

  @override
  void dispose() {
    appConfig.saveAppConfig2SP();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('设置'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 12.0, right: 12.0),
          child: Column(
            children: <Widget>[
              _buildLoopConfig(),
              _buildFirstNameConfig(),
              _buildMusicConfig(),
              _buildMusicResConfig(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoopConfig() {
    return Row(
      children: <Widget>[
        Text('循环模式：'),
        Radio<LoopMode>(
            value: LoopMode.Order,
            groupValue: appConfig.loopMode,
            onChanged: (value) {
              setState(() {
                appConfig.loopMode = value;
              });
            }),
        Text.rich(
          TextSpan(text: '顺序模式', children: [
            TextSpan(
              text: '（该模式下权重无效）',
              style: TextStyle(color: Colors.black26, fontSize: 12.0),
            )
          ]),
        ),
        Radio<LoopMode>(
            value: LoopMode.Random,
            groupValue: appConfig.loopMode,
            onChanged: (value) {
              setState(() {
                appConfig.loopMode = value;
              });
            }),
        Text('随机模式'),
      ],
    );
  }

  Widget _buildFirstNameConfig() {
    return Row(
      children: <Widget>[
        Text('是否展示姓氏：'),
        Radio<bool>(
            value: true,
            groupValue: appConfig.showFirstName,
            onChanged: (value) {
              setState(() {
                appConfig.showFirstName = value;
              });
            }),
        Text('是'),
        Radio<bool>(
            value: false,
            groupValue: appConfig.showFirstName,
            onChanged: (value) {
              setState(() {
                appConfig.showFirstName = value;
              });
            }),
        Text('否'),
      ],
    );
  }

  Widget _buildMusicConfig() {
    return Row(
      children: <Widget>[
        Text('是否播放背景音乐：'),
        Radio<bool>(
            value: true,
            groupValue: appConfig.playMusic,
            onChanged: (value) {
              setState(() {
                appConfig.playMusic = value;
              });
            }),
        Text('是'),
        Radio<bool>(
            value: false,
            groupValue: appConfig.playMusic,
            onChanged: (value) {
              setState(() {
                appConfig.playMusic = value;
              });
            }),
        Text('否'),
      ],
    );
  }

  Widget _buildMusicResConfig() {
    return Visibility(
      visible: appConfig.playMusic,
      child: Row(
        children: <Widget>[
          Text('背景音乐来源：'),
          Radio<bool>(
              value: true,
              groupValue: appConfig.defaultMusic,
              onChanged: (value) {
                setState(() {
                  appConfig.defaultMusic = value;
                });
              }),
          Text('默认'),
          Radio<bool>(
              value: false,
              groupValue: appConfig.defaultMusic,
              onChanged: (value) {
                setState(() {
                  appConfig.defaultMusic = value;
                });
              }),
          Text('本地'),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(
                musicName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              decoration: BoxDecoration(
                border:
                    Border.fromBorderSide(BorderSide(color: Colors.black12)),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
          MaterialButton(
            onPressed:
                appConfig.defaultMusic ? null : () => _openAudioFilePicker(),
            child: Text('选择'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60.0),
            ),
            color: Colors.amberAccent,
            disabledColor: Colors.black26,
            minWidth: 20.0,
            height: 30.0,
            elevation: 0.0,
          ),
        ],
      ),
    );
  }

  void _openAudioFilePicker() {
    PermissionHandler()
        .requestPermissions([PermissionGroup.storage]).then((map) {
      FilePicker.getFilePath(type: FileType.AUDIO)
          .then((path) {
        if (path == null || path.isEmpty) return;
        musicUrl = path;
        appConfig.musicUrl = path;
        setState(() {});
      });
    });
  }
}
