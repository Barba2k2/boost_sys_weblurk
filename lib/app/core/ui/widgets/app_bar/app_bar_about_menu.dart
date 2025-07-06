import 'package:flutter/material.dart';
import 'app_bar_menu_button.dart';
import 'app_bar_menu_item.dart';
import '../messages/messages.dart';

class AppBarAboutMenu extends StatelessWidget {
  const AppBarAboutMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarMenuButton(
      label: 'Sobre',
      icon: Icons.info_outline_rounded,
      items: [
        AppBarMenuItem(
          label: 'Sobre o Weblurk',
          icon: Icons.leaderboard,
          onTap: () async {
            Messages.info('Em breve!');
          },
        ),
      ],
    );
  }
} 