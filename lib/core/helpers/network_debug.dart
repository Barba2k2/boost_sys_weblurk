import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';

class NetworkDebug {
  static Future<bool> testBasicConnectivity() async {
    try {
      final dio = Dio();
      final response = await dio.get('https://httpbin.org/get');
      log('Basic connectivity test: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      log('Basic connectivity test failed: $e');
      return false;
    }
  }

  static Future<bool> testApiConnectivity() async {
    try {
      final dio = Dio();
      final response = await dio.get('https://api.boostapi.com.br/auth/login');
      log('API connectivity test: ${response.statusCode}');
      return true;
    } catch (e) {
      log('API connectivity test failed: $e');
      return false;
    }
  }

  static Future<void> runNetworkDiagnostics() async {
    log('=== NETWORK DIAGNOSTICS ===');

    // Teste básico de conectividade
    final basicConnectivity = await testBasicConnectivity();
    log('Basic connectivity: $basicConnectivity');

    // Teste específico da API
    final apiConnectivity = await testApiConnectivity();
    log('API connectivity: $apiConnectivity');

    // Verificar DNS
    try {
      final addresses = await InternetAddress.lookup('api.boostapi.com.br');
      log('DNS resolution: ${addresses.isNotEmpty}');
      for (var address in addresses) {
        log('  - ${address.address}');
      }
    } catch (e) {
      log('DNS resolution failed: $e');
    }

    log('=== END DIAGNOSTICS ===');
  }
}
