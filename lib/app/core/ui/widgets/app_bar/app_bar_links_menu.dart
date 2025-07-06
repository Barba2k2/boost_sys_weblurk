import 'package:flutter/material.dart';
import '../../controllers/url_launch_controller.dart';
import 'app_bar_menu_button.dart';
import 'app_bar_menu_item.dart';

class AppBarLinksMenu extends StatelessWidget {
  final UrlLaunchController urlController;

  const AppBarLinksMenu({
    super.key,
    required this.urlController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBarMenuButton(
      label: 'Links',
      icon: Icons.link,
      items: [
        AppBarMenuItem(
          label: 'Pontuação',
          icon: Icons.leaderboard,
          onTap: () async {
            await urlController.launchURL(
              'https://docs.google.com/spreadsheets/d/1kh4zc2INhLEOGbLqqte8NnP4NsNRvFTgSWvKNKKM9qk/edit?usp=sharing',
            );
          },
        ),
        AppBarMenuItem(
          label: 'Discord',
          icon: Icons.discord,
          onTap: () async {
            await urlController.launchURL(
              'https://discord.gg/udteYpaGuB',
            );
          },
        ),
        AppBarMenuItem(
          label: 'Redes Sociais',
          icon: Icons.live_tv_rounded,
          onTap: () async {
            await urlController.launchURL(
              'https://www.twitch.com/BoostTeam_',
            );
          },
        ),
        AppBarMenuItem(
          label: 'Formulário de horários',
          icon: Icons.edit_document,
          onTap: () async {
            await urlController.launchURL(
              'https://forms.gle/RN4NGWm8Qvi1daqp7',
            );
          },
        ),
        AppBarMenuItem(
          label: 'BoostTeam SysWeblurk',
          icon: Icons.edit_document,
          onTap: () async {
            await urlController.launchURL(
              'https://drive.google.com/drive/folders/1XsmNh_gpKYLEkMSaBPFLuT3Y5vDmeWC3?usp=sharing',
            );
          },
        ),
      ],
    );
  }
} 