import 'package:experiment_app/pages/experiment_page.dart';
import 'package:experiment_app/pages/start_page.dart';
import 'package:experiment_app/pages/summary_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reversed Correlation Experiment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartPage(),
        '/experiment': (context) => const ExperimentPage(),
        '/summary': (context) => const SummaryPage()
      },
    );
  }
}
