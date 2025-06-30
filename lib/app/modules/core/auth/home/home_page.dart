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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: SyslurkAppBar(),
          body: Observer(
            builder: (_) {
              return Stack(
                children: [
                  Column(
                    children: [
                      // Abas principais
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(
                          color: Color(0xFF231942),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          onTap: (index) => homeController.switchTab(index),
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
                            fontSize: 16,
                          ),
                          unselectedLabelStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          tabs: const [
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text('Lista A'),
                              ),
                            ),
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Text('Lista B'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      LiveUrlBar(
                        currentChannel: homeController.currentChannel,
                      ),
                      // Conteúdo das abas
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Aba Lista A
                            WindowsWebViewWidget(
                              initialUrl: homeController.currentChannel ??
                                  'https://twitch.tv/BoostTeam_',
                              onWebViewCreated: homeController.onWebViewCreated,
                              logger: Modular.get(),
                            ),
                            // Aba Lista B
                            WindowsWebViewWidget(
                              initialUrl: homeController.currentChannel ??
                                  'https://twitch.tv/BoostTeam_',
                              onWebViewCreated: homeController.onWebViewCreated,
                              logger: Modular.get(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Indicador de recuperação
                  if (homeController.isRecovering)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.purple,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          floatingActionButton: Observer(
            builder: (_) => FloatingActionButton.extended(
              onPressed: homeController.reloadWebView,
              label: const Text('Recarregar'),
              icon: const Icon(Icons.refresh),
              heroTag: 'reload',
            ),
          ),
        );
      },
    );
  }
}
