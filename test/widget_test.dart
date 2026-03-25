// Basic Flutter widget test. App uses SkillBridgeApp and GoRouter; full run requires Firebase/DI.
import 'package:flutter_test/flutter_test.dart';
import 'package:skillbridge/features/assessment/domain/services/scoring_service.dart';

void main() {
  testWidgets('ScoringService normaliseScore smoke test', (WidgetTester tester) async {
    expect(ScoringService.normaliseScore(5, 10), 50);
    expect(ScoringService.assignTier(75), 'Proficient');
  });
}
