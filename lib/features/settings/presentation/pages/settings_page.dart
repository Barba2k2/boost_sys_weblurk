import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/ui/app_colors.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.viewModel,
  });

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVolumeSection(),
          const SizedBox(height: 24),
          _buildUrlSection(),
        ],
      ),
    );
  }

  Widget _buildVolumeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Controle de Volume',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Slider de volume
            ListenableBuilder(
              listenable: viewModel,
              builder: (context, child) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          viewModel.isMuted
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: viewModel.isMuted
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: viewModel.currentVolume,
                            divisions: 10,
                            label:
                                '${(viewModel.currentVolume * 100).round()}%',
                            onChanged: (value) {
                              viewModel.setVolumeCommand.execute(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    // Botão de mute/unmute
                    ListenableBuilder(
                      listenable: viewModel.toggleMuteCommand,
                      builder: (context, child) {
                        final command = viewModel.toggleMuteCommand;

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: command.running
                                ? null
                                : () => command.execute(),
                            icon: command.running
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Icon(viewModel.isMuted
                                    ? Icons.volume_up
                                    : Icons.volume_off),
                            label: Text(
                              command.running
                                  ? 'Processando...'
                                  : viewModel.isMuted
                                      ? 'Desmutar'
                                      : 'Mutar',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Links Úteis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUrlButton(
              'Twitch Boost Team',
              'https://twitch.tv/BoostTeam_',
              Icons.live_tv,
            ),
            const SizedBox(height: 8),
            _buildUrlButton(
              'GitHub do Projeto',
              'https://github.com/boostteam/boost_sys_weblurk',
              Icons.code,
            ),
            const SizedBox(height: 8),
            _buildUrlButton(
              'Documentação',
              'https://docs.boostteam.com',
              Icons.description,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlButton(String title, String url, IconData icon) {
    return ListenableBuilder(
      listenable: viewModel.launchUrlCommand,
      builder: (context, child) {
        final command = viewModel.launchUrlCommand;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: command.running ? null : () => command.execute(url),
            icon: command.running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon),
            label: Text(title),
            style: ElevatedButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
          ),
        );
      },
    );
  }
}
