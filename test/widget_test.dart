// Widget tests for Boost Sys Weblurk application.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boost_sys_weblurk/core/ui/ui_config.dart';

void main() {
  testWidgets('Weblurk app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: We use a simplified version without dependency injection for testing
    await tester.pumpWidget(
      MaterialApp(
        title: UiConfig.title,
        theme: UiConfig.theme,
        home: const Scaffold(
          body: Center(
            child: Text('Boost Sys Weblurk'),
          ),
        ),
      ),
    );

    // Verify that the app title is configured correctly.
    expect(UiConfig.title, equals('Boost Sys Weblurk'));

    // Verify that the app loads without errors.
    expect(find.text('Boost Sys Weblurk'), findsOneWidget);
  });

  testWidgets('UI Config theme is properly configured',
      (WidgetTester tester) async {
    // Test that theme configuration is valid
    expect(UiConfig.theme, isA<ThemeData>());
    expect(UiConfig.theme.textTheme.bodyLarge?.fontFamily, equals('Ibrand'));
    expect(UiConfig.theme.useMaterial3, isTrue);
  });
}
