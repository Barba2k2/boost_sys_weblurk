import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/logger/logger_app_logger_impl.dart';

class ScheduleWebSocketService {
  ScheduleWebSocketService(String baseUrl)
      : _wsUrl = '${baseUrl.replaceFirst('http', 'ws')}/schedules/ws/streamer',
        _logger = LoggerAppLoggerImpl();

  late WebSocketChannel _channel;
  final String _wsUrl;
  final LoggerAppLoggerImpl _logger;

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

    _channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (data['type'] == 'SCHEDULE_UPDATE') {
          // Atualiza a UI com os novos dados
          _handleScheduleUpdate(data['data']);
        }
      },
      onError: (error) {
        _logger.error('WebSocket error: $error');
        // Implementar reconexão se necessário
      },
      onDone: () {
        _logger.error('WebSocket connection closed');
        // Implementar reconexão se necessário
      },
    );
  }

  void _handleScheduleUpdate(Map<String, dynamic> scheduleData) {
    // Atualizar o estado da aplicação/UI com os novos dados
  }

  void dispose() {
    _channel.sink.close();
  }
}
