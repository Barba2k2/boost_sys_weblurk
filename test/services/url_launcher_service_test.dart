import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:process_run/process_run.dart';
import 'package:boost_sys_weblurk/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/core/services/url_launcher_service.dart';

class MockAppLogger extends Mock implements AppLogger {}

class MockShell extends Mock implements Shell {}

void registerFallbacks() {
  registerFallbackValue(<String, String>{});
}

void main() {
  group(
    'UrlLauncherService',
    () {
      late MockAppLogger mockLogger;
      late UrlLauncherService urlLauncherService;
      late MockShell mockShell;

      setUp(() {
        mockLogger = MockAppLogger();
        mockShell = MockShell();
        registerFallbacks();
        urlLauncherService = UrlLauncherService(
          logger: mockLogger,
          shell: mockShell,
        );
      });

      test(
        'launchURL logs error if URL is invalid',
        () async {
          const invalidUrl = 'invalid-url';

          await urlLauncherService.launchURL(invalidUrl);

          verify(
            () => mockLogger.error(
              'URL inválida ou maliciosa detectada: $invalidUrl',
            ),
          ).called(1);
        },
      );

      test(
        'launchURL opens URL if valid',
        () async {
          const validUrl = 'https://twitch.tv/BoostTeam_';
          when(() => mockShell.run(any())).thenAnswer((_) async => []);

          await urlLauncherService.launchURL(validUrl);

          final captured = verify(() => mockShell.run(captureAny())).captured;
          expect(captured.length, 1);
          expect(captured.first, contains(validUrl));
        },
      );
    },
  );
}
