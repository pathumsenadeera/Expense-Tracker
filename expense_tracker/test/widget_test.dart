import 'package:expense_tracker/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/firebase_options.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('App smoke test — renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    // Allow async frame to settle
    await tester.pump(Duration.zero);
    // Verify the MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
