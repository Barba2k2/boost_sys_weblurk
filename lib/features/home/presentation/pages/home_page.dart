import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/settings_service.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/services/volume_service.dart';
import '../../../../core/ui/widgets/live_url_bar.dart';
import '../../../../core/ui/widgets/schedule_tabs_widget.dart';
import '../../../../core/ui/widgets/syslurk_app_bar.dart';
import '../viewmodels/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.viewModel,
  });
  final HomeViewModel viewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
    widget.viewModel.loadSchedulesCommand.execute();
    widget.viewModel.fetchCurrentChannelCommand.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SyslurkAppBar(
        viewModel: widget.viewModel,
        settingsService: GetIt.I<SettingsService>(),
        urlLauncherService: GetIt.I<UrlLauncherService>(),
        volumeService: GetIt.I<VolumeService>(),
        username: widget.viewModel.userLogged?.nickname,
      ),
      body: Column(
        children: [
          // Barra de URL
          LiveUrlBar(currentChannel: widget.viewModel.currentChannel),

          // Abas customizadas
          Expanded(
            child: ScheduleTabsWidget(viewModel: widget.viewModel),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  Widget _buildFloatingActionButton() {
    return ListenableBuilder(
      listenable: widget.viewModel.loadSchedulesCommand,
      builder: (context, child) {
        final command = widget.viewModel.loadSchedulesCommand;

        return FloatingActionButton(
          onPressed: command.running
              ? null
              : () => widget.viewModel.loadSchedulesCommand.execute(),
          child: command.running
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.refresh),
        );
      },
    );
  }

}
