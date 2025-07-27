import 'package:flutter/material.dart';
import '../app_colors.dart';

class LiveUrlBar extends StatelessWidget {
  const LiveUrlBar({
    required this.currentChannel,
    super.key,
  });

  final String? currentChannel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: AppColors.primary.withValues(alpha: 0.7),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          currentChannel ?? 'https://www.twitch.tv/BootTeam_',
          style: const TextStyle(
            fontSize: 16.0,
            color: AppColors.cardHeaderText,
          ),
        ),
      ),
    );
  }
}
