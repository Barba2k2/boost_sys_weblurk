import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../core/ui/widgets/live_url_bar.dart';
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
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
