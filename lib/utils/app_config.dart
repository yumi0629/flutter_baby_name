import 'dart:convert';

import 'package:baby_name/model/app_config_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoopMode {
  Order,
  Random,
}

class AppConfig {
  factory AppConfig() => _getInstance();

  static AppConfig get instance => _getInstance();
  static AppConfig _instance;

  AppConfig._internal() {}

  static AppConfig _getInstance() {
    if (_instance == null) {
      _instance = new AppConfig._internal();
    }
    return _instance;
  }

  LoopMode loopMode = LoopMode.Order;
  bool showFirstName = true;
  bool playMusic = true;
  bool defaultMusic = true;
  String musicUrl = "";

  void init(String config) {
    AppConfigModel configModel = AppConfigModel.fromJson(json.decode(config));
    loopMode = LoopMode.values[configModel.loopMode];
    showFirstName = configModel.showFirstName;
    playMusic = configModel.playMusic;
    defaultMusic = configModel.defaultMusic;
    musicUrl = configModel.musicUrl;
  }

  Future saveAppConfig2SP() async {
    AppConfigModel configModel = AppConfigModel(
        loopMode.index, showFirstName, playMusic, defaultMusic, musicUrl);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('appConfig', json.encode(configModel));
  }
}
