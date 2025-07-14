import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../modules/core/auth/auth_store.dart';
import '../../../modules/core/auth/home/home_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/url_launch_controller.dart';
import 'build_menu_button.dart';
import 'build_menu_item.dart';
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
            BuildMenuButton(
              label: 'Opções',
              icon: Icons.menu,
              items: [
                BuildMenuItem(
                  label: 'Atualizar Listas',
                  icon: Icons.refresh,
                  onTap: () {
                    // homeController.loadSchedules();
                    homeController.reloadWebView();
                  },
                ),
                BuildMenuItem(
                  label: 'Encerrar',
                  icon: Icons.power_settings_new,
                  onTap: () {
                    settingsController.terminateApp();
                  },
                ),
                BuildMenuItemReactive(
                  onTap: () {
                    settingsController.muteAppAudio();
                  },
                  builder: () {
                    return Observer(
                      builder: (_) {
                        final isMuted =
                            settingsController.isAudioCurrentlyMuted;
                        return Row(
                          children: [
                            Icon(
                              isMuted ? Icons.volume_off : Icons.volume_up,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(isMuted ? 'Desmutar Áudio' : 'Mutar Áudio'),
                          ],
                        );
                      },
                    );
                  },
                ),
                BuildMenuItem(
                  label: 'Fuso Horário',
                  icon: Icons.schedule,
                  onTap: () {
                    Messages.info('Funcionalidade ainda não funcional');
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
            BuildMenuButton(
              label: 'Links',
              icon: Icons.link,
              items: [
                BuildMenuItem(
                  label: 'Pontuação',
                  icon: Icons.leaderboard,
                  onTap: () async {
                    await urlController.launchURL(
                      'https://docs.google.com/spreadsheets/d/1kh4zc2INhLEOGbLqqte8NnP4NsNRvFTgSWvKNKKM9qk/edit?usp=sharing',
                    );
                  },
                ),
                BuildMenuItem(
                  label: 'Discord',
                  icon: Icons.discord,
                  onTap: () async {
                    await urlController.launchURL(
                      'https://discord.gg/udteYpaGuB',
                    );
                  },
                ),
                BuildMenuItem(
                  label: 'Redes Sociais',
                  icon: Icons.live_tv_rounded,
                  onTap: () async {
                    await urlController.launchURL(
                      'https://www.twitch.com/BoostTeam_',
                    );
                  },
                ),
                BuildMenuItem(
                  label: 'Formulário de horários',
                  icon: Icons.edit_document,
                  onTap: () async {
                    await urlController.launchURL(
                      'https://forms.gle/RN4NGWm8Qvi1daqp7',
                    );
                  },
                ),
                BuildMenuItem(
                  label: 'BoostTeam SysWeblurk',
                  icon: Icons.edit_document,
                  onTap: () async {
                    await urlController.launchURL(
                      'https://drive.google.com/drive/folders/1XsmNh_gpKYLEkMSaBPFLuT3Y5vDmeWC3?usp=sharing',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
            BuildMenuButton(
              label: 'Sobre',
              icon: Icons.info_outline_rounded,
              items: [
                BuildMenuItem(
                  label: 'Sobre o Weblurk',
                  icon: Icons.leaderboard,
                  onTap: () async {
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
