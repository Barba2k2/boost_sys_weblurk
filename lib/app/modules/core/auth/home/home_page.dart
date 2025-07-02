import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/ui/widgets/live_url_bar.dart';
import '../../../../core/ui/widgets/syslurk_app_bar.dart';
import '../../../../core/ui/widgets/windows_web_view_widget.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final homeController = Modular.get<HomeController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    homeController.onInit();
  }

  @override
  void dispose() {
    _tabController.dispose();
    homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: SyslurkAppBar(),
          body: Column(
            children: [
              // Abas principais (não precisa de Observer)
              Container(
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  color: Color(0xFF231942),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: EdgeInsets.zero,
                  onTap: (index) {
                    homeController.switchTab(index);
                    _tabController.animateTo(index);
                  },
                  indicator: const BoxDecoration(
                    color: Color(0xFFA259FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.white),
                      vertical: BorderSide(color: Colors.white),
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFFB9AEE0),
                  labelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * textScaleFactor,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 16 * textScaleFactor,
                  ),
                  tabs: const [
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('Lista A'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('Lista B'),
                      ),
                    ),
                  ],
                ),
              ),
              // LiveUrlBar com Observer para reagir às mudanças
              Observer(
                builder: (_) => LiveUrlBar(
                  currentChannel: homeController.currentChannel,
                ),
              ),
              // Conteúdo das abas usando IndexedStack para manter estado independente
              Expanded(
                child: Observer(
                  builder: (_) => IndexedStack(
                    index: homeController.currentTabIndex,
                    children: [
                      // Aba Lista A
                      Semantics(
                        label: 'Conteúdo da Lista A - Navegador web',
                        child: WindowsWebViewWidget(
                          key: const ValueKey('webview_lista_a'),
                          initialUrl: 'https://twitch.tv/BoostTeam_',
                          currentUrl: homeController.currentChannelListA,
                          onWebViewCreated: homeController.onWebViewCreated,
                          logger: Modular.get(),
                        ),
                      ),
                      // Aba Lista B
                      Semantics(
                        label: 'Conteúdo da Lista B - Navegador web',
                        child: WindowsWebViewWidget(
                          key: const ValueKey('webview_lista_b'),
                          initialUrl: 'https://twitch.tv/BoostTeam_',
                          currentUrl: homeController.currentChannelListB,
                          onWebViewCreated: homeController.onWebViewCreated,
                          logger: Modular.get(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Indicador de recuperação
              Observer(
                builder: (_) => homeController.isRecovering
                    ? Semantics(
                        label: 'Recuperando aplicação, aguarde...',
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
          floatingActionButton: Observer(
            builder: (_) => Semantics(
              label: 'Recarregar página atual',
              button: true,
              child: FloatingActionButton.extended(
                onPressed: homeController.reloadWebView,
                label: Text(
                  'Recarregar',
                  style: TextStyle(fontSize: 14 * textScaleFactor),
                ),
                icon: const Icon(Icons.refresh),
                heroTag: 'reload',
              ),
            ),
          ),
        );
      },
    );
  }
}
