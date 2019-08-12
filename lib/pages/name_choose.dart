import 'dart:async';

import 'package:baby_name/utils/easy_stream_builder.dart';
import 'package:baby_name/utils/route.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:baby_name/utils/app_config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

import 'name_choose_bloc.dart';

class NameChoosePage extends StatefulWidget {
  final int type;

  const NameChoosePage({Key key, @required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NameChooseState(type);
}

class NameChooseState extends State<NameChoosePage>
    with TickerProviderStateMixin {
  final int type;
  NameChooseBloc bloc;

  get textColor => type == 0 ? Colors.pinkAccent : Colors.lightBlueAccent;

  NameChooseState(this.type) : bloc = NameChooseBloc(type);

  Animation<double> _scaleAnimation;
  AnimationController _controller;

  final FlareControls _flareControls = FlareControls();

  AnimationController _rotateController;
  Animation<double> _rotateAnimation;

  AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _initMusicPlayer(bloc.appConfig);
    _initAnimation(bloc.appConfig);
    bloc.loadNames(() => _controller?.isAnimating ?? false);
  }

  @override
  void dispose() {
    bloc.dispose();
    _controller.dispose();
    _rotateController.dispose();
    _audioPlayer?.release();
    super.dispose();
  }

  void _initMusicPlayer(AppConfig config) {
    String url =
        config.defaultMusic ? 'castle_in_the_sky.mp3' : config.musicUrl;
    Future.delayed(Duration.zero, () {
      if (config.playMusic) {
        if (config.defaultMusic) {
          AudioCache().loop(url).then((player) {
            _audioPlayer = player;
          });
        } else {
          _audioPlayer = AudioPlayer()
            ..setReleaseMode(ReleaseMode.LOOP)
            ..play(url, isLocal: true);
          print('audio url = $url');
        }
      }
    });
  }

  void _initAnimation(AppConfig config) {
    _controller = AnimationController(
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
      if (config.playMusic) {
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
    bloc.pauseOrResumeSubscription(pause: () {
      _controller.forward();
      _flareControls.play('estrellas');
    }, resume: () {
      _flareControls.onCompleted('estrellas');
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        onPressed: () {
          bloc.pauseSubscription();
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
                child: EasyStreamBuilder<String>(
                    stream: bloc.nameSubject,
                    builder: (context, snapshot) {
                      return AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (_, __) {
                            return ScaleTransition(
                              scale: _scaleAnimation,
                              child: Text(
                                '${snapshot.data}',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 80.0,
                                    letterSpacing: 10.0,
                                    fontFamily: 'Lolita'),
                              ),
                            );
                          });
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
            child: EasyStreamBuilder<bool>(
              initialData: bloc.appConfig.playMusic,
              stream: bloc.musicSubject,
              builder: (context, snapshot) {
                return Visibility(
                    visible: bloc.appConfig.playMusic,
                    child: GestureDetector(
                      onTap: () {
                        if (_rotateController.isAnimating) {
                          _rotateController.stop();
                        } else {
                          _rotateController.repeat();
                        }
                        bloc.switchPlayingStatus();
                        _playOrPause();
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
                            visible: !snapshot.data,
                            child: Image.asset(
                              'images/ic_music_no.png',
                              width: 40.0,
                              height: 40.0,
                            ),
                          )
                        ],
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
