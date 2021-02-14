import 'package:flutter/material.dart';
import "package:audioplayers/audio_cache.dart";
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
  
  //patch
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  void _playDingOnce() async {
    audioCache.play('DeskBell.mp3');
  }

  void _playHandbell() async {
    audioCache.play('Handbell-sound.mp3');
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

    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (_bellSwitch) {
        if (event.x > 0.2 || event.x < -0.2 || event.y > 0.2 || event.y < -0.2 || event.z > 0.2 || event.z < -0.2) {
          _animationController..forward();
          _playHandbell();
        }
      }
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      if (_bellSwitch) {
        if (event.x > 0.2 || event.x < -0.2 || event.y > 0.2 || event.y < -0.2 || event.z > 0.2 || event.z < -0.2) {
          _animationController..forward();
          _playHandbell();
        }
      }
    });


    accelerometerEvents.listen((AccelerometerEvent event) {
      if (_bellSwitch) {
        if (event.x > 0.2 || event.x < -0.2 || event.y > 0.2 || event.y < -0.2 || event.z > 0.2 || event.z < -0.2) {
          _animationController..forward();
          _playHandbell();
        }
      }
    });

    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));

  }

  @override
  Widget build(BuildContext context) {

    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    return Scaffold(
        appBar: null,
        body: Container(
          // decoration: BoxDecoration(
          //     image: DecorationImage(image: AssetImage('1012.png'), repeat: ImageRepeat.repeat)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onDoubleTap: () {
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
                      child: Container(
                        child: Image.asset('bell.png',
                            colorBlendMode: BlendMode.srcATop, 
                            color: _bellColor,
                            height: 150,
                            fit:BoxFit.fill),
                      ),
                    )),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    'Double tap to ring the bell or shake shake baby',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Accelerometer: $accelerometer'),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                ),
                Padding(
                  child: Row(
                    
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('UserAccelerometer: $userAccelerometer'),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                ),
                Padding(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Gyroscope: $gyroscope'),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                ),
              ],
            ),
          ),
        ));
  }
}