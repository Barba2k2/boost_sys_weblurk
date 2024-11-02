import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/ui/widgets/live_url_bar.dart';
import '../../../../core/ui/widgets/syslurk_app_bar.dart';
import '../../../../core/ui/widgets/webview_widget.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = Modular.get<HomeController>();
  bool _hasCheckedPlatform = false;
  String? _platformError;

  @override
  void initState() {
    super.initState();
    _checkPlatform();
  }

  Future<void> _checkPlatform() async {
    if (!Platform.isWindows) {
      setState(() {
        _hasCheckedPlatform = true;
        _platformError = 'Esta aplicação só está disponível no Windows';
      });
      return;
    }

    setState(() {
      _hasCheckedPlatform = true;
    });
    homeController.onInit();
  }

  @override
  void dispose() {
    homeController.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    if (!_hasCheckedPlatform) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.purple,
        ),
      );
    }

    if (_platformError != null) {
      return Center(
        child: Text(
          _platformError!,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Observer(
      builder: (_) {
        if (!homeController.isWebViewInitialized) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.purple,
                ),
                SizedBox(height: 16),
                Text(
                  'Inicializando WebView...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

        return WebviewWidget(
          webViewController: homeController.webViewController,
          initializationFuture: homeController.initializationFuture,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SyslurkAppBar(),
      body: Column(
        children: [
          Observer(
            builder: (_) => LiveUrlBar(
              currentChannel: homeController.currentChannel,
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
