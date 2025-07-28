import 'package:dio/dio.dart';

import '../../../features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../helpers/constants.dart';
import '../../helpers/environments.dart';
import '../../local_storage/local_storage.dart';
import '../../logger/app_logger.dart';
import '../rest_client.dart';
import '../rest_client_exception.dart';
import '../rest_client_response.dart';
import 'interceptors/auth_interceptors.dart';

class DioRestClientAlternative implements RestClient {
  DioRestClientAlternative({
    required LocalStorage localStorage,
    required AppLogger logger,
    required AuthViewModel authStore,
    BaseOptions? baseOptions,
  }) {
    _dio = Dio(baseOptions ?? _defaultOptions);
    _dio.interceptors.addAll(
      [
        AuthInterceptors(
          localStorage: localStorage,
          logger: logger,
          authStore: authStore,
        ),
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: true,
        ),
      ],
    );
  }
  late final Dio _dio;

  final _defaultOptions = BaseOptions(
    baseUrl: Environments.param(Constants.ENV_BASE_URL_KEY) ?? '',
    connectTimeout: const Duration(milliseconds: 30000), // Reduzido para 30s
    receiveTimeout: const Duration(milliseconds: 30000), // Reduzido para 30s
    sendTimeout: const Duration(milliseconds: 30000), // Reduzido para 30s
    validateStatus: (status) {
      return status != null && status < 500;
    },
    // Configurações mais permissivas
    followRedirects: true,
    maxRedirects: 10,
    // Configurações de retry
    extra: {
      'retry': 3,
      'retryDelay': 1000,
    },
  );

  @override
  RestClient auth() {
    _defaultOptions.extra[Constants.REST_CLIENT_AUTH_REQUIRED_KEY] = true;
    return this;
  }

  @override
  Future<RestClientResponse<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _executeWithRetry(() => _dio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        ));
  }

  @override
  Future<RestClientResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _executeWithRetry(() => _dio.get(
          path,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        ));
  }

  @override
  Future<RestClientResponse<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _executeWithRetry(() => _dio.patch(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        ));
  }

  @override
  Future<RestClientResponse<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _executeWithRetry(() => _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        ));
  }

  @override
  Future<RestClientResponse<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _executeWithRetry(() => _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        ));
  }

  @override
  Future<RestClientResponse<T>> request<T>(
    String path, {
    required String method,
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _executeWithRetry(() => _dio.request(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            headers: headers,
            method: method,
          ),
        ));
  }

  @override
  RestClient unAuth() {
    _defaultOptions.extra[Constants.REST_CLIENT_AUTH_REQUIRED_KEY] = false;
    return this;
  }

  Future<RestClientResponse<T>> _executeWithRetry<T>(
    Future<Response<dynamic>> Function() request,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 1000);

    while (retryCount < maxRetries) {
      try {
        final response = await request();
        return _dioResponseConverter(response);
      } on DioException catch (e) {
        retryCount++;

        // Log detalhado do erro
        print('=== DIO ERROR (Attempt $retryCount/$maxRetries) ===');
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        print('Error: ${e.error}');
        print('========================');

        if (retryCount >= maxRetries) {
          _throwRestClientException(e);
        }

        // Aguardar antes de tentar novamente
        await Future.delayed(retryDelay);
      }
    }

    throw RestClientException(
      error: Exception('Max retries exceeded'),
      message: 'Erro de conexão após múltiplas tentativas',
      statusCode: null,
      response: RestClientResponse(
        data: null,
        statusCode: null,
        statusMessage: 'Erro de conexão após múltiplas tentativas',
      ),
    );
  }

  Future<RestClientResponse<T>> _dioResponseConverter<T>(
    Response<dynamic> response,
  ) async {
    return RestClientResponse<T>(
      data: response.data,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
    );
  }

  Never _throwRestClientException(DioException dioException) {
    final response = dioException.response;

    throw RestClientException(
      error: dioException.error,
      message: response?.statusMessage,
      statusCode: response?.statusCode,
      response: RestClientResponse(
        data: response?.data,
        statusCode: response?.statusCode,
        statusMessage: response?.statusMessage,
      ),
    );
  }
}
