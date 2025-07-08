import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../modules/core/auth/home/home_controller.dart';
import 'schedule_table.dart';

class ScheduleTabsWidget extends StatefulWidget {
  const ScheduleTabsWidget({super.key});

  @override
  State<ScheduleTabsWidget> createState() => _ScheduleTabsWidgetState();
}

class _ScheduleTabsWidgetState extends State<ScheduleTabsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final homeController = Modular.get<HomeController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, // 2 abas fixas: Lista A e Lista B
      vsync: this,
      initialIndex: homeController.currentTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Column(
          children: [
            // TabBar
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) => homeController.switchTab(index),
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
                isScrollable: false,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                tabs: const [
                  Tab(text: 'Lista A', iconMargin: EdgeInsets.zero),
                  Tab(text: 'Lista B', iconMargin: EdgeInsets.zero),
                ],
                labelPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Aba Lista A
                  Observer(
                    builder: (_) => ScheduleTable(
                      schedules: homeController.listaASchedules,
                      listName: 'Lista A',
                    ),
                  ),
                  // Aba Lista B
                  Observer(
                    builder: (_) => ScheduleTable(
                      schedules: homeController.listaBSchedules,
                      listName: 'Lista B',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
