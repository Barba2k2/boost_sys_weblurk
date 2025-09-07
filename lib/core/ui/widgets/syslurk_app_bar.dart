import 'package:flutter/material.dart';
import '../../../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../../services/settings_service.dart';
import '../../services/timezone_service.dart';
import '../../services/url_launcher_service.dart';
import '../../services/volume_service.dart';
import '../app_colors.dart';
import 'combined_menu_button.dart';

class SyslurkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeViewModel viewModel;
  final SettingsService settingsService;
  final TimezoneService timezoneService;
  final UrlLauncherService urlLauncherService;
  final VolumeService volumeService;
  final String? username;

  const SyslurkAppBar({
    super.key,
    required this.viewModel,
    required this.settingsService,
    required this.timezoneService,
    required this.urlLauncherService,
    required this.volumeService,
    this.username,
  });

  String _extractChannelName(String url) {
    try {
      if (url.contains('twitch.tv/')) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          return pathSegments.first;
        }
      }
      return 'BoostTeam_';
    } catch (e) {
      return 'BoostTeam_';
    }
  }

  Future<String> _getTimezoneDisplay() async {
    try {
      final selectedTimezone = await timezoneService.getSelectedTimezone();
      final systemTimezone = timezoneService.getSystemTimezone();

      // Only show timezone if it's different from system timezone
      if (selectedTimezone != systemTimezone) {
        return timezoneService.getTimezoneName(selectedTimezone);
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBar,
        boxShadow: [
          BoxShadow(
            color: AppColors.menuItemIconInactive.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CombinedMenuButton(
              viewModel: viewModel,
              settingsService: settingsService,
              timezoneService: timezoneService,
              urlLauncherService: urlLauncherService,
              volumeService: volumeService,
            ),
            const SizedBox(width: 16),
            Image.asset(
              'assets/images/logo-cla-boost.png',
              height: 32,
            ),
            const SizedBox(width: 16),
            ListenableBuilder(
              listenable: viewModel,
              builder: (context, child) {
                final channelName =
                    _extractChannelName(viewModel.currentChannel);
                return Text(
                  'Canal: $channelName',
                  style: const TextStyle(
                    color: AppColors.menuItemIcon,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          // Timezone display (outside and to the left)
          ListenableBuilder(
            listenable: timezoneService,
            builder: (context, child) {
              return FutureBuilder<String>(
                future: _getTimezoneDisplay(),
                builder: (context, snapshot) {
                  final timezoneDisplay = snapshot.data ?? '';
                  if (timezoneDisplay.isEmpty) return const SizedBox.shrink();
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      timezoneDisplay,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Username display
          if (username != null)
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.menuButtonActive,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 20,
                    color: AppColors.menuItemIcon,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    username!,
                    style: const TextStyle(
                      color: AppColors.menuItemIcon,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
