import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/home/presentation/viewmodels/home_viewmodel.dart';
import 'webview_widget.dart';
import '../app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, // 2 abas fixas: Lista A e Lista B
      vsync: this,
      initialIndex: widget.viewModel.currentTabIndex,
    );
    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (_tabController.index != widget.viewModel.currentTabIndex) {
      _tabController.animateTo(widget.viewModel.currentTabIndex);
    }
    setState(() {});
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
            color: AppColors.cardBackground.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.menuItemIconInactive.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) => widget.viewModel.switchTabCommand.execute(index),
            labelColor: AppColors.tabBarLabel,
            unselectedLabelColor: AppColors.tabBarUnselected,
            indicatorColor: AppColors.tabBarIndicator,
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
              // Aba Lista A
              MyWebviewWidget(
                initialUrl: widget.viewModel.currentTabIndex == 0
                    ? widget.viewModel.currentChannelListA
                    : 'https://twitch.tv/BoostTeam_',
              ),
              // Aba Lista B
              MyWebviewWidget(
                initialUrl: widget.viewModel.currentTabIndex == 1
                    ? widget.viewModel.currentChannelListB
                    : 'https://twitch.tv/BoostTeam_',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
