import 'package:flutter/material.dart';

import '../../../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../../di/injector.dart';
import '../../logger/app_logger.dart';
import '../app_colors.dart';
import 'webview_widget.dart';

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

    _tabController.addListener(() {
      setState(() {});
    });
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
    final selectedIndex = _tabController.index;
    BorderRadius indicatorRadius = BorderRadius.circular(0);
    if (selectedIndex == 0) {
      indicatorRadius = const BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      );
    } else {
      indicatorRadius = const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      );
    }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.menuButton,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) => widget.viewModel.switchTabCommand.execute(index),
            labelColor: AppColors.menuItemIcon,
            unselectedLabelColor: AppColors.menuItemIconInactive,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.appBar,
              borderRadius: indicatorRadius,
            ),
            labelStyle: const TextStyle(
              fontFamily: 'Ibrand',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 2.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Ibrand',
              fontWeight: FontWeight.w300,
              fontSize: 16,
              letterSpacing: 2.2,
            ),
            tabs: const [
              Tab(text: 'Lista A'),
              Tab(text: 'Lista B'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              MyWebviewWidget(
                key: ValueKey(
                    'webview_lista_a_${widget.viewModel.currentChannelListA}'),
                initialUrl: widget.viewModel.currentChannelListA.isNotEmpty
                    ? widget.viewModel.currentChannelListA
                    : 'https://twitch.tv/BoostTeam_',
                currentUrl: widget.viewModel.currentChannelListA,
                logger: _logger,
                onWebViewCreated: widget.viewModel.onWebViewCreated,
                tabIdentifier: 'listaA',
              ),
              MyWebviewWidget(
                key: ValueKey(
                    'webview_lista_b_${widget.viewModel.currentChannelListB}'),
                initialUrl: widget.viewModel.currentChannelListB.isNotEmpty
                    ? widget.viewModel.currentChannelListB
                    : 'https://twitch.tv/BoostTeam_',
                currentUrl: widget.viewModel.currentChannelListB,
                logger: _logger,
                onWebViewCreated: widget.viewModel.onWebViewCreated,
                tabIdentifier: 'listaB',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
