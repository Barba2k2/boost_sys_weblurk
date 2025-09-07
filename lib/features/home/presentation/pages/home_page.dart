import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../auth/login/presentation/viewmodels/login_viewmodel.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/timezone_service.dart';
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
      backgroundColor: AppColors.cosmicNavy,
      appBar: SyslurkAppBar(
        viewModel: widget.viewModel,
        loginViewModel: GetIt.I<LoginViewModel>(),
        settingsService: GetIt.I<SettingsService>(),
        timezoneService: GetIt.I<TimezoneService>(),
        urlLauncherService: GetIt.I<UrlLauncherService>(),
        volumeService: GetIt.I<VolumeService>(),
        username: widget.viewModel.userLogged?.nickname,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.cosmicNavy,
              AppColors.cosmicBlue,
              AppColors.cosmicDarkPurple,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ScheduleTabsWidget(viewModel: widget.viewModel),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cosmicButtonStart,
              AppColors.cosmicButtonEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.cosmicBorder.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.cosmicNavy.withValues(alpha: 0.95),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cosmicAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: Icon(
                        Icons.refresh,
                        color: AppColors.cosmicAccent,
                      ),
                      title: const Text(
                        'Atualizar Agendamentos',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        widget.viewModel.loadSchedulesCommand.execute();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.system_update,
                        color: AppColors.cosmicAccent,
                      ),
                      title: const Text(
                        'Verificar Atualização do App',
                        style: TextStyle(color: Colors.white),
                      ),
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
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
