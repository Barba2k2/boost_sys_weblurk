import 'package:flutter/material.dart';

import '../../../../core/controllers/settings_controller.dart';
import '../../../../core/controllers/url_launch_controller.dart';
import '../../../../core/di/di.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/syslurk_app_bar.dart';
import '../../../auth/domain/entities/auth_store.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/universal_webview_widget.dart';
import '../widgets/live_url_bar/live_url_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final HomeViewModel _viewModel;
  late final SettingsController _settingsController;
  late final UrlLaunchController _urlController;
  late final AppLogger _logger;
  late final AuthStore _authStore;
  bool _isWebViewMuted = false;

  @override
  void initState() {
    super.initState();
    _logger = di.get<AppLogger>();
    _authStore = di.get<AuthStore>();
    _viewModel = HomeViewModel();
    _settingsController = SettingsController(logger: _logger);
    _urlController = UrlLaunchController(logger: _logger);
    _viewModel.initializeHome();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _toggleWebViewMute() {
    setState(() {
      _isWebViewMuted = !_isWebViewMuted;
    });
    _logger.info('WebView mute ${_isWebViewMuted ? 'ativado' : 'desativado'}');
  }

  String _getUsername() {
    final user = _authStore.userLogged;
    if (user != null && user.nickname.isNotEmpty) {
      return user.nickname;
    }
    return 'Convidado';
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: ListenableBuilder(
            listenable: _authStore,
            builder: (context, child) {
              return SyslurkAppBar(
                username: _getUsername(),
                onReloadWebView: () {
                  // TODO: Implement reload functionality
                  _logger.info('Reload requested');
                },
                onTerminateApp: _settingsController.terminateApp,
                onToggleMute: _toggleWebViewMute,
                isMuted: _isWebViewMuted,
                urlController: _urlController,
                settingsController: _settingsController,
              );
            },
          ),
          body: Column(
            children: [
              // TODO: Add schedule tabs widget
              Container(
                height: 50,
                color: Colors.grey[200],
                child: const Center(
                  child: Text('Schedule Tabs - TODO'),
                ),
              ),
              // Live URL bar
              ListenableBuilder(
                listenable: _viewModel,
                builder: (_, __) => LiveUrlBar(
                  currentChannel: _viewModel.currentChannel,
                ),
              ),
              Expanded(
                child: UniversalWebViewWidget(
                  initialUrl: 'https://www.google.com',
                  logger: _logger,
                  isMuted: _isWebViewMuted,
                  onWebViewCreated: (controller) {
                    _logger.info('WebView criado com sucesso');
                  },
                ),
              ),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (_, __) => _viewModel.isInitializing
                    ? Semantics(
                        label: 'Inicializando aplicação, aguarde...',
                        child: Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          floatingActionButton: ListenableBuilder(
            listenable: _viewModel,
            builder: (_, __) => Semantics(
              label: 'Iniciar polling',
              button: true,
              child: FloatingActionButton.extended(
                onPressed: _viewModel.startPolling,
                label: Text(
                  'Iniciar Polling',
                  style: TextStyle(fontSize: 14 * textScaleFactor),
                ),
                icon: const Icon(Icons.play_arrow),
                heroTag: 'start_polling',
              ),
            ),
          ),
        );
      },
    );
  }
}
