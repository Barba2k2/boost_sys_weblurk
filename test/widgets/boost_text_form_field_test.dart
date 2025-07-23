import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/core/ui/widgets/boost_text_form_field.dart';

void main() {
  group('BoostTextFormField', () {
    testWidgets('renders correctly with label', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoostTextFormField(
              controller: controller,
              label: 'Test Label',
              validator: (value) => null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('accepts input text', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoostTextFormField(
              controller: controller,
              label: 'Test Label',
              validator: (value) => null,
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'Hello World');
      await tester.pump();

      // Assert
      expect(controller.text, 'Hello World');
    });

    testWidgets('shows validation error', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              autovalidateMode: AutovalidateMode.always,
              child: BoostTextFormField(
                controller: controller,
                label: 'Test Label',
                validator: (value) => 'Error message',
              ),
            ),
          ),
        ),
      );

      // Wait for validation
      await tester.pump();

      // Assert
      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoostTextFormField(
              controller: controller,
              label: 'Password',
              validator: (value) => null,
              obscureText: true,
            ),
          ),
        ),
      );

      // Initial state - password hidden, visibility icon shown
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

      // Tap the visibility icon
      await tester.tap(
        find.byIcon(Icons.visibility_rounded),
      );
      await tester.pump();

      // After tap - password visible, visibility_off icon shown
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
    });
  });
}
