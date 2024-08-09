import 'dart:io';
import 'package:mobx/mobx.dart';
import '../../service/schedule/schedule_service.dart';
import '../formatters/date_formatter.dart';
import '../logger/app_logger.dart';
import '../ui/widgets/messages.dart';

part 'settings_controller.g.dart';

class SettingsController = SettingsControllerBase with _$SettingsController;

abstract class SettingsControllerBase with Store {
  final ScheduleService _scheduleService;
  final AppLogger _logger;

  SettingsControllerBase({
    required AppLogger logger,
    required ScheduleService scheduleService,
  })  : _logger = logger,
        _scheduleService = scheduleService;

  // Método para encerrar o aplicativo
  @action
  Future<void> terminateApp() async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        exit(0);
      } else {
        throw 'Plataforma não suportada para encerramento do app';
      }
    } catch (e) {
      _logger.error('Erro ao encerrar o aplicativo: $e');
      Messages.alert('Erro ao encerrar o aplicativo');
    }
  }

  // Método para mutar o áudio do WebView
  @action
  Future<void> muteAppAudio() async {
    try {
      if (Platform.isWindows) {
        Messages.info('Funcionalidade ainda não implementada');
      }
      // else if (Platform.isMacOS) {
      //   await shell.run('osascript -e "set volume output muted true"');
      // } else if (Platform.isLinux) {
      //   await shell.run('amixer -q -D pulse sset Master mute');
      // } else {
      //   throw 'Plataforma não suportada para mutar áudio';
      // }
    } catch (e) {
      _logger.error('Erro ao mutar o áudio do aplicativo: $e');
      Messages.alert('Erro ao mutar o áudio do aplicativo');
    }
  }

  Future<void> fetchSchedule() async {
    try {
      final scheduleData = await _scheduleService.fetchSchedule();
      DateTime now = DateTime.now();

      var tempSchedule = scheduleData.where(
        (item) {
          DateTime streamDate = DateTime.parse(item['date']);
          return streamDate.day == now.day &&
              streamDate.month == now.month &&
              streamDate.year == now.year;
        },
      ).map(
        (item) {
          DateTime streamDate = DateTime.parse(item['date']);
          DateTime startTime = DateTime(
            streamDate.year,
            streamDate.month,
            streamDate.day,
            int.parse(item['startTime'].split(':')[0]),
            int.parse(item['startTime'].split(':')[1]),
          );
          int status;

          if (startTime.hour == now.hour) {
            status = 1; // Live em andamento
          } else if (startTime.isBefore(now)) {
            status = 2; // Live já realizada
          } else {
            status = 0; // Live não realizada
          }

          return {
            'seq': startTime.hour + 1,
            'nome_do_streamer': item['streamerUrl']?.split('/')?.last ?? '',
            'horario': DateFormatter.formatTime(startTime),
            'data': DateFormatter.formatDate(streamDate),
            'acao': '2 - Executar Live Programada',
            'link_do_canal': item['streamerUrl'] ?? '',
            'status': status,
          };
        },
      ).toList();

      // schedule.assignAll(tempSchedule);
      // _startChannelChangeTimer();
    } catch (e, s) {
      _logger.error('Error on fetch schedule', e, s);
      Messages.alert(
        'Erro ao atualizar as listas, verifique se tem conexão com a internet e tente novamente.',
      );
    }
  }
}
