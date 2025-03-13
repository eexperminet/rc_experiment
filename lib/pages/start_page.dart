import 'package:experiment_app/common/experiment_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StartPage extends HookWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final experimentData = ExperimentData.instance;
      experimentData.experimentDate = DateTime.now();
      return null;
    }, []);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Dziękuję za udział w badaniu.\nZa chwilę poprosimy Cię o ocenienie serii obrazów twarzy\npod względem określonej cechy.\nJeśli jesteś gotowy, przejdź do następnego kroku.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Zrezygnuj"),
                  ),
                  const SizedBox(width: 40),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pushNamed('/experiment');
                    },
                    child: const Text("Dalej"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
