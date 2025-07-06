import 'package:flutter/material.dart';
import '../../controllers/url_launch_controller.dart';
import 'app_bar_menu_button.dart';
import 'app_bar_menu_item.dart';
import '../messages/messages.dart';

class AppBarOptionsMenu extends StatelessWidget {
  final VoidCallback onReloadWebView;
  final VoidCallback onTerminateApp;
  final VoidCallback? onToggleMute;
  final bool isMuted;

  const AppBarOptionsMenu({
    super.key,
    required this.onReloadWebView,
    required this.onTerminateApp,
    this.onToggleMute,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBarMenuButton(
      label: 'Opções',
      icon: Icons.menu,
      items: [
        AppBarMenuItem(
          label: 'Atualizar Listas',
          icon: Icons.refresh,
          onTap: onReloadWebView,
        ),
        if (onToggleMute != null)
          AppBarMenuItem(
            label: isMuted ? 'Desmutar WebView' : 'Mutar WebView',
            icon: isMuted ? Icons.volume_up : Icons.volume_off,
            onTap: onToggleMute!,
          ),
        AppBarMenuItem(
          label: 'Encerrar',
          icon: Icons.power_settings_new,
          onTap: onTerminateApp,
        ),
        AppBarMenuItem(
          label: 'Fuso Horário',
          icon: Icons.schedule,
          onTap: () {
            Messages.info('Funcionalidade ainda não funcional');
          },
        ),
      ],
    );
  }
} 