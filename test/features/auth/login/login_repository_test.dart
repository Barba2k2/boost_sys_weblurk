// import 'package:flutter_test/flutter_test.dart';
// import 'package:boost_sys_weblurk/core/helpers/environments.dart';
// import 'package:boost_sys_weblurk/core/rest_client/dio/dio_rest_client.dart';
// import 'package:boost_sys_weblurk/core/local_storage/local_storage.dart';
// import 'package:boost_sys_weblurk/features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
// import 'package:boost_sys_weblurk/repositories/user/user_repository_impl.dart';
// import 'package:boost_sys_weblurk/repositories/user/user_repository.dart';
// import 'package:mockito/mockito.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// // Mocks
// class MockLocalStorage extends Mock implements LocalStorage {}
// class MockAuthViewModel extends Mock implements AuthViewModel {}
// class MockAppLogger extends Mock implements AppLogger {}

// void main() {
//   setUpAll(() async {
//     // Load environment variables from .env file for tests
//     try {
//       await dotenv.load(fileName: ".env");
//     } catch (e) {
//       print('Could not load .env file, make sure it exists in the root directory.');
//       print(e);
//     }
//   });

//   group('UserRepository Integration Test', () {
//     test('should login user with underscore successfully', () async {
//       // Arrange
//       final localStorage = MockLocalStorage();
//       final authViewModel = MockAuthViewModel();
//       final logger = MockAppLogger();

//       final dioRestClient = DioRestClient(
//         localStorage: localStorage,
//         authStore: authViewModel,
//         logger: logger,
//       );

//       final UserRepository userRepository = UserRepositoryImpl(
//         restClient: dioRestClient,
//         logger: logger,
//       );

//       const username = 'bruce_wayne_rp';
//       const password = 'boost123';

//       // Act
//       String? accessToken;
//       dynamic exception;
//       try {
//         accessToken = await userRepository.login(username, password);
//       } catch (e) {
//         exception = e;
//       }

//       // Assert
//       expect(exception, isNull, reason: 'Login failed with exception: $exception');
//       expect(accessToken, isNotNull);
//       expect(accessToken, isA<String>());
//       expect(accessToken!.isNotEmpty, isTrue);

//     }, tags: 'integration');
//   });
// }
