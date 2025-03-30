import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_test/modular_test.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/login/login_page.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/login/login_controller.dart';
import 'package:boost_sys_weblurk/app/service/user/user_service.dart';
import 'package:boost_sys_weblurk/app/core/local_storage/local_storage.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/app/core/helpers/constants.dart';

class MockUserService extends Mock implements UserService {}

class MockLocalStorage extends Mock implements LocalStorage {}

class MockAppLogger extends Mock implements AppLogger {}

class MockModularNavigate extends Mock implements IModularNavigator {}

class LogCapture {
  final List<String> messages = [];
  final List<Object> errors = [];

  void captureError(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    messages.add(message.toString());
    if (error != null) errors.add(error);
    debugPrint('Error logged: $message, $error');
  }
}

class TestModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.instance<UserService>(MockUserService()),
        Bind.instance<LocalStorage>(MockLocalStorage()),
        Bind.instance<AppLogger>(MockAppLogger()),
        Bind.factory<LoginController>(
          (i) => LoginController(
            userService: i.get<UserService>(),
            localStorage: i.get<LocalStorage>(),
            logger: i.get<AppLogger>(),
          ),
        ),
      ];
}

void main() {
  late MockUserService mockUserService;
  late MockLocalStorage mockLocalStorage;
  late MockAppLogger mockAppLogger;
  late MockModularNavigate mockModularNavigate;
  late LogCapture logCapture;

  setUpAll(
    () {
      TestWidgetsFlutterBinding.ensureInitialized();
      registerFallbackValue('');
    },
  );

  setUp(
    () {
      initModule(TestModule());

      mockUserService = Modular.get<UserService>() as MockUserService;
      mockLocalStorage = Modular.get<LocalStorage>() as MockLocalStorage;
      mockAppLogger = Modular.get<AppLogger>() as MockAppLogger;
      mockModularNavigate = MockModularNavigate();
      logCapture = LogCapture();

      Modular.navigatorDelegate = mockModularNavigate;

      when(
        () => mockUserService.login('testuser', 'password123'),
      ).thenAnswer(
        (_) async => {},
      );
      when(
        () => mockUserService.getToken(),
      ).thenAnswer(
        (_) async => 'valid_token',
      );
      when(
        () => mockLocalStorage.read<String>(
          Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        ),
      ).thenAnswer(
        (_) async => '{"id":1,"nickname":"test"}',
      );

      when(
        () => mockUserService.login(
          'testuser',
          'wrongpassword',
        ),
      ).thenThrow(
        Exception('Invalid credentials'),
      );

      when(
        () => mockAppLogger.error(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (invocation) {
          final message = invocation.positionalArguments[0];
          final error =
              invocation.positionalArguments.length > 1 ? invocation.positionalArguments[1] : null;
          final stack =
              invocation.positionalArguments.length > 2 ? invocation.positionalArguments[2] : null;
          logCapture.captureError(
            message,
            error,
            stack,
          );
        },
      );
    },
  );

  group(
    'Login Flow',
    () {
      testWidgets(
        'complete login flow with success',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: LoginPage(),
            ),
          );

          expect(find.text('Usuário'), findsOneWidget);
          expect(find.text('Password'), findsOneWidget);

          await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
          await tester.enterText(find.byType(TextFormField).at(1), 'password123');

          await tester.tap(
            find.text('Entrar'),
          );
          await tester.pumpAndSettle();

          verify(
            () => mockUserService.login('testuser', 'password123'),
          ).called(1);
          verify(
            () => mockModularNavigate.navigate('/home/'),
          ).called(1);
        },
      );

      testWidgets(
        'login with invalid credentials shows error',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: LoginPage(),
            ),
          );

          await tester.enterText(
            find.byType(TextFormField).at(0),
            'testuser',
          );
          await tester.enterText(
            find.byType(TextFormField).at(1),
            'wrongpassword',
          );

          await tester.tap(
            find.text('Entrar'),
          );
          await tester.pumpAndSettle();

          verify(
            () => mockUserService.login('testuser', 'wrongpassword'),
          ).called(1);
          verifyNever(
            () => mockModularNavigate.navigate('/home/'),
          );

          verify(
            () => mockAppLogger.error(
              any(),
              any(),
              any(),
            ),
          ).called(2);

          debugPrint('Número de erros capturados: ${logCapture.messages.length}');
          for (int i = 0; i < logCapture.messages.length; i++) {
            debugPrint('Erro #${i + 1}: ${logCapture.messages[i]}');
            if (i < logCapture.errors.length) {
              debugPrint('Exceção: ${logCapture.errors[i]}');
            }
          }
        },
      );
    },
  );
}
