import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../../features/home/presentation/viewmodels/home_viewmodel.dart';
import 'webview_widget.dart';
import '../../di/injector.dart';
import '../../../features/home/data/services/webview_service.dart';

class ScheduleTabsWidget extends StatefulWidget {
  const ScheduleTabsWidget({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  State<ScheduleTabsWidget> createState() => _ScheduleTabsWidgetState();
}

class _ScheduleTabsWidgetState extends State<ScheduleTabsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late WebviewController _webviewControllerA;
  late WebviewController _webviewControllerB;
  late WebViewService _webviewService;
  bool _isControllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, // 2 abas fixas: Lista A e Lista B
      vsync: this,
      initialIndex: widget.viewModel.currentTabIndex,
    );
    widget.viewModel.addListener(_onViewModelChanged);

    _webviewService = injector<WebViewService>();
    _initWebviewControllers();
  }

  Future<void> _initWebviewControllers() async {
    try {
      _webviewControllerA = WebviewController();
      _webviewControllerB = WebviewController();

      // ✅ CORREÇÃO: Inicializar os controllers do webview_windows
      await _webviewControllerA.initialize();
      await _webviewControllerB.initialize();

      // ✅ CORREÇÃO: Inicializar os controllers no WebViewService
      await _webviewService.initializeWebView(_webviewControllerA);
      await _webviewService.initializeWebView(_webviewControllerB);

      if (mounted) {
        setState(() {
          _isControllersInitialized = true;
        });
      }

      // ✅ Configurar listeners para mudanças de canal
      _setupChannelListeners();
    } catch (e) {
      debugPrint('Erro ao inicializar WebView controllers: $e');
      if (mounted) {
        setState(() {
          _isControllersInitialized = false;
        });
      }
    }
  }

  void _setupChannelListeners() {
    // Escutar mudanças nos canais e atualizar as WebViews correspondentes
    widget.viewModel.addListener(() {
      if (_isControllersInitialized) {
        _updateWebViewUrls();
      }
    });
  }

  Future<void> _updateWebViewUrls() async {
    try {
      // Atualizar Lista A
      final channelA = widget.viewModel.currentChannelListA;
      if (channelA.isNotEmpty) {
        await _webviewService.loadUrlForController(
            _webviewControllerA, channelA);
      }

      // Atualizar Lista B
      final channelB = widget.viewModel.currentChannelListB;
      if (channelB.isNotEmpty) {
        await _webviewService.loadUrlForController(
            _webviewControllerB, channelB);
      }
    } catch (e) {
      debugPrint('Erro ao atualizar URLs das WebViews: $e');
    }
  }

  void _onViewModelChanged() {
    if (_tabController.index != widget.viewModel.currentTabIndex) {
      _tabController.animateTo(widget.viewModel.currentTabIndex);
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _tabController.dispose();

    // ✅ Não fazer dispose dos controllers aqui pois eles são gerenciados pelo service
    // O service fará o cleanup quando necessário

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) => widget.viewModel.switchTabCommand.execute(index),
            labelColor: const Color(0xFF2C1F4A),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: const Color(0xFF2C1F4A),
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Lista A'),
              Tab(text: 'Lista B'),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: _isControllersInitialized
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    // Aba Lista A
                    MyWebviewWidget(
                      initialUrl:
                          widget.viewModel.currentChannelListA.isNotEmpty
                              ? widget.viewModel.currentChannelListA
                              : 'https://twitch.tv/BoostTeam_',
                      webviewController: _webviewControllerA,
                      webviewService: _webviewService,
                    ),
                    // Aba Lista B
                    MyWebviewWidget(
                      initialUrl:
                          widget.viewModel.currentChannelListB.isNotEmpty
                              ? widget.viewModel.currentChannelListB
                              : 'https://twitch.tv/BoostTeam_',
                      webviewController: _webviewControllerB,
                      webviewService: _webviewService,
                    ),
                  ],
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Inicializando WebViews...'),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
