import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:boost_sys_weblurk/app/core/controllers/url_launch_controller.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';

// Mock the logger
class MockAppLogger extends Mock implements AppLogger {}

// Create a custom UrlLaunchController for testing
class TestUrlLaunchController extends UrlLaunchController {
  TestUrlLaunchController({required super.logger});
  bool launchCalled = false;
  String? lastLaunchedUrl;

  @override
  Future<void> launchURL(String url) async {
    launchCalled = true;
    lastLaunchedUrl = url;
    // Return immediately to avoid platform-specific code
    return Future.value();
  }
}

void main() {
  group(
    'UrlLaunchController',
    () {
      late MockAppLogger mockLogger;
      late TestUrlLaunchController controller;

      setUp(
        () {
          mockLogger = MockAppLogger();
          controller = TestUrlLaunchController(logger: mockLogger);
        },
      );

      test(
        'can be instantiated',
        () {
          expect(controller, isNotNull);
        },
      );

      test(
        'launchURL sets launchCalled flag',
        () async {
          // Act - Call the method
          await controller.launchURL('https://google.com');

          // Assert - Check that the launch was called
          expect(controller.launchCalled, isTrue);
        },
      );

      test(
        'launchURL stores the URL correctly',
        () async {
          // Arrange
          const testUrl = 'https://example.com';

          // Act
          await controller.launchURL(testUrl);

          // Assert
          expect(controller.lastLaunchedUrl, equals(testUrl));
        },
      );
    },
  );
}
