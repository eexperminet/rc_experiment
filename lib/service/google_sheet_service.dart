import 'dart:convert';

import 'package:experiment_app/common/cred.dart';
import 'package:experiment_app/common/experiment_data.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:intl/intl.dart';

const spreadsheetId = '1uEnLgHA6PjXny1aiS9oF0gdFxjyIHJPJUomT1yyMfok';

class GoogleSheetsService {
  static const _scopes = [SheetsApi.spreadsheetsScope];

  Future<SheetsApi?> _getSheetsApi() async {
    final credentials = base64Decode(cred);
    String jsonString = utf8.decode(credentials);
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final accountCredentials = auth.ServiceAccountCredentials.fromJson(jsonMap);

    final client = await clientViaServiceAccount(accountCredentials, _scopes);
    return SheetsApi(client);
  }

  Future<void> storeExperimentData() async {
    final experimentDate = ExperimentData.instance.experimentDate;
    final choices = ExperimentData.instance.choices;

    final sheetsApi = await _getSheetsApi();
    if (sheetsApi == null) return;

    final formattedDate =
        DateFormat('yyyy-MM-dd hh:mm:ss').format(experimentDate);

    // Step 1: Create a new sheet named after the formatted date
    await sheetsApi.spreadsheets.batchUpdate(
      BatchUpdateSpreadsheetRequest(requests: [
        Request(
            addSheet: AddSheetRequest(
                properties: SheetProperties(title: formattedDate)))
      ]),
      spreadsheetId,
    );

    // Step 2: Prepare values where keys are in Column A and values in Column B
    final values =
        choices.entries.map((entry) => [entry.key, entry.value]).toList();

    // Step 3: Define the range for insertion (starting from A1)
    final range = '$formattedDate!A1:B${values.length}';

    // Step 4: Append the data to the new sheet
    final valueRange = ValueRange(values: values);

    await sheetsApi.spreadsheets.values.update(
      valueRange,
      spreadsheetId,
      range,
      valueInputOption: 'RAW',
    );
  }
}
