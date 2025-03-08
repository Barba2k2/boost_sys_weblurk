import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../modules/core/auth/auth_store.dart';
import '../../../modules/core/auth/home/home_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/url_launch_controller.dart';
import 'messages.dart';

class SyslurkAppBar extends StatelessWidget implements PreferredSizeWidget {
  SyslurkAppBar({super.key});
  
  final urlController = Modular.get<UrlLaunchController>();
  final homeController = Modular.get<HomeController>();
  final settingsController = Modular.get<SettingsController>();
  final authStore = Modular.get<AuthStore>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C1F4A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo-cla-boost.png',
              height: 32,
            ),
            const SizedBox(width: 16),
            _buildMenuButton(
              'Opções',
              Icons.menu,
              [
                _buildMenuItem(
                  'Atualizar Listas',
                  Icons.refresh,
                  () {
                    // homeController.loadSchedules();
                    homeController.reloadWebView();
                  },
                ),
                _buildMenuItem(
                  'Encerrar',
                  Icons.power_settings_new,
                  () {
                    settingsController.terminateApp();
                  },
                ),
                _buildMenuItem(
                  'Audio',
                  Icons.volume_up,
                  () {
                    settingsController.muteAppAudio();
                  },
                ),
                _buildMenuItem(
                  'Fuso Horário',
                  Icons.schedule,
                  () {
                    Messages.info('Funcionalidade ainda não funcional');
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
            _buildMenuButton(
              'Links',
              Icons.link,
              [
                _buildMenuItem(
                  'Pontuação',
                  Icons.leaderboard,
                  () async {
                    await urlController.launchURL(
                      'https://docs.google.com/spreadsheets/d/1kh4zc2INhLEOGbLqqte8NnP4NsNRvFTgSWvKNKKM9qk/edit?usp=sharing',
                    );
                  },
                ),
                _buildMenuItem(
                  'Discord',
                  Icons.discord,
                  () async {
                    await urlController.launchURL(
                      'https://discord.gg/udteYpaGuB',
                    );
                  },
                ),
                _buildMenuItem(
                  'Redes Sociais',
                  Icons.live_tv_rounded,
                  () async {
                    await urlController.launchURL(
                      'https://www.twitch.com/BoostTeam_',
                    );
                  },
                ),
                _buildMenuItem(
                  'Formulário de horários',
                  Icons.edit_document,
                  () async {
                    await urlController.launchURL(
                      'https://forms.gle/RN4NGWm8Qvi1daqp7',
                    );
                  },
                ),
                _buildMenuItem(
                  'BoostTeam SysWeblurk',
                  Icons.edit_document,
                  () async {
                    await urlController.launchURL(
                      'https://drive.google.com/drive/folders/1XsmNh_gpKYLEkMSaBPFLuT3Y5vDmeWC3?usp=sharing',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
            _buildMenuButton(
              'Sobre',
              Icons.info_outline_rounded,
              [
                _buildMenuItem(
                  'Sobre o Weblurk',
                  Icons.leaderboard,
                  () async {
                    // await urlController.launchURL(
                    //   'https://docs.google.com/spreadsheets/d/1kh4zc2INhLEOGbLqqte8NnP4NsNRvFTgSWvKNKKM9qk/edit?usp=sharing',
                    // );
                    Messages.info('Em breve!');
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          Observer(
            builder: (_) {
              final username = authStore.userLogged?.nickname;
              if (username != null) {
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA162FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        username,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    String label,
    IconData icon,
    List<PopupMenuItem<String>> items,
  ) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => items,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return PopupMenuItem<String>(
      value: label,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
