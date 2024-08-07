import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:process_run/process_run.dart';

import '../logger/app_logger.dart';
import '../ui/widgets/messages.dart';

part 'url_launch_controller.g.dart';

class UrlLaunchController = UrlLaunchControllerBase with _$UrlLaunchController;

abstract class UrlLaunchControllerBase with Store {
  final AppLogger _logger;

  UrlLaunchControllerBase({
    required AppLogger logger,
  }) : _logger = logger;

  @action
  Future<void> launchURL(String url) async {
    try {
      final Shell shell = Shell();
      if (Platform.isWindows) {
        await shell.run('start $url');
      } else if (Platform.isMacOS) {
        await shell.run('open $url');
      } else if (Platform.isLinux) {
        await shell.run('xdg-open $url');
      } else {
        throw 'Platform not supported';
      }
    } catch (e) {
      _logger.error('Error launching URL: $e');
      Messages.alert('Erro ao abrir URL');
    }
  }
}
