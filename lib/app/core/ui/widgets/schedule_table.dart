import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/schedule_model.dart';

class ScheduleTable extends StatelessWidget {
  const ScheduleTable({
    super.key,
    required this.schedules,
    required this.listName,
  });

  final List<ScheduleModel> schedules;
  final String listName;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          color: Colors.white.withValues(alpha: 0.8),
          child: Column(
            children: [
              // Header da lista
              Container(
                // padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C1F4A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      listName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${schedules.length} agendamentos',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.0,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Tabela
              Expanded(
                child: schedules.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum agendamento nesta lista',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : DataTable(
                        border: TableBorder.all(),
                        columns: [
                          DataColumn(
                            label: Text(
                              'ID',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Streamer',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Data',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Início',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Fim',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Link',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                        rows: schedules
                            .map(
                              (schedule) => DataRow(
                                cells: [
                                  DataCell(Text(schedule.id?.toString() ?? '')),
                                  DataCell(Text(schedule.streamerUrl)),
                                  DataCell(
                                      Text(schedule.date.toIso8601String())),
                                  DataCell(Text(schedule.startTime)),
                                  DataCell(Text(schedule.endTime)),
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        // abrir link
                                      },
                                      child: Text(
                                        schedule.streamerUrl,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
