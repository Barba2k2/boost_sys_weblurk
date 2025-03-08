import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:boost_sys_weblurk/app/core/controllers/url_launch_controller.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late UrlLaunchController urlLaunchController;
  late MockAppLogger mockLogger;

  setUp(() {
    mockLogger = MockAppLogger();
    urlLaunchController = UrlLaunchController(
      logger: mockLogger,
    );
  });

  group('UrlLaunchController', () {
    test('launchURL logs error when platform is not supported', () async {
      // Arrange - configurado no setUp

      // Act - Em ambiente de teste, não teremos plataforma Windows/Mac/Linux
      try {
        await urlLaunchController.launchURL('https://google.com');
      } catch (_) {}

      // Assert - verificar se o erro foi logado corretamente
      verify(mockLogger.error(argThat(contains('Error launching URL')), any)).called(1);
    });
  });
}
