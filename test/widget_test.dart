import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_ai/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaestroAIApp());

    // Verify that the splash screen is shown
    expect(find.text('Maestro'), findsOneWidget);
    expect(find.text('تحكم في هاتفك بصوتك'), findsOneWidget);
  });

  testWidgets('Splash screen shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const MaestroAIApp());

    // Verify that loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('App has correct theme', (WidgetTester tester) async {
    await tester.pumpWidget(const MaestroAIApp());

    // Get the MaterialApp
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    
    // Verify dark theme is used
    expect(materialApp.theme?.brightness, equals(Brightness.dark));
  });
}
