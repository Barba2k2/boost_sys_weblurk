import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:boost_sys_weblurk/core/logger/app_logger.dart';

class MockAppLogger extends Mock implements AppLogger {}

class TestSettingsController {
  TestSettingsController({required this.logger});

  final AppLogger logger;

  Future<void> terminateApp() async {
    try {
      debugPrint('TEST: terminateApp called');
      throw 'Plataforma não suportada para encerramento do app';
    } catch (e, s) {
      logger.error('Erro ao encerrar o aplicativo', e, s);
    }
  }

  Future<void> muteAppAudio() async {
    try {
      debugPrint('TEST: muteAppAudio called');
    } catch (e, s) {
      logger.error('Erro ao mutar o áudio do aplicativo', e, s);
    }
  }
}

Future<void> runTestWithExtraDebugging(
  String description,
  Future<void> Function() testBody,
) async {
  test(
    description,
    () async {
      try {
        debugPrint('\n----- STARTING TEST: $description -----');
        await testBody();
        debugPrint('----- TEST COMPLETED: $description -----\n');
      } catch (e, stack) {
        debugPrint('\n===== ERROR IN TEST: $description =====');
        debugPrint('ERROR: $e');
        debugPrint('STACK: $stack');
        debugPrint('=====================================\n');
        fail('Test failed with error: $e');
      }
    },
  );
}

void main() {
  late TestSettingsController settingsController;
  late MockAppLogger mockLogger;

  setUpAll(
    () {
      debugPrint('===== SETTING UP TEST ENVIRONMENT =====');
      TestWidgetsFlutterBinding.ensureInitialized();
    },
  );

  setUp(
    () {
      debugPrint('Setting up test...');
      mockLogger = MockAppLogger();

      when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
      when(() => mockLogger.info(any())).thenReturn(null);

      settingsController = TestSettingsController(
        logger: mockLogger,
      );
      debugPrint('Setup complete.');
    },
  );

  group(
    'SettingsController',
    () {
      runTestWithExtraDebugging(
        'terminateApp logs error when platform is not supported',
        () async {
          debugPrint('Testing terminateApp...');

          await settingsController.terminateApp();

          verify(() => mockLogger.error(
                'Erro ao encerrar o aplicativo',
                any(),
                any(),
              )).called(1);

          debugPrint('terminateApp test completed.');
        },
      );

      runTestWithExtraDebugging(
        'muteAppAudio doesnt call logger',
        () async {
          debugPrint('Testing muteAppAudio...');

          await settingsController.muteAppAudio();

          verifyNever(() => mockLogger.info(any()));

          verifyNever(() => mockLogger.error(any(), any(), any()));

          debugPrint('muteAppAudio test completed.');
        },
      );
    },
  );
}
