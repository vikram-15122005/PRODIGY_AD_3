import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clock Stopwatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  Timer? timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  DateTime _currentTime = DateTime.now();

  // Starts the timer
  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsed += Duration(milliseconds: 100);
        _currentTime = DateTime.now(); // Update the clock hands
      });
    });
  }

  // Stops the timer
  void _stopTimer() {
    setState(() {
      _isRunning = false;
    });
    timer?.cancel();
  }

  // Resets the timer
  void _resetTimer() {
    _stopTimer();
    setState(() {
      _elapsed = Duration.zero;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = (duration.inMilliseconds % 1000) ~/ 100;
    return "$hours:$minutes:$seconds.$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clock Stopwatch'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Analog Clock
            SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: ClockPainter(currentTime: _currentTime),
              ),
            ),
            SizedBox(height: 50.0),
            // Digital Stopwatch Display
            Text(
              _formatTime(_elapsed),
              style: TextStyle(fontSize: 48.0),
            ),
            SizedBox(height: 24.0),
            // Stopwatch Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  child: Text(_isRunning ? 'Stop' : 'Start'),
                ),
                SizedBox(width: 12.0),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime currentTime;

  ClockPainter({required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    // Draw the clock background
    Paint circlePaint = Paint()..color = Colors.grey[300]!;
    canvas.drawCircle(center, radius, circlePaint);

    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw clock ticks (hours)
    Paint tickPaint = Paint()..color = Colors.black;
    for (int i = 0; i < 12; i++) {
      double tickLength = 10.0;
      double angle = (i * 30) * pi / 180;
      double x1 = radius + radius * cos(angle);
      double y1 = radius + radius * sin(angle);
      double x2 = radius + (radius - tickLength) * cos(angle);
      double y2 = radius + (radius - tickLength) * sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Draw hour hand
    double hourAngle = ((currentTime.hour % 12) + currentTime.minute / 60) * 30 * pi / 180;
    double hourHandLength = radius * 0.5;
    Paint hourHandPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + hourHandLength * cos(hourAngle), center.dy + hourHandLength * sin(hourAngle)),
      hourHandPaint,
    );

    // Draw minute hand
    double minuteAngle = (currentTime.minute + currentTime.second / 60) * 6 * pi / 180;
    double minuteHandLength = radius * 0.7;
    Paint minuteHandPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + minuteHandLength * cos(minuteAngle), center.dy + minuteHandLength * sin(minuteAngle)),
      minuteHandPaint,
    );

    // Draw second hand
    double secondAngle = currentTime.second * 6 * pi / 180;
    double secondHandLength = radius * 0.9;
    Paint secondHandPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + secondHandLength * cos(secondAngle), center.dy + secondHandLength * sin(secondAngle)),
      secondHandPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // To repaint the clock hands
  }
}
