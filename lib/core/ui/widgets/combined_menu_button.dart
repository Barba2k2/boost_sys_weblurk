import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../../services/settings_service.dart';
import '../../services/url_launcher_service.dart';
import '../../services/volume_service.dart';
import '../widgets/messages.dart';
import '../app_colors.dart';
import 'menu_item_widget.dart'; // Will be created next

class CombinedMenuButton extends StatelessWidget {
  final HomeViewModel viewModel;
  final SettingsService settingsService;
  final UrlLauncherService urlLauncherService;
  final VolumeService volumeService;

  const CombinedMenuButton({
    super.key,
    required this.viewModel,
    required this.settingsService,
    required this.urlLauncherService,
    required this.volumeService,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => [
        MenuItemWidget(
          label: 'Atualizar Listas',
          icon: Icons.refresh,
          onTap: () {
            viewModel.reloadWebView();
          },
        ),
        MenuItemWidget(
          label: 'Encerrar',
          icon: Icons.power_settings_new,
          onTap: () {
            settingsService.terminateApp();
          },
        ),
        PopupMenuItem<String>(
          child: PopupMenuButton<String>(
            offset: const Offset(150, 0),
            child: const Row(
              children: [
                Icon(
                  Icons.volume_up,
                  size: 20,
                  color: AppColors.menuItemIconInactive,
                ),
                SizedBox(width: 10),
                Text('Audio'),
                SizedBox(width: 40),
                Icon(Icons.arrow_right),
              ],
            ),
            itemBuilder: (context) {
              final isMuted = volumeService.isMuted;
              return [
                PopupMenuItem<String>(
                  value: 'muted',
                  child: Row(
                    children: [
                      if (isMuted)
                        const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.green,
                        ),
                      if (!isMuted) const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      const Text('Mutado'),
                    ],
                  ),
                  onTap: () {
                    volumeService.mute();
                  },
                ),
                PopupMenuItem<String>(
                  value: 'unmuted',
                  child: Row(
                    children: [
                      if (!isMuted)
                        const Icon(Icons.check, size: 18, color: Colors.green),
                      if (isMuted) const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      const Text('Desmutado'),
                    ],
                  ),
                  onTap: () {
                    volumeService.unmute();
                  },
                ),
              ];
            },
          ),
        ),
        MenuItemWidget(
          label: 'Fuso Horário',
          icon: Icons.schedule,
          onTap: () {
            Messages.info('Funcionalidade ainda não funcional');
          },
        ),
        // Links
        MenuItemWidget(
          label: 'Pontuação',
          icon: Icons.leaderboard,
          onTap: () async {
            await urlLauncherService.launchURL(
              'https://docs.google.com/spreadsheets/d/1kh4zc2INhLEOGbLqqte8NnP4NsNRvFTgSWvKNKKM9qk/edit?usp=sharing',
            );
          },
        ),
        MenuItemWidget(
          label: 'Discord',
          icon: Icons.discord,
          onTap: () async {
            await urlLauncherService.launchURL(
              'https://discord.gg/udteYpaGuB',
            );
          },
        ),
        MenuItemWidget(
          label: 'Redes Sociais',
          icon: Icons.live_tv_rounded,
          onTap: () async {
            await urlLauncherService.launchURL(
              'https://www.twitch.com/BoostTeam_',
            );
          },
        ),
        MenuItemWidget(
          label: 'Formulário de horários',
          icon: Icons.edit_document,
          onTap: () async {
            await urlLauncherService.launchURL(
              'https://forms.gle/RN4NGWm8Qvi1daqp7',
            );
          },
        ),
        MenuItemWidget(
          label: 'BoostTeam SysWeblurk',
          icon: Icons.edit_document,
          onTap: () async {
            await urlLauncherService.launchURL(
              'https://drive.google.com/drive/folders/1XsmNh_gpKYLEkMSaBPFLuT3Y5vDmeWC3?usp=sharing',
            );
          },
        ),
        // Sobre
        MenuItemWidget(
          label: 'Sobre o Weblurk',
          icon: Icons.leaderboard,
          onTap: () async {
            Messages.info('Em breve!');
          },
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.menuButton,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              'Menu',
              style: GoogleFonts.inter(
                color: AppColors.menuItemIcon,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
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
