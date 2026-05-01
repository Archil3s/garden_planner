import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:garden_planner/main.dart';

void main() {
  testWidgets('Garden Planner loads', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const GardenPlannerApp());
    await tester.pump();

    expect(find.text('Garden Planner'), findsWidgets);
  });
}
