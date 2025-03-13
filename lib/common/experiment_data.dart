class ExperimentData {
  ExperimentData._privateConstructor();

  static final ExperimentData _instance = ExperimentData._privateConstructor();

  static ExperimentData get instance => _instance;

  DateTime experimentDate = DateTime.now();
  Map<String, String> choices = {};
}
