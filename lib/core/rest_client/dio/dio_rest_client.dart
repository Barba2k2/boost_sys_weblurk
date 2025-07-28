import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../../features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../helpers/constants.dart';
import '../../helpers/environments.dart';
import '../../local_storage/local_storage.dart';
import '../../logger/app_logger.dart';
import '../rest_client.dart';
import '../rest_client_exception.dart';
import '../rest_client_response.dart';
import 'interceptors/auth_interceptors.dart';

class DioRestClient implements RestClient {
  DioRestClient({
    required LocalStorage localStorage,
    required AppLogger logger,
    required AuthViewModel authStore,
    BaseOptions? baseOptions,
  }) {
    _dio = Dio(baseOptions ?? _defaultOptions);

    // Configurações específicas para macOS
    if (Platform.isMacOS) {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 30);
      httpClient.idleTimeout = const Duration(seconds: 30);

      // Configurações para contornar problemas de certificado
      httpClient.badCertificateCallback = (cert, host, port) => true;

      _dio.httpClientAdapter = IOHttpClientAdapter();
    }

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
    // Configurações mais permissivas para macOS
    followRedirects: true,
    maxRedirects: 10,
    // Configurações específicas para contornar problemas de permissão
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
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _dioResponseConverter(response);
    } on DioException catch (e) {
      _throwRestClientException(e);
    }
  }

  @override
  Future<RestClientResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _executeWithRetry(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  @override
  Future<RestClientResponse<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _dioResponseConverter(response);
    } on DioException catch (e) {
      _throwRestClientException(e);
    }
  }

  @override
  Future<RestClientResponse<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _executeWithRetry(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  @override
  Future<RestClientResponse<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _dioResponseConverter(response);
    } on DioException catch (e) {
      _throwRestClientException(e);
    }
  }

  @override
  Future<RestClientResponse<T>> request<T>(
    String path, {
    required String method,
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          method: method,
        ),
      );

      return _dioResponseConverter(response);
    } on DioException catch (e) {
      _throwRestClientException(e);
    }
  }

  @override
  RestClient unAuth() {
    _defaultOptions.extra[Constants.REST_CLIENT_AUTH_REQUIRED_KEY] = false;
    return this;
  }

  /// Testa a conectividade com a API
  Future<bool> testConnectivity() async {
    try {
      log('=== TESTING CONNECTIVITY ===');
      log('Base URL: ${_defaultOptions.baseUrl}');
      log('Full URL: ${_defaultOptions.baseUrl}/auth/login');

      // Teste usando HttpClient diretamente para macOS
      if (Platform.isMacOS) {
        final httpClient = HttpClient();
        httpClient.connectionTimeout = const Duration(seconds: 10);
        httpClient.idleTimeout = const Duration(seconds: 10);

        try {
          final request = await httpClient.getUrl(
            Uri.parse('${_defaultOptions.baseUrl}/auth/login'),
          );
          final response = await request.close();
          log('Direct HttpClient test successful: ${response.statusCode}');
          return true;
        } catch (e) {
          log('Direct HttpClient test failed: $e');
          return false;
        } finally {
          httpClient.close();
        }
      }

      // Teste usando Dio
      final response = await _dio.get(
        '/auth/login',
        options: Options(
          validateStatus: (status) => true, // Aceita qualquer status para teste
        ),
      );

      log('Connectivity test successful');
      log('Status: ${response.statusCode}');
      return true;
    } catch (e) {
      log('Connectivity test failed: $e');
      return false;
    }
  }

  /// Executa requisições com retry automático
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
        log('=== DIO ERROR (Attempt $retryCount/$maxRetries) ===');
        log('Type: ${e.type}');
        log('Message: ${e.message}');
        log('Error: ${e.error}');
        log('========================');

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
      response: RestClientResponse(
        data: null,
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

    // Log detalhado do erro para debug
    log('=== DIO ERROR DETAILS ===');
    log('Type: ${dioException.type}');
    log('Message: ${dioException.message}');
    log('Error: ${dioException.error}');
    log('Response Status: ${response?.statusCode}');
    log('Response Message: ${response?.statusMessage}');
    log('Request URL: ${dioException.requestOptions.uri}');
    log('Request Method: ${dioException.requestOptions.method}');
    log('Request Headers: ${dioException.requestOptions.headers}');
    log('Request Data: ${dioException.requestOptions.data}');
    log('========================');

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
