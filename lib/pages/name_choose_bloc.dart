import 'dart:async';

import 'package:baby_name/model/name.dart';
import 'package:baby_name/utils/app_config.dart';
import 'package:baby_name/utils/random_util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class NameChooseBloc {
  final int _type;

  AppConfig appConfig = AppConfig.instance;

  List<Name> _names = [];
  int _index = 0;
  WeightRandom _weightRandom;

  bool _isRandom = AppConfig.instance.loopMode == LoopMode.Random;

  Name get randomName => _weightRandom?.getRandomName() ?? Name('', '');

  String get showName => appConfig.showFirstName
      ? '${_currentName.firstName}${_currentName.name}'
      : '${_currentName.name}';

  Name _currentName = Name('', '');

  bool _isMusicPlaying = AppConfig.instance.playMusic;

  StreamSubscription _subscription;

  final PublishSubject<String> nameSubject = PublishSubject();
  final PublishSubject<bool> musicSubject = PublishSubject();

  NameChooseBloc(this._type);

  void dispose() {
    _subscription?.cancel();
    nameSubject.close();
    musicSubject.close();
  }

  void pauseSubscription() {
    _subscription.pause();
  }

  void pauseOrResumeSubscription({void pause(), void resume()}) {
    if (_subscription.isPaused) {
      _subscription.resume();
      resume();
    } else {
      _subscription.pause();
      pause();
    }
  }

  void switchPlayingStatus() {
    _isMusicPlaying = !_isMusicPlaying;
    musicSubject.add(_isMusicPlaying);
  }

  void loadNames(bool isAnimating()) async {
    var db = await openDatabase('names.db');
    String table = _type == 0 ? 'Girls' : 'Boys';
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
    _weightRandom = WeightRandom(names);

    _subscription = Observable.periodic(
            Duration(milliseconds: 100), (count) => count % names.length)
        .listen((index) {
      _index = index;

      if (isAnimating()) return;

      _getName();
      nameSubject.add(showName);
    });
  }

  void _getName() {
    Name preName = _currentName;
    _currentName = _isRandom
        ? randomName
        : _index >= 0 && _index < _names.length ? _names[_index] : Name('', '');
    if (_currentName == preName) _getName();
  }
}
