import 'dart:convert';

import 'package:experiment_app/common/experiment_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ImageChoice { a, b }

class ExperimentPage extends StatefulWidget {
  const ExperimentPage({super.key});

  @override
  ExperimentPageState createState() => ExperimentPageState();
}

class ExperimentPageState extends State<ExperimentPage> {
  List<List<String>> imagePairs = [];

  @override
  void initState() {
    _loadImagePairs();
    super.initState();
  }

  final Map<String, String> choices = {};

  int currentIndex = 0;

  bool showMessage = false;

  bool isChoiceMade = false;

  bool experimentDone = false;

  void handleChoice(ImageChoice choice) {
    if (isChoiceMade || experimentDone) return;
    choices['$currentIndex'] = choice.name;

    if (currentIndex == imagePairs.length - 1) {
      experimentDone = true;
      ExperimentData.instance.choices = choices;
      Navigator.of(context).pushNamed('/summary');
      return;
    }

    setState(() {
      isChoiceMade = true;
      showMessage = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (currentIndex < imagePairs.length - 1) {
          currentIndex++;
        }
        isChoiceMade = false;
        showMessage = false;
      });
    });
  }

  Future<void> _loadImagePairs() async {
    const assetPath = 'assets/';
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestJson);

    List<String> allAssets = manifestMap.keys
        .where((key) =>
            key.startsWith(assetPath) &&
            (key.contains('blended_run_') ||
                key.contains('blended_inverse_run_')))
        .toList();

    List<String> runImages = [];
    List<String> inverseRunImages = [];

    for (String asset in allAssets) {
      if (asset.contains('blended_run_')) {
        runImages.add(asset);
      } else if (asset.contains('blended_inverse_run_')) {
        inverseRunImages.add(asset);
      }
    }

    runImages.sort((a, b) {
      // Extract the numeric part from the filename
      final RegExp numericRegex = RegExp(r'blended_run_(\d+)');
      final aMatch = numericRegex.firstMatch(a);
      final bMatch = numericRegex.firstMatch(b);

      if (aMatch != null && bMatch != null) {
        final aIndex = int.parse(aMatch.group(1)!);
        final bIndex = int.parse(bMatch.group(1)!);
        return aIndex.compareTo(bIndex);
      }
      return a.compareTo(b);
    });

    inverseRunImages.sort((a, b) {
      final RegExp numericRegex = RegExp(r'blended_inverse_run_(\d+)');
      final aMatch = numericRegex.firstMatch(a);
      final bMatch = numericRegex.firstMatch(b);

      if (aMatch != null && bMatch != null) {
        final aIndex = int.parse(aMatch.group(1)!);
        final bIndex = int.parse(bMatch.group(1)!);
        return aIndex.compareTo(bIndex);
      }
      return a.compareTo(b);
    });

    List<List<String>> pairs = [];
    for (int i = 0; i < runImages.length; i++) {
      String leftImagePath = runImages[i];
      String rightImagePath = inverseRunImages[i];

      pairs.add([leftImagePath, rightImagePath]);
    }

    List<Future<void>> precacheFutures = [];
    for (List<String> pair in pairs) {
      for (String imagePath in pair) {
        precacheFutures.add(precacheImage(AssetImage(imagePath), context));
      }
    }

    await Future.wait(precacheFutures);

    setState(() {
      imagePairs = pairs;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imagePairs.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 32),
              Text('Ładowanie danych, proszę czekać...')
            ],
          ),
        ),
      );
    }

    final currentPair = imagePairs[currentIndex];

    return Scaffold(
      body: Center(
        child: Focus(
          autofocus: true,
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              handleChoice(ImageChoice.a);

              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              handleChoice(ImageChoice.b);
              return KeyEventResult.handled;
            }

            return KeyEventResult.ignored;
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showMessage)
                  const Text(
                    "+",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                if (!showMessage)
                  Column(
                    children: [
                      const Text(
                        "Wybierz obrazek bardziej przedstawiający osobę chorą.",
                        style: TextStyle(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(currentPair[0], width: 300, height: 300),
                          const SizedBox(width: 60),
                          Image.asset(currentPair[1], width: 300, height: 300),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
