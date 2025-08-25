import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/settings_service.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/services/volume_service.dart';
import '../../../../core/ui/app_colors.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    widget.viewModel.loadSchedulesCommand.addListener(_handleLoadingChange);

    widget.viewModel.loadSchedulesCommand.execute();
    widget.viewModel.fetchCurrentChannelCommand.execute();

    if (widget.viewModel.loadSchedulesCommand.running) {
      _rotationController.repeat();
    }
  }

  void _handleLoadingChange() {
    final isLoading = widget.viewModel.loadSchedulesCommand.running;
    if (isLoading) {
      _rotationController.repeat();
    } else {
      final currentValue = _rotationController.value;
      if (currentValue != 0.0) {
        _rotationController.stop();
        _rotationController
            .animateTo(
          1.0,
          duration: const Duration(milliseconds: 700),
        )
            .then(
          (_) {
            _rotationController.value = 0.0;
          },
        );
      } else {
        _rotationController.stop();
        _rotationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    widget.viewModel.loadSchedulesCommand.removeListener(_handleLoadingChange);
    super.dispose();
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
          Expanded(
            child: ScheduleTabsWidget(viewModel: widget.viewModel),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Atualizar Agendamentos'),
                    onTap: () {
                      Navigator.pop(context);
                      widget.viewModel.loadSchedulesCommand.execute();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.system_update),
                    title: const Text('Verificar Atualização do App'),
                    onTap: () {
                      Navigator.pop(context);
                      widget.viewModel.checkUpdate();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(
          Icons.menu,
          color: AppColors.cardHeaderText,
        ),
      ),
    );
  }
}
