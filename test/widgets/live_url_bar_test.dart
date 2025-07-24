import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/core/ui/widgets/live_url_bar.dart';

void main() {
  group(
    'LiveUrlBar',
    () {
      testWidgets(
        'displays provided channel URL',
        (WidgetTester tester) async {
          // Arrange
          const testChannel = 'https://twitch.tv/testchannel';

          // Act
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: LiveUrlBar(currentChannel: testChannel),
              ),
            ),
          );

          // Assert
          expect(find.text(testChannel), findsOneWidget);
        },
      );

      testWidgets(
        'displays default URL when channel is null',
        (WidgetTester tester) async {
          // Act
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: LiveUrlBar(currentChannel: null),
              ),
            ),
          );

          // Assert
          expect(find.text('https://www.twitch.tv/BootTeam_'), findsOneWidget);
        },
      );

      testWidgets(
        'has correct background color',
        (WidgetTester tester) async {
          // Act
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: LiveUrlBar(currentChannel: 'https://twitch.tv/test'),
              ),
            ),
          );

          // Assert
          final container = tester.widget<Container>(
            find.byType(Container),
          );
          expect(
            container.color,
            const Color(0xFF6750A4).withValues(alpha: 0.7), // 0.7 * 255 = 178
          );
        },
      );

      testWidgets(
        'has correct height',
        (WidgetTester tester) async {
          // Act
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: LiveUrlBar(currentChannel: 'https://twitch.tv/test'),
              ),
            ),
          );

          // Assert
          final container = tester.widget<Container>(
            find.byType(Container),
          );
          expect(container.constraints?.constrainHeight(), 30);
        },
      );
    },
  );
}
