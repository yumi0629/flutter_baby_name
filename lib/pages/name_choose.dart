import 'dart:async';
import 'dart:convert';

import 'package:baby_name/model/name.dart';
import 'package:baby_name/utils/route.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_name/utils/app_config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:baby_name/utils/random_util.dart';
import 'package:sqflite/sqflite.dart';

class NameChoosePage extends StatefulWidget {
  final int type;

  const NameChoosePage({Key key, @required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NameChooseState();
}

class NameChooseState extends State<NameChoosePage>
    with TickerProviderStateMixin {
  AppConfig _appConfig = AppConfig.instance;

  List<Name> _names = [];
  int _index = 0;
  WeightRandom _weightRandom;

  bool _isRandom = AppConfig.instance.loopMode == LoopMode.Random;

  get textColor =>
      widget.type == 0 ? Colors.pinkAccent : Colors.lightBlueAccent;

  Name get randomName => _weightRandom?.getRandomName() ?? Name('', '');

  String get showName => _appConfig.showFirstName
      ? '${currentName.firstName}${currentName.name}'
      : '${currentName.name}';

  Name currentName = Name('', '');

  StreamSubscription _subscription;

  Animation<double> _scaleAnimation;
  AnimationController _controller;

  final FlareControls _flareControls = FlareControls();

  AnimationController _rotateController;
  Animation<double> _rotateAnimation;
  bool _enableMusic = AppConfig.instance.playMusic;

  AudioPlayer _audioPlayer;

  void _getName() {
    if (_controller.isAnimating) return;
    Name preName = currentName;
    currentName = _isRandom
        ? randomName
        : _index >= 0 && _index < _names.length ? _names[_index] : Name('', '');
    if (currentName == preName) _getName();
  }

  @override
  void initState() {
    super.initState();
    _initMusicPlayer();
    _initAnimation();
    _loadNames().then((names) {
      _names = names;
      _weightRandom = WeightRandom(_names);
      _subscription = Observable.periodic(
              Duration(milliseconds: 100), (count) => count % names.length)
          .listen((index) {
        setState(() {
          this._index = index;
          _getName();
        });
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    _rotateController.dispose();
    _audioPlayer?.release();
    super.dispose();
  }

  void _initMusicPlayer() {
    String url =
        _appConfig.defaultMusic ? 'castle_in_the_sky.mp3' : _appConfig.musicUrl;
    Future.delayed(Duration.zero, () {
      if (_appConfig.playMusic) {
        if (_appConfig.defaultMusic) {
          AudioCache().loop(url).then((player) {
            _audioPlayer = player;
          });
        } else {
          _audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
          _audioPlayer.setReleaseMode(ReleaseMode.LOOP);
          _audioPlayer.setUrl(url, isLocal: true);
        }
      }
    });
  }

  Future<List<Name>> _loadNames() async {
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
    return names;
  }

  void _initAnimation() {
    _controller = new AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _scaleAnimation = new Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );
    _rotateController = new AnimationController(
        duration: Duration(milliseconds: 5000), vsync: this);
    _rotateAnimation = new Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotateController);

    Future.delayed(Duration.zero, () {
      if (_appConfig.playMusic) {
        _rotateController.repeat();
      }
    });
  }

  void _playOrPause() {
    if (_audioPlayer.state == AudioPlayerState.PLAYING) {
      _audioPlayer.pause();
    } else if (_audioPlayer.state == AudioPlayerState.PAUSED) {
      _audioPlayer.resume();
    }
  }

  void _chooseOrResume() {
    if (_subscription.isPaused) {
      _subscription.resume();
      _flareControls.onCompleted('estrellas');
      _controller.reset();
    } else {
      _subscription.pause();
      _controller.forward();
      _flareControls.play('estrellas');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        onPressed: () {
          _subscription.pause();
          Navigator.of(context).pushReplacementNamed(UIRoute.nameSetting,
              arguments: widget.type);
        },
        child: Icon(Icons.add),
      ),
      body: Stack(
        children: <Widget>[
          FlareActor(
            'assets/entrellas premio.flr',
            fit: BoxFit.contain,
            controller: _flareControls,
            animation: 'null',
          ),
          GestureDetector(
            child: Container(
              child: Center(
                child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (_, __) {
                      return ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          '$showName',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 80.0,
                              letterSpacing: 10.0,
                              fontFamily: 'Lolita'),
                        ),
                      );
                    }),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/bg_choose.png'))),
            ),
            onTap: () => _chooseOrResume(),
            behavior: HitTestBehavior.translucent,
          ),
          Positioned(
              top: 40.0,
              left: 20.0,
              child: GestureDetector(
                onTap: () {
                  if (_rotateController.isAnimating) {
                    _rotateController.stop();
                  } else {
                    _rotateController.repeat();
                  }
                  _enableMusic = !_enableMusic;
                  _playOrPause();
                  setState(() {});
                },
                child: Stack(
                  children: <Widget>[
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Image.asset(
                        'images/ic_music.png',
                        width: 40.0,
                        height: 40.0,
                      ),
                    ),
                    Visibility(
                      visible: !_enableMusic,
                      child: Image.asset(
                        'images/ic_music_no.png',
                        width: 40.0,
                        height: 40.0,
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
