import 'package:dio/dio.dart';

import '../../../../features/auth/domain/entities/auth_store.dart';
import '../../../helpers/constants.dart';
import '../../../local_storage/local_storage.dart';
import '../../../logger/app_logger.dart';

class AuthInterceptors extends Interceptor {
  AuthInterceptors({
    required LocalStorage localStorage,
    required AppLogger logger,
    required AuthStore authStore,
  })  : _localStorage = localStorage,
        _logger = logger,
        _authStore = authStore;
  final LocalStorage _localStorage;
  final AppLogger _logger;
  final AuthStore _authStore;

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
          _authStore.logout();

          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Expire token',
              type: DioExceptionType.cancel,
            ),
          );
        }

        options.headers['Authorization'] = accessToken;
      } else {
        options.headers.remove('Authorization');
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
