import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/schedule_entity.dart';
import 'schedule_table.dart';

class ScheduleTabsWidget extends StatefulWidget {
  const ScheduleTabsWidget({
    super.key,
    required this.listaASchedules,
    required this.listaBSchedules,
  });

  final List<ScheduleEntity> listaASchedules;
  final List<ScheduleEntity> listaBSchedules;

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
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
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
            labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ScheduleTable(
                schedules: widget.listaASchedules,
                listName: 'Lista A',
              ),
              ScheduleTable(
                schedules: widget.listaBSchedules,
                listName: 'Lista B',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
