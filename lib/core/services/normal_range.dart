import '../../models/lab_test.dart';

/// Interprets lab results: counts abnormal parameters and generates a
/// plain-English summary plus advice based on which values are out of range.
class NormalRangeService {
  const NormalRangeService();

  /// Overall status for a set of results.
  LabSummary summarise(List<LabTest> tests) {
    var total = 0;
    var normal = 0;
    var low = 0;
    var high = 0;
    var critical = 0;
    final abnormal = <({LabTest test, LabRange range, RangeStatus status})>[];

    for (final test in tests) {
      for (final range in test.parameters) {
        total++;
        final status = RangeStatus.of(range);
        if (status.label == 'Normal') {
          normal++;
        } else if (status.label == 'Low') {
          low++;
        } else if (status.label == 'High') {
          high++;
        } else {
          critical++;
        }
        if (status.label != 'Normal') {
          abnormal.add((test: test, range: range, status: status));
        }
      }
    }

    return LabSummary(
      totalParameters: total,
      normalCount: normal,
      lowCount: low,
      highCount: high,
      criticalCount: critical,
      abnormal: abnormal,
    );
  }

  /// Short, human summary used under the report header.
  String headline(LabSummary s) {
    if (s.totalParameters == 0) return 'No parameters available';
    if (s.criticalCount > 0) {
      return '${s.criticalCount} critical value(s) need immediate attention';
    }
    if (s.lowCount + s.highCount == 0) {
      return 'All ${s.totalParameters} parameters are within the normal range';
    }
    return '${s.lowCount + s.highCount} of ${s.totalParameters} parameters '
        'are outside the normal range';
  }

  /// Advice derived from the abnormal values.
  List<String> advice(LabSummary s) {
    final advice = <String>[];
    final byParameter = <String, ({RangeStatus status, double value})>{};

    for (final a in s.abnormal) {
      byParameter[a.range.parameter] = (status: a.status, value: a.range.value);
    }

    if (byParameter.containsKey('Fasting Glucose')) {
      final v = byParameter['Fasting Glucose']!.value;
      advice.add(v >= 126
          ? 'Fasting glucose of $v mg/dL is in the diabetes range. A doctor needs '
              'to confirm this and start a treatment plan.'
          : v > 100
              ? 'Fasting glucose is above normal ($v mg/dL). Book an HbA1c test to '
                  'confirm whether you are pre-diabetic.'
              : 'Fasting glucose is low. Eat a carbohydrate-rich snack and recheck after an hour.');
    }
    if (byParameter.containsKey('HbA1c')) {
      final v = byParameter['HbA1c']!.value;
      advice.add(v >= 6.5
          ? 'HbA1c of $v% is in the diabetes range (6.5% or above). Please see a '
              'doctor promptly to confirm the result and begin treatment.'
          : v > 5.6
              ? 'HbA1c of $v% indicates impaired blood sugar control (pre-diabetes). '
                  'Diet changes and 150 minutes of weekly exercise can bring this down.'
              : 'HbA1c of $v% is below the normal range. Review your diet with a doctor.');
    }
    if (byParameter.containsKey('LDL Cholesterol')) {
      final v = byParameter['LDL Cholesterol']!.value;
      advice.add(v > 100
          ? 'LDL ("bad" cholesterol) is $v mg/dL. Reduce saturated fats, add '
              'oats and legumes, and discuss a statin with your doctor.'
          : 'LDL is $v mg/dL, which is favourable for cardiovascular health.');
    }
    if (byParameter.containsKey('HDL Cholesterol')) {
      final v = byParameter['HDL Cholesterol']!.value;
      if (v < 40) {
        advice.add('HDL ("good" cholesterol) is low at $v mg/dL. Regular aerobic '
            'exercise is the most effective way to raise it.');
      }
    }
    if (byParameter.containsKey('Triglycerides')) {
      final v = byParameter['Triglycerides']!.value;
      advice.add(v > 150
          ? 'Triglycerides are $v mg/dL. Cut sugar, refined carbs and alcohol.'
          : 'Triglycerides are within range.');
    }
    if (byParameter.containsKey('TSH (Ultrasensitive)')) {
      final v = byParameter['TSH (Ultrasensitive)']!.value;
      final status = byParameter['TSH (Ultrasensitive)']!.status;
      advice.add(status.label == 'High'
          ? 'TSH of $v µIU/mL suggests an underactive thyroid. Thyroid medicines '
              'like levothyroxine may help once prescribed.'
          : 'TSH of $v µIU/mL suggests a hyperactive thyroid. See an endocrinologist.');
    }
    if (byParameter.containsKey('SGPT (ALT)')) {
      final v = byParameter['SGPT (ALT)']!.value;
      advice.add('Liver enzymes are raised (ALT $v U/L). Avoid alcohol entirely, '
          'reduce oily food and review any medicines you are taking.');
    }
    if (byParameter.containsKey('25-Hydroxy Vitamin D')) {
      final v = byParameter['25-Hydroxy Vitamin D']!.value;
      advice.add(v < 30
          ? 'Vitamin D is deficient at $v ng/mL. A doctor can prescribe a '
              'correction course, plus 10 minutes of daily sunlight.'
          : 'Vitamin D level of $v ng/mL is healthy.');
    }
    if (byParameter.containsKey('WBC Count')) {
      final v = byParameter['WBC Count']!.value;
      advice.add('White blood cell count is $v/µL. A raised count often means the '
          'body is fighting an infection — your doctor may repeat this test.');
    }
    if (byParameter.containsKey('Haemoglobin')) {
      final v = byParameter['Haemoglobin']!.value;
      advice.add(v < 13
          ? 'Haemoglobin of $v g/dL indicates anaemia. Increase iron-rich foods '
              'and ask your doctor about iron supplementation.'
          : 'Haemoglobin of $v g/dL is normal.');
    }

    if (advice.isEmpty) {
      advice.add('All tested parameters look healthy. Keep up your current diet '
          'and exercise routine, and repeat this screening once a year.');
    }
    advice.add('Always discuss this report with a qualified doctor before starting '
        'any treatment.');
    return advice;
  }
}

/// Aggregated result of interpreting a set of tests.
class LabSummary {
  const LabSummary({
    required this.totalParameters,
    required this.normalCount,
    required this.lowCount,
    required this.highCount,
    required this.criticalCount,
    required this.abnormal,
  });

  final int totalParameters;
  final int normalCount;
  final int lowCount;
  final int highCount;
  final int criticalCount;
  final List<({LabTest test, LabRange range, RangeStatus status})> abnormal;

  bool get isAllNormal => totalParameters > 0 && abnormal.isEmpty;
  int get abnormalCount => lowCount + highCount + criticalCount;
}
