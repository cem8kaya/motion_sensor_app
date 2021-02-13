//https://github.com/h4ck4life/flutter-play-sound

import 'package:flutter/material.dart';
import "package:audioplayers/audio_cache.dart";
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors/sensors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'handbell',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Handbell'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AudioCache audioCache = new AudioCache();
  AudioPlayer _audioPlayer;
  bool _bellSwitch = false;
  Color _bellColor = Colors.black54;
  bool _isPlaying = false;

  Animation<Color> _tweenColor;
  Animation<double> _animation;
  AnimationController _animationController;
  AnimationController _colorAnimationController;

  void _playDingOnce() async {
    audioCache.play('DeskBell.mp3');
  }

  void _playBellSound() async {
    if (_isPlaying == false) {
      setState(() => _isPlaying = true);
      audioCache.play('Handbell-sound.mp3').then((audioPlayer) {
        setState(() => _audioPlayer = audioPlayer);
        audioPlayer.completionHandler = () {
          setState(() => _isPlaying = false);
        };
      });
    } else {
      _audioPlayer.stop();
      setState(() => _isPlaying = false);
    }
  }

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (_bellSwitch) {
        if (event.x > 5.0 || event.x < -5.0) {
          _animationController..forward();
          _playDingOnce();
        }
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );

    _animation.addListener(() {
      if (_animation.value > 0.05) {
        _animationController..reverse();
      }
    });

    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _tweenColor = ColorTween(begin: Colors.black54, end: Colors.transparent)
        .animate(_colorAnimationController);
    _tweenColor.addListener(() {
      setState(() => _bellColor = _tweenColor.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('1012.png'), repeat: ImageRepeat.repeat)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      if (_bellSwitch) {
                        _colorAnimationController..reverse();
                        _animationController..reset();
                        setState(() => _bellSwitch = false);
                      } else {
                        _colorAnimationController..forward();
                        _animationController..forward();
                        setState(() => _bellSwitch = true);
                      }
                    },
                    child: RotationTransition(
                      alignment: Alignment(0.0, 0.0),
                      turns: _animation,
                      child: Image.asset('bell.png',
                          colorBlendMode: BlendMode.srcATop, color: _bellColor),
                    )),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    'Made with ♥ by Alif',
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
