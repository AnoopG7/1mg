import 'package:flutter/foundation.dart';

import '../core/services/symptom_engine.dart';
import '../data/mock_symptoms.dart';
import '../models/symptom.dart';

enum CheckerStep { profile, symptoms, questions, result }

/// Drives the multi-step symptom checker as a small state machine.
class SymptomProvider extends ChangeNotifier {
  SymptomProvider({SymptomEngine? engine})
      : _engine = engine ?? const SymptomEngine();

  final SymptomEngine _engine;

  CheckerStep _step = CheckerStep.profile;
  CheckerStep get step => _step;

  // ---- profile
  String _ageBand = MockSymptoms.ageBands[2];
  String _gender = MockSymptoms.genders[0];
  String get ageBand => _ageBand;
  String get gender => _gender;

  // ---- symptoms
  final Set<String> _selected = {};
  Set<String> get selected => Set.unmodifiable(_selected);
  int get selectedCount => _selected.length;

  // ---- questions
  final Map<String, String> _answers = {};
  Map<String, String> get answers => Map.unmodifiable(_answers);
  String? answerFor(String q) => _answers[q];

  int get questionIndex => _questionStep;
  int _questionStep = 0;

  /// The question currently being asked, or null when finished.
  SymptomQuestion? get currentQuestion =>
      _questionStep < MockSymptoms.questions.length
          ? MockSymptoms.questions[_questionStep]
          : null;

  int get totalQuestions => MockSymptoms.questions.length;

  // ---- result
  Assessment? _assessment;
  Assessment? get assessment => _assessment;
  bool get isAnalysing => _isAnalysing;
  bool _isAnalysing = false;

  void setAgeBand(String value) {
    _ageBand = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void toggleSymptom(String id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
    notifyListeners();
  }

  void goToSymptoms() {
    _step = CheckerStep.symptoms;
    notifyListeners();
  }

  void goToQuestions() {
    if (_selected.isEmpty) return;
    _step = CheckerStep.questions;
    _questionStep = 0;
    notifyListeners();
  }

  /// Saves the current answer and advances to the next question.
  ///
  /// When the last question is answered the flow moves to [CheckerStep.result]
  /// and the engine is kicked off automatically, so callers never have to
  /// remember to trigger analysis themselves.
  void answer(SymptomQuestion question, String option) {
    _answers[question.id] = option;
    _questionStep++;
    if (_questionStep >= MockSymptoms.questions.length) {
      _step = CheckerStep.result;
      notifyListeners();
      analyse();
      return;
    }
    notifyListeners();
  }

  /// Runs the engine with a short delay so the UI can show an analysis state.
  Future<void> analyse() async {
    _isAnalysing = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    _assessment = _engine.analyse(
      symptomIds: _selected.toList(),
      answers: Map.of(_answers),
      ageBand: _ageBand,
      gender: _gender,
    );
    _isAnalysing = false;
    notifyListeners();
  }

  void reset() {
    _step = CheckerStep.profile;
    _selected.clear();
    _answers.clear();
    _questionStep = 0;
    _assessment = null;
    _isAnalysing = false;
    notifyListeners();
  }

  void restartKeepingSymptoms() {
    _step = CheckerStep.questions;
    _questionStep = 0;
    _assessment = null;
    notifyListeners();
  }
}
