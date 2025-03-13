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

  void handleChoice(ImageChoice choice) {
    if (isChoiceMade) return;
    choices['$currentIndex'] = choice.name;

    if (currentIndex == imagePairs.length - 1) {
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

    allAssets.sort();

    List<String> runImages = [];
    List<String> inverseRunImages = [];

    for (String asset in allAssets) {
      if (asset.contains('blended_run_')) {
        runImages.add(asset);
      } else if (asset.contains('blended_inverse_run_')) {
        inverseRunImages.add(asset);
      }
    }

    List<List<String>> pairs = [];
    for (int i = 0; i < runImages.length; i++) {
      String leftImagePath = runImages[i];
      String rightImagePath = inverseRunImages[i];

      pairs.add([leftImagePath, rightImagePath]);
    }

    setState(() {
      imagePairs = pairs;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imagePairs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(currentPair[0], width: 300, height: 300),
                      const SizedBox(width: 60),
                      Image.asset(currentPair[1], width: 300, height: 300),
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
