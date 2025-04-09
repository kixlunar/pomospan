import 'package:flutter/material.dart';
import 'dart:async';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pomospan/floating_nav_bar.dart';
import 'database.dart';

Map<String, dynamic> data = {};
const int workDuration = 25 * 60; // 25 minutes in seconds
const int breakDuration = 5 * 60; // 5 minutes in seconds
int timeLeft = workDuration;
bool isWorking = true;
bool isRunning = false;
Timer? timer;

void main() {
  loadDB().then((onValue) {
    data = onValue;
    saveDB(data);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// Main screen with navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const MyHomePage(),
    const ChartPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Navigation bar at the top
          Container(
            constraints: const BoxConstraints(
              minHeight: 40,
            ),
            margin: EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: AdaptiveIconButton(
                        color: _selectedIndex == 0
                            ? Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                            : Colors.black,
                        icon: Icons.home_rounded,
                        onPressed: () {
                          _onItemTapped(0);
                        }),
                  ),
                  Expanded(
                    child: AdaptiveIconButton(
                      color: _selectedIndex == 1
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                          : Colors.black,
                      icon: Icons.pie_chart_rounded,
                      onPressed: () {
                        _onItemTapped(1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Timer Page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    if (isRunning) {
      pauseTimer();
      startTimer();
    }
  }

  void startTimer() {
    if (!isRunning) {
      isRunning = true;
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(
            () {
              if (timeLeft > 0) {
                timeLeft--;
              } else {
                if (data.isNotEmpty) {
                  if (DateTime.parse(data.keys.last).day ==
                      DateTime.now().day) {
                    // checks if previous entry was on same day
                    data[data.keys.last] += workDuration;
                  } else {
                    // new entry created
                    data[DateTime.now().toString()] = workDuration;
                  }
                } else {
                  data[DateTime.now().toString()] = workDuration;
                }

                saveDB(data);
                isWorking = !isWorking;
                timeLeft = isWorking ? workDuration : breakDuration;
              }
            },
          );
        },
      );
    }
  }

  void pauseTimer() {
    if (isRunning) {
      timer?.cancel();
      isRunning = false;
      setState(() {});
    }
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      if (!isWorking) {
        timeLeft = breakDuration;
      } else {
        timeLeft = workDuration;
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isWorking ? 'Work Time' : 'Break Time',
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(height: 20),
          Text(
            formatTime(timeLeft),
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AdaptiveIconButton(
                color: Colors.transparent,
                onPressed: isRunning ? pauseTimer : startTimer,
                icon:
                    isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              const SizedBox(width: 20),
              AdaptiveIconButton(
                color: Colors.transparent,
                onPressed: resetTimer,
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Chart Page
class ChartPage extends StatefulWidget {
  const ChartPage({super.key});
  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChartPage oldWidget) {
    loadDB().then((onValue) {
      data = onValue;
    });
    super.didUpdateWidget(oldWidget);
  }

  String intMonthToString(int monthNumber) {
    const monthNames = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];

    if (monthNumber < 1 || monthNumber > 12) {
      throw ArgumentError('Month number must be between 1 and 12');
    }

    return monthNames[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      // Initialize category axis

      primaryXAxis: CategoryAxis(),
      series: <LineSeries<Entry, dynamic>>[
        LineSeries<Entry, dynamic>(
            markerSettings: MarkerSettings(isVisible: true),
            dataLabelMapper: (datum, index) => (datum.timeSpent.toString()),
            // Bind data source
            dataSource: data.entries
                .map((e) => Entry(DateTime.parse(e.key), e.value))
                .toList(),
            xValueMapper: (entries, _) =>
                ('${entries.time.day.toString().padLeft(2, '0')}-${intMonthToString(entries.time.month)}-${entries.time.year.toString().substring(2, 4)}'),
            yValueMapper: (entries, _) => entries.timeSpent)
      ],
    );
  }
}

class Entry {
  Entry(this.time, this.timeSpent);
  final DateTime time;
  final int timeSpent;
}
