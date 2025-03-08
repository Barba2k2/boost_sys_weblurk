import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_test/modular_test.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/login/login_page.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/login/login_controller.dart';
import 'package:boost_sys_weblurk/app/service/user/user_service.dart';
import 'package:boost_sys_weblurk/app/core/local_storage/local_storage.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/app/core/helpers/constants.dart';

// Mocks
class MockUserService extends Mock implements UserService {
  @override
  Future<Map<String, dynamic>> login(String nickname, String password) async {
    return super.noSuchMethod(
      Invocation.method(#login, [nickname, password]),
      returnValue: Future.value(<String, dynamic>{}),
    );
  }

  @override
  Future<String?> getToken() async {
    return super.noSuchMethod(
      Invocation.method(#getToken, []),
      returnValue: Future.value(''),
    );
  }
}

class MockLocalStorage extends Mock implements LocalStorage {
  @override
  Future<T?> read<T>(String key) async {
    return super.noSuchMethod(
      Invocation.method(#read, [key], {#T: T}),
      returnValue: Future.value(),
    );
  }
}

class MockAppLogger extends Mock implements AppLogger {
  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    super.noSuchMethod(
      Invocation.method(#error, [message, error, stackTrace]),
    );
  }
}

class MockModularNavigate extends Mock implements IModularNavigator {
  @override
  void navigate(String path, {dynamic arguments}) {
    super.noSuchMethod(
      Invocation.method(#navigate, [path], {#arguments: arguments}),
    );
  }
}

// Test module for dependency injection
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
  late MockModularNavigate mockModularNavigate;

  setUp(
    () {
      // Initialize modular for testing
      initModule(TestModule());

      mockUserService = Modular.get<UserService>() as MockUserService;
      mockLocalStorage = Modular.get<LocalStorage>() as MockLocalStorage;
      mockModularNavigate = MockModularNavigate();

      // Configurar o Modular para testes
      Modular.navigatorDelegate = mockModularNavigate;
    },
  );

  group(
    'Login Flow',
    () {
      testWidgets(
        'complete login flow with success',
        (WidgetTester tester) async {
          // Arrange
          when(mockUserService.login('testuser', 'password123')).thenAnswer(
            (_) async => {},
          );
          when(mockUserService.getToken()).thenAnswer(
            (_) async => 'valid_token',
          );
          when(
            mockLocalStorage.read<String>(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY),
          ).thenAnswer(
            (_) async => '{"id":1,"nickname":"test"}',
          );

          // Act - Renderizar a página de login
          await tester.pumpWidget(
            const MaterialApp(
              home: LoginPage(),
            ),
          );

          // Verificar se os campos de formulário estão presentes
          expect(find.text('Usuário'), findsOneWidget);
          expect(find.text('Password'), findsOneWidget);

          // Preencher os campos
          await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
          await tester.enterText(find.byType(TextFormField).at(1), 'password123');

          // Clicar no botão de login
          await tester.tap(
            find.text('Entrar'),
          );
          await tester.pumpAndSettle();

          // Assert
          verify(mockUserService.login('testuser', 'password123')).called(1);
          verify(mockModularNavigate.navigate('/home/')).called(1);
        },
      );

      testWidgets(
        'login with invalid credentials shows error',
        (WidgetTester tester) async {
          // Arrange
          when(mockUserService.login('testuser', 'wrongpassword'))
              .thenThrow(Exception('Invalid credentials'));

          // Act - Renderizar a página de login
          await tester.pumpWidget(
            const MaterialApp(
              home: LoginPage(),
            ),
          );

          // Preencher os campos
          await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
          await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

          // Clicar no botão de login
          await tester.tap(
            find.text('Entrar'),
          );
          await tester.pumpAndSettle();

          // Assert
          verify(mockUserService.login('testuser', 'wrongpassword')).called(1);
          verifyNever(
            mockModularNavigate.navigate('/home/'),
          );
        },
      );
    },
  );
}
