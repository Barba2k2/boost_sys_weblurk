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
                        child: WebviewWidget(
                          initialUrl: homeController.currentChannel ??
                              'https://twitch.tv/BoostTeam_',
                          onWebViewCreated: homeController.onWebViewCreated,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          // floatingActionButton: Observer(
          //   builder: (_) => FloatingActionButton.extended(
          //     onPressed: () {
          //       // controller.isScheduleVisible.toggle();
          //     },
          //     label: const Text(
          //       // controller.isScheduleVisible.value ? 'Esconder' : 'Mostrar',
          //       'Mostrar',
          //     ),
          //     icon: const Icon(
          //       Icons.arrow_upward_rounded,
          //     ),
          //   ),
          // ),
        );
      },
    );
  }
}
