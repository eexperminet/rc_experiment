import 'package:experiment_app/pages/experiment_page.dart';
import 'package:experiment_app/pages/start_page.dart';
import 'package:experiment_app/pages/summary_page.dart';
import 'package:flutter/material.dart';

// import 'dart:async';
// import 'dart:js' as js;

// void simulateArrowPress(String key) {
//   js.context.callMethod('eval', [
//     '''
//     document.dispatchEvent(new KeyboardEvent('keydown', {'key': '$key'}));
//     document.dispatchEvent(new KeyboardEvent('keyup', {'key': '$key'}));
//     '''
//   ]);
// }

void main() {
  runApp(const MyApp());

  // Timer.periodic(const Duration(seconds: 2), (timer) {
  //   simulateArrowPress("ArrowLeft");
  // });
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
