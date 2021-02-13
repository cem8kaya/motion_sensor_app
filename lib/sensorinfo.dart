// alert sound when AccelerometerEvent event threshold is > 0.1

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

// import 'snake.dart';

//AlertPart Added
import "package:audioplayers/audio_cache.dart";
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // static const int _snakeRows = 20;
  // static const int _snakeColumns = 20;
  // static const double _snakeCellSize = 10.0;

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  //AlertPart Added
  AudioCache audioCache = new AudioCache();
  AudioPlayer _audioPlayer;
  bool _bellSwitch = false;
  Color _bellColor = Colors.black54;
  bool _isPlaying = false;

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
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Snake Widget
          // Center(
          //   child: DecoratedBox(
          //     decoration: BoxDecoration(
          //       border: Border.all(width: 1.0, color: Colors.black38),
          //     ),
          //     child: SizedBox(
          //       height: _snakeRows * _snakeCellSize,
          //       width: _snakeColumns * _snakeCellSize,
          //       child: Snake(
          //         rows: _snakeRows,
          //         columns: _snakeColumns,
          //         cellSize: _snakeCellSize,
          //       ),
          //     ),
          //   ),
          // ),

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
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();

    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });

      //AlertPart Added

    }));

    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });

      //AlertPart Added
      if (_bellSwitch) {
        if (event.x > 0.2 || event.x < -0.2 || event.y > 0.2 || event.y < -0.2 || event.z > 0.2 || event.z < -0.2) {
          _playBellSound();
        }
      }
    }));

    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });

            //AlertPart Added
      if (_bellSwitch) {
        if (event.x > 0.2 || event.x < -0.2 || event.y > 0.2 || event.y < -0.2 || event.z > 0.2 || event.z < -0.2) {
          _playBellSound();
        }
      }

    }));
  }
}
