import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/app/features/home/presentation/pages/home_page.dart';

void main() {
  group('Home Initialization Tests', () {
    testWidgets('should initialize home page correctly',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Assert
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display home page structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Assert
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle page rendering', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Assert
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
