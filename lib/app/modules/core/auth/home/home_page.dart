import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../core/ui/widgets/live_url_bar.dart';
import '../../../../core/ui/widgets/schedule_table.dart';
import '../../../../core/ui/widgets/syslurk_app_bar.dart';
import 'home_controller.dart';

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
    final homeController = Modular.get<HomeController>();
    final scheduleScrollController = ScrollController();

    return Scaffold(
      appBar: const SyslurkAppBar(),
      body: Observer(
        builder: (_) {
          return Stack(
            children: [
              Column(
                children: [
                  const LiveUrlBar(
                    currentChannel: 'Canal XYZ',
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return const ListTile(
                          title: Text('Nome'),
                          subtitle: Text('Horario'),
                          // trailing: Text(homeController.getStatusText(item['status'])),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white.withOpacity(0.90),
                        child: SizedBox(
                          height: 200,
                          child: Scrollbar(
                            controller: scheduleScrollController,
                            child: SingleChildScrollView(
                              controller: scheduleScrollController,
                              // child: const ScheduleTable(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: Observer(
        builder: (_) => FloatingActionButton.extended(
          onPressed: () {
            // controller.isScheduleVisible.toggle();
          },
          label: const Text(
            // controller.isScheduleVisible.value ? 'Esconder' : 'Mostrar',
            'Mostrar',
          ),
          icon: const Icon(
            Icons.arrow_upward_rounded,
          ),
        ),
      ),
    );
  }
}
