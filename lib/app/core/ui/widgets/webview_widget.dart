import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class WebviewWidget extends StatelessWidget {
  final WebviewController webViewController;
  final Future<void> initializationFuture;

  const WebviewWidget({
    required this.webViewController,
    required this.initializationFuture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initializationFuture,
      builder: (context, snapshot) {
        // Log the snapshot details
        // log('Snapshot connection state: ${snapshot.connectionState}');
        // log('Snapshot hasData: ${snapshot.hasData}');
        // log('Snapshot hasError: ${snapshot.hasError}');
        // log('Snapshot error: ${snapshot.error}');
        // log('Snapshot stack trace: ${snapshot.stackTrace}');

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            log('Error: ${snapshot.error}');
          }
          // if (!snapshot.hasData) {
          //   log('No data found in snapshot');
          // }
          return Webview(
            webViewController,
            permissionRequested: (url, permissionKind, isUserInitiated) {
              return Future.value(WebviewPermissionDecision.allow);
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.purple,
            ),
          );
        }
      },
    );
  }
}
