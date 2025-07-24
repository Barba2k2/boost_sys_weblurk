// lib/core/ui/widgets/schedule_tabs_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/home/presentation/viewmodels/home_viewmodel.dart';
import 'webview_widget.dart';
import '../../di/injector.dart';
import '../../logger/app_logger.dart';

class ScheduleTabsWidget extends StatefulWidget {
  const ScheduleTabsWidget({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  State<ScheduleTabsWidget> createState() => _ScheduleTabsWidgetState();
}

class _ScheduleTabsWidgetState extends State<ScheduleTabsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AppLogger _logger;

  @override
  void initState() {
    super.initState();
    _logger = injector<AppLogger>();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.viewModel.currentTabIndex,
    );

    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted && _tabController.index != widget.viewModel.currentTabIndex) {
      _tabController.animateTo(widget.viewModel.currentTabIndex);
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230), // ~90%
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25), // 10%
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) => widget.viewModel.switchTabCommand.execute(index),
            labelColor: const Color(0xFF2C1F4A),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: const Color(0xFF2C1F4A),
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Lista A'),
              Tab(text: 'Lista B'),
            ],
          ),
        ),

        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              MyWebviewWidget(
                key: const ValueKey('webview_lista_a'),
                initialUrl: widget.viewModel.currentChannelListA.isNotEmpty
                    ? widget.viewModel.currentChannelListA
                    : 'https://twitch.tv/BoostTeam_',
                currentUrl: widget.viewModel.currentChannelListA,
                logger: _logger,
              ),
              MyWebviewWidget(
                key: const ValueKey('webview_lista_b'),
                initialUrl: widget.viewModel.currentChannelListB.isNotEmpty
                    ? widget.viewModel.currentChannelListB
                    : 'https://twitch.tv/BoostTeam_',
                currentUrl: widget.viewModel.currentChannelListB,
                logger: _logger,
              ),
            ],
          ),
        ),
      ],
    );
  }
}