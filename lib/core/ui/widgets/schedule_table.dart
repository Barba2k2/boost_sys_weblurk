import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class ScheduleTable extends StatelessWidget {
  const ScheduleTable({
    super.key,
    required this.schedules,
    required this.listName,
  });

  final List<Map<String, dynamic>> schedules;
  final String listName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        color: AppColors.cardBackground.withValues(alpha: 0.8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.cardHeader,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: AppColors.cardHeaderText,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    listName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: AppColors.cardHeaderText,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${schedules.length} agendamentos',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                      color: AppColors.cardHeaderSubText,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: schedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: AppColors.menuItemIconInactive
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum agendamento nesta lista',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.menuItemIconInactive
                                  .withValues(alpha: 0.6),
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
                            'Seq.',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: AppColors.menuItemIconInactive,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nome do Streamer',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: AppColors.menuItemIconInactive,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Horário',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: AppColors.menuItemIconInactive,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Data',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: AppColors.menuItemIconInactive,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Link do Canal',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: AppColors.menuItemIconInactive,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: AppColors.menuItemIconInactive,
                            ),
                          ),
                        ),
                      ],
                      rows: schedules
                          .map(
                            (streamer) => DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) =>
                                    _getRowColor(streamer),
                              ),
                              cells: [
                                DataCell(
                                  Text(
                                    streamer['seq']?.toString() ?? '',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      color: AppColors.menuItemIconInactive,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    streamer['nome_do_streamer'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      color: AppColors.menuItemIconInactive,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    streamer['horario'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      color: AppColors.menuItemIconInactive,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    streamer['data'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      color: AppColors.menuItemIconInactive,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    streamer['link_do_canal'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      color: AppColors.menuItemIconInactive,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _getStatusText(streamer['status'] ?? 0),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      color: AppColors.menuItemIconInactive,
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
    );
  }

  Color? _getRowColor(Map<String, dynamic> streamer) {
    final status = streamer['status'] ?? 0;
    switch (status) {
      case 1:
        return AppColors.scheduleRowActive;
      case 2:
        return AppColors.scheduleRowPending;
      case 3:
        return AppColors.scheduleRowCancelled;
      default:
        return null;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Ativo';
      case 2:
        return 'Pendente';
      case 3:
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }
}
