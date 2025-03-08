import 'rest_client_response.dart';

class RestClientException implements Exception {
  RestClientException({
    this.message,
    this.statusCode,
    required this.error,
    required this.response,
  });

  String? message;
  int? statusCode;
  dynamic error;
  RestClientResponse response;

  @override
  String toString() {
    return 'RestClientException(message: $message, statusCode: $statusCode, error: $error, response: $response)';
  }
}
