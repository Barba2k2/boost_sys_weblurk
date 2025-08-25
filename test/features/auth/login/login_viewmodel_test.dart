import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:boost_sys_weblurk/features/auth/login/presentation/viewmodels/login_viewmodel.dart';
import 'package:boost_sys_weblurk/service/user/user_service.dart';
import 'package:boost_sys_weblurk/features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
import 'package:boost_sys_weblurk/models/user_model.dart';

// Mocks
class MockUserService extends Mock implements UserService {}
class MockAuthViewModel extends Mock implements AuthViewModel {
  @override
  UserModel? get userLogged => null; // Default to null, can be overridden
}

void main() {
  late LoginViewModel loginViewModel;
  late MockUserService mockUserService;
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockUserService = MockUserService();
    mockAuthViewModel = MockAuthViewModel();

    // Stub the reloadUserData to prevent null issues
    when(mockAuthViewModel.reloadUserData()).thenAnswer((_) async => {});

    loginViewModel = LoginViewModel(
      authStore: mockAuthViewModel,
      userService: mockUserService,
    );
  });

  group('LoginViewModel Unit Test', () {
    test('should call login service with exact username and password', () async {
      // Arrange
      const usernameWithSpaces = '  bruce_wayne_rp  ';
      const passwordWithSpaces = '  boost123  ';
      final loginParams = LoginParams(nickname: usernameWithSpaces, password: passwordWithSpaces);

      when(mockUserService.login(any, any)).thenAnswer((_) async => {});
      when(mockAuthViewModel.userLogged).thenReturn(UserModel(id: 1, nickname: 'bruce_wayne_rp', role: 'user', status: 'ON'));


      // Act
      await loginViewModel.loginCommand.execute(loginParams);

      // Assert
      final verification = verify(mockUserService.login(captureAny, captureAny));

      // Check that login was called once
      verification.called(1);

      // Check the captured values
      final captured = verification.captured;
      expect(captured[0], usernameWithSpaces, reason: "Username should not be trimmed");
      expect(captured[1], passwordWithSpaces, reason: "Password should not be trimmed");
    });

    test('validateUser should return error message for empty value', () {
      // Act
      final result = loginViewModel.validateUser('');
      // Assert
      expect(result, 'Login obrigatório');
    });

    test('validateUser should return null for non-empty value', () {
      // Act
      final result = loginViewModel.validateUser('some_user');
      // Assert
      expect(result, isNull);
    });
  });
}
