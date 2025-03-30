import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/ui/widgets/live_url_bar.dart';
import '../../../../core/ui/widgets/syslurk_app_bar.dart';
import '../../../../core/ui/widgets/windows_web_view_widget.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = Modular.get<HomeController>();

  @override
  void initState() {
    super.initState();
    homeController.onInit();
  }

  @override
  void dispose() {
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
                      LiveUrlBar(
                        currentChannel: homeController.currentChannel,
                      ),
                      Expanded(
                        child: WindowsWebViewWidget(
                          initialUrl:
                              homeController.currentChannel ?? 'https://twitch.tv/BoostTeam_',
                          onWebViewCreated: homeController.onWebViewCreated,
                          logger: Modular.get(), // Injetando o logger
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
            ),
          ),
        );
      },
    );
  }
}
