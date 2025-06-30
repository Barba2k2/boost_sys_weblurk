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
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                  const ScheduleTable(
                    schedules: [],
                    listName: 'Lista A',
                  ),
                  // Aba Lista B
                  const ScheduleTable(
                    schedules: [],
                    listName: 'Lista B',
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
