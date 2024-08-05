// import 'dart:io';
// import 'dart:developer';
// import 'package:mobx/mobx.dart';
// import 'package:flutter/material.dart';
// import 'package:process_run/shell.dart';
// import 'package:flutter_modular/flutter_modular.dart';

// import '../logger/app_logger.dart';
// import '../ui/widgets/messages.dart';

// part 'url_store.g.dart';

// class UrlStore = _UrlStore with _$UrlStore;

// abstract class _UrlStore with Store {
//   final AppLogger _logger;

//   _UrlStore({
//     required AppLogger logger,
//   }) : _logger = logger;

//   @action
//   Future<void> launchURL(BuildContext context, String url) async {
//     try {
//       final Shell shell = Shell();
//       if (Platform.isWindows) {
//         await shell.run('start $url');
//       } else if (Platform.isMacOS) {
//         await shell.run('open $url');
//       } else if (Platform.isLinux) {
//         await shell.run('xdg-open $url');
//       } else {
//         throw 'Platform not supported';
//       }
//     } catch (e) {
//       log('Error launching URL: $e');
//       Messages.alert('Erro ao abrir URL');
//     }
//   }
// }
