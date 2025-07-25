import 'dart:math' as math;

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
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    );
    widget.viewModel.loadSchedulesCommand.addListener(_handleLoadingChange);

    // Carregar dados iniciais
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
      // Ao parar, anima até o final do ciclo com bounce
      final currentValue = _rotationController.value;
      if (currentValue != 0.0) {
        _rotationController.stop();
        _rotationAnimation = CurvedAnimation(
          parent: _rotationController,
          curve: Curves.elasticOut,
        );
        _rotationController
            .animateTo(
          1.0,
          duration: const Duration(milliseconds: 700),
        )
            .then(
          (_) {
            _rotationController.value = 0.0;
            _rotationAnimation = CurvedAnimation(
              parent: _rotationController,
              curve: Curves.linear,
            );
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
          // Abas customizadas
          Expanded(
            child: ScheduleTabsWidget(viewModel: widget.viewModel),
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: widget.viewModel.loadSchedulesCommand,
        builder: (context, child) {
          final command = widget.viewModel.loadSchedulesCommand;
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: command.running
                ? null
                : () => widget.viewModel.loadSchedulesCommand.execute(),
            icon: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * math.pi,
                  child: const Icon(
                    Icons.refresh,
                    size: 30,
                    color: AppColors.cardHeaderText,
                  ),
                );
              },
            ),
            label: const Text(
              'Atualizar',
              style: TextStyle(
                fontFamily: 'Ibrand',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.cardHeaderText,
                letterSpacing: 2.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
