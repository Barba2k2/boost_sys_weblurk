import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

// import '../../../../core/ui/widgets/syslurk_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final webViewController = WebviewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: const SyslurkAppBar(),
      body: Webview(
        webViewController,
        permissionRequested: (url, permissionKind, isUserInitiated) {
          return Future.value(WebviewPermissionDecision.allow);
        },
      ),
    );
  }
}
