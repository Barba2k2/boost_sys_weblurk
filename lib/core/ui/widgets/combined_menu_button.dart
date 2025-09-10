import 'package:flutter/material.dart';

import '../../../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../../services/settings_service.dart';
import '../../services/timezone_service.dart';
import '../../services/url_launcher_service.dart';
import '../../services/volume_service.dart';
import '../app_colors.dart';
import '../dialogs/timezone_dialog.dart';
import '../widgets/messages.dart';
import 'menu_item_widget.dart';

class CombinedMenuButton extends StatefulWidget {
  final HomeViewModel viewModel;
  final SettingsService settingsService;
  final TimezoneService timezoneService;
  final UrlLauncherService urlLauncherService;
  final VolumeService volumeService;

  const CombinedMenuButton({
    super.key,
    required this.viewModel,
    required this.settingsService,
    required this.timezoneService,
    required this.urlLauncherService,
    required this.volumeService,
  });

  @override
  State<CombinedMenuButton> createState() => _CombinedMenuButtonState();
}

class _CombinedMenuButtonState extends State<CombinedMenuButton> {
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _checkMuteStatus();
  }

  Future<void> _checkMuteStatus() async {
    try {
      final isMuted = await widget.volumeService.isSystemMuted();
      if (mounted) {
        setState(() {
          _isMuted = isMuted;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMuted = widget.volumeService.isMuted;
        });
      }
    }
  }

  Future<void> _handleMute() async {
    await widget.volumeService.mute();
    await _checkMuteStatus();
    _showMessage('Áudio mutado');
  }

  Future<void> _handleUnmute() async {
    await widget.volumeService.unmute();
    await _checkMuteStatus();
    _showMessage('Áudio desmutado');
  }

  void _showMessage(String message) {
    if (mounted) {
      Navigator.of(context).pop();

      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: 20,
          right: 200,
          bottom: 20,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.cosmicNavy,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.cosmicBorder,
                ),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Ibrand',
                  color: AppColors.cosmicAccent,
                  fontSize: 18,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {},
      offset: const Offset(0, 40),
      color: AppColors.menuBackgroundImproved,
      surfaceTintColor: AppColors.menuBackgroundImproved,
      shadowColor: AppColors.menuBorderImproved.withValues(alpha: 0.4),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.menuBorderImproved,
          width: 1.5,
        ),
      ),
      itemBuilder: (context) => [
        MenuItemWidget(
          label: 'Atualizar Listas',
          icon: Icons.refresh,
          iconColor: AppColors.menuIconSecondary,
          onTap: () async {
            // Limpar cache e recarregar listas
            await widget.viewModel.loadSchedulesCommand.execute();
            // Recarregar WebView com os novos dados
            widget.viewModel.reloadWebView();
          },
        ),
        MenuItemWidget(
          label: 'Encerrar',
          icon: Icons.power_settings_new,
          iconColor: AppColors.menuIconDanger,
          onTap: () {
            widget.settingsService.terminateApp();
          },
        ),
        PopupMenuItem<String>(
          enabled: false,
          child: PopupMenuButton<String>(
            onSelected: (value) {},
            offset: const Offset(150, 0),
            color: AppColors.cosmicDarkPurple,
            surfaceTintColor: AppColors.cosmicDarkPurple,
            shadowColor: AppColors.cosmicBorder.withValues(alpha: 0.3),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(
                color: AppColors.cosmicBorder,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.volume_up,
                  size: 20,
                  color: AppColors.menuIconAudio,
                ),
                SizedBox(width: 10),
                Text(
                  'Audio',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Ibrand',
                  ),
                ),
                SizedBox(width: 40),
                Icon(
                  Icons.arrow_right,
                  color: AppColors.menuIconAudio,
                ),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'muted',
                child: Row(
                  children: [
                    if (_isMuted)
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.success,
                      ),
                    if (!_isMuted) const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Mutado',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Ibrand',
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _handleMute();
                },
              ),
              PopupMenuItem<String>(
                value: 'unmuted',
                child: Row(
                  children: [
                    if (!_isMuted)
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.success,
                      ),
                    if (_isMuted) const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Desmutado',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Ibrand',
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _handleUnmute();
                },
              ),
            ],
          ),
        ),
        MenuItemWidget(
          label: 'Fuso Horário',
          icon: Icons.schedule,
          iconColor: AppColors.menuIconAccent,
          onTap: () async {
            try {
              final currentTimezone =
                  await widget.timezoneService.getSelectedTimezone();
              final selectedTimezone = await showDialog<String>(
                context: context,
                builder: (context) => TimezoneDialog(
                  timezoneService: widget.timezoneService,
                  currentTimezone: currentTimezone,
                ),
              );

              if (selectedTimezone != null &&
                  selectedTimezone != currentTimezone) {
                final timezoneName =
                    widget.timezoneService.getTimezoneName(selectedTimezone);
                Messages.info('Fuso horário alterado para: $timezoneName');
              }
            } catch (e) {
              Messages.alert('Erro ao abrir configurações de fuso horário');
            }
          },
        ),
        MenuItemWidget(
          label: 'Pontuação',
          icon: Icons.leaderboard,
          iconColor: AppColors.menuIconWarning,
          onTap: () async {
            await widget.urlLauncherService.launchURL(
              'https://docs.google.com/spreadsheets/d/1kh4zc2INhLEOGbLqqte8NnP4NsNRvFTgSWvKNKKM9qk/edit?usp=sharing',
            );
          },
        ),
        MenuItemWidget(
          label: 'Discord',
          icon: Icons.discord,
          iconColor: AppColors.menuIconDiscord,
          onTap: () async {
            await widget.urlLauncherService.launchURL(
              'https://discord.gg/udteYpaGuB',
            );
          },
        ),
        MenuItemWidget(
          label: 'Redes Sociais',
          icon: Icons.live_tv_rounded,
          iconColor: AppColors.menuIconTwitch,
          onTap: () async {
            await widget.urlLauncherService.launchURL(
              'https://www.twitch.com/BoostTeam_',
            );
          },
        ),
        MenuItemWidget(
          label: 'Formulário de horários',
          icon: Icons.edit_document,
          iconColor: AppColors.menuIconGoogle,
          onTap: () async {
            await widget.urlLauncherService.launchURL(
              'https://forms.gle/RN4NGWm8Qvi1daqp7',
            );
          },
        ),
        MenuItemWidget(
          label: 'BoostTeam SysWeblurk',
          icon: Icons.edit_document,
          iconColor: AppColors.menuIconGoogleDrive,
          onTap: () async {
            await widget.urlLauncherService.launchURL(
              'https://drive.google.com/drive/folders/1XsmNh_gpKYLEkMSaBPFLuT3Y5vDmeWC3?usp=sharing',
            );
          },
        ),
        MenuItemWidget(
          label: 'Apoie o projeto',
          icon: Icons.card_giftcard_rounded,
          iconColor: AppColors.menuIconWarning,
          onTap: () async {
            await widget.urlLauncherService.launchURL(
              'https://github.com/Barba2k2/boost_sys_weblurk',
            );
          },
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.menuButton,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Text(
              'Menu',
              style: TextStyle(
                color: AppColors.menuItemIcon,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.menu,
              size: 20,
              color: AppColors.menuItemIcon,
            ),
          ],
        ),
      ),
    );
  }
}
