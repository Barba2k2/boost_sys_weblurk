import 'package:dio/dio.dart';

import '../../../../features/auth/domain/entities/auth_state.dart';
import '../../../helpers/constants.dart';
import '../../../local_storage/local_storage.dart';
import '../../../logger/app_logger.dart';

class AuthInterceptors extends Interceptor {
  AuthInterceptors({
    required LocalStorage localStorage,
    required AppLogger logger,
    required AuthState authState,
  })  : _localStorage = localStorage,
        _logger = logger,
        _authState = authState;

  final LocalStorage _localStorage;
  final AppLogger _logger;
  final AuthState _authState;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final authRequired =
          options.extra[Constants.REST_CLIENT_AUTH_REQUIRED_KEY] ?? false;

      if (authRequired) {
        final accessToken = await _localStorage.read<String>(
          Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY,
        );

        if (accessToken == null) {
          _authState.logout();

          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Expire token',
              type: DioExceptionType.cancel,
            ),
          );
        }

        options.headers['Authorization'] = accessToken;
      }

      handler.next(options);
    } catch (e, s) {
      _logger.error('Error on AuthInterceptors', e, s);
      throw Exception('Error on AuthInterceptors');
    }
  }

  // @override
  // void onResponse(Response response, ResponseInterceptorHandler handler) {}

  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) {}
}
