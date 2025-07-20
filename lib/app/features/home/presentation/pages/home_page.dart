import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/result.dart';
import '../../../../models/schedule_model.dart';
import '../viewmodels/home_viewmodel.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    super.key,
    required this.viewModel,
  });
  final HomeViewModel viewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
    widget.viewModel.loadSchedulesCommand.execute();
    widget.viewModel.fetchCurrentChannelCommand.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boost System'),
        actions: [
          // Botão de configurações
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
          ),
          // Botão de logout
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _handleLogout(context),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Card de informações do usuário
          _buildUserInfoCard(),

          // Tabs para Lista A e Lista B
          _buildTabBar(),

          // Conteúdo das tabs
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildUserInfoCard() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final user = widget.viewModel.userLogged;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo, ${user?.nickname ?? 'Usuário'}!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Status: ${user?.status ?? 'offline'}',
                        style: TextStyle(
                          color: user?.status == 'online'
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return TabBar(
          onTap: (index) => widget.viewModel.switchTabCommand.execute(index),
          tabs: const [
            Tab(text: 'Lista A'),
            Tab(text: 'Lista B'),
          ],
        );
      },
    );
  }

  Widget _buildTabContent() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel,
        widget.viewModel.loadSchedulesCommand,
      ]),
      builder: (context, child) {
        final command = widget.viewModel.loadSchedulesCommand;

        if (command.running) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (command.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar agendamentos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  command.result?.errorOrNull?.toString() ??
                      'Erro desconhecido',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      widget.viewModel.loadSchedulesCommand.execute(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final schedules = widget.viewModel.currentListSchedules;
        final listName = widget.viewModel.currentListName;

        if (schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.schedule,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum agendamento encontrado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Lista: $listName'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleCard(schedule);
          },
        );
      },
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.live_tv),
        ),
        title: Text(
          schedule.streamerUrl.isNotEmpty
              ? schedule.streamerUrl.split('/').last
              : 'Canal não definido',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${schedule.date.toString().split(' ')[0]}'),
            Text('Horário: ${schedule.startTime} - ${schedule.endTime}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => _openChannel(schedule.streamerUrl),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ListenableBuilder(
      listenable: widget.viewModel.loadSchedulesCommand,
      builder: (context, child) {
        final command = widget.viewModel.loadSchedulesCommand;

        return FloatingActionButton(
          onPressed: command.running
              ? null
              : () => widget.viewModel.loadSchedulesCommand.execute(),
          child: command.running
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.refresh),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.login);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _openChannel(String url) {
    if (url.isNotEmpty) {
      // Aqui você implementaria a lógica para abrir o canal
      // Por enquanto, apenas mostra um snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abrindo canal: $url'),
        ),
      );
    }
  }
}
