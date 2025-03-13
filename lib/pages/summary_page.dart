import 'package:experiment_app/service/google_sheet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SummaryPage extends HookWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sendingData = useState(true);

    useEffect(() {
      Future<void>.microtask(() async {
        sendingData.value = true;
        await GoogleSheetsService().storeExperimentData();
        sendingData.value = false;
      });

      return null;
    }, []);

    return Scaffold(
      body: Center(
        child: sendingData.value
            ? const CircularProgressIndicator()
            : const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Dziękuję za udział w badaniu.\nMożesz zamknąć przeglądarkę.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
