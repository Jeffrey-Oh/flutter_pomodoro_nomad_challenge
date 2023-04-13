import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          backgroundColor: const Color(0xffe64d3d),
        ),
        primaryColor: const Color(0xffe64d3d),
      ),
      home: const Pomodoro(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Pomodoro extends StatelessWidget {
  const Pomodoro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PomodoroScreen(),
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final PageController _pageController =
      PageController(viewportFraction: 0.2, initialPage: 2);
  int _initSeconds = 1500;
  static const int _initTakeRestSeconds = 300;
  late int _totalSeconds = _initSeconds;
  late int _totalTakeRestSeconds = _initTakeRestSeconds;
  final int _totalRound = 4;
  int _currentRound = 0;
  final int _totalGoal = 12;
  int _currentGoal = 0;
  bool _isRunning = false;
  bool _isRoundFinished = false;
  bool _isInit = true;
  bool _isAnimating = false;
  late Timer _timer;
  late Timer _takeRestTimer;
  String restMessage = 'Take a rest';
  List<String> timeList = ['15', '20', '25', '30', '35'];
  int _initPage = 2;
  int _currentIndex = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String format(int seconds) {
    var duration = Duration(seconds: seconds);
    return duration.toString().split(".").first.substring(2, 7);
  }

  void onTakeRestTick(Timer timer) {
    if (_totalTakeRestSeconds == 0) {
      setState(() {
        _isRoundFinished = false;
        _totalTakeRestSeconds = _initTakeRestSeconds;
        restMessage = 'Take a rest';
      });
      timer.cancel();
    } else {
      setState(() {
        _totalTakeRestSeconds--;
      });
    }
  }

  void onTick(Timer timer) {
    if (_totalSeconds == 0) {
      setState(() {
        _currentRound++;
        _isRunning = false;
        _isRoundFinished = true;
        _totalSeconds = _initSeconds;
        _isInit = true;
        if (_currentRound == _totalRound) {
          _currentGoal++;
          _currentRound = 0;
        }
        if (_currentGoal == _totalGoal) {
          _currentGoal = 0;
        }
      });
      timer.cancel();

      // take a rest
      _takeRestTimer = Timer.periodic(
        const Duration(seconds: 1),
        onTakeRestTick,
      );
    } else {
      setState(() {
        _totalSeconds--;
      });
    }
  }

  void onStartPressed() {
    if (_isRoundFinished) {
      if (_totalTakeRestSeconds > 150) {
        restMessage = 'Please Take a rest';
      } else {
        restMessage = 'Please !! Take a rest !!';
      }
    } else {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
      setState(() {
        _isRunning = true;
        _isInit = false;
      });
    }
  }

  void onPausePressed() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void onReset() {
    setState(() {
      _isRunning = false;
      _isRoundFinished = false;
      _totalSeconds = _initSeconds;
      _isInit = true;
    });
    _timer.cancel();
  }

  void onSelectedTime(int index) {
    if (!_isRunning) {
      setState(() {
        _isInit = true;
        _initPage = index;
        String selectedTime = timeList[index];
        _initSeconds = int.parse(selectedTime) * 60;
        _totalSeconds = _initSeconds;
      });

      _onItemClicked(index);
    }
  }

  void _onItemClicked(int index) {
    if (!_isAnimating) {
      _isAnimating = true;
      _pageController
          .animateTo(
        index * 90,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      )
          .then((value) {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 30,
                ),
                child: const Text(
                  'POMOTIMER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Opacity(
                opacity: !_isRunning && _isRoundFinished ? 1 : 0,
                child: Text(
                  '$restMessage ☕ ${format(_totalTakeRestSeconds)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                        time: format(_totalSeconds).toString().substring(0, 2)),
                    SizedBox(
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(time: format(_totalSeconds).toString().substring(3)),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: 600,
                height: 40,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: timeList.length,
                  itemBuilder: (context, index) {
                    double opacity =
                        1.0 - (0.2 * (_currentIndex - index).abs());
                    return GestureDetector(
                      onTap: () => onSelectedTime(index),
                      child: Opacity(
                        opacity: _initPage == index ? 1 : opacity,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _initPage == index
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            timeList[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _initPage == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 36,
                      onPressed: _isRunning ? onPausePressed : onStartPressed,
                      icon: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (!_isInit) const SizedBox(height: 5),
                  if (!_isInit)
                    GestureDetector(
                      onTap: onReset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$_currentRound/$_totalRound',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ROUND',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$_currentGoal/$_totalGoal',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'GOAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Card extends StatefulWidget {
  const Card({
    super.key,
    required this.time,
  });

  final String time;

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(9, -9),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white.withOpacity(0.5),
            ),
            width: 120,
            height: 150,
          ),
        ),
        Transform.translate(
          offset: const Offset(4.5, -4.5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white.withOpacity(0.6),
            ),
            width: 130,
            height: 150,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          width: 140,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.time,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 72,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
