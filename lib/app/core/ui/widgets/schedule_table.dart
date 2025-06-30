import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../modules/core/auth/home/home_controller.dart';

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
    final homeController = Modular.get<HomeController>();

    return Observer(
      builder: (_) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          color: Colors.white.withOpacity(0.8),
          child: Column(
            children: [
              // Header da lista
              Container(
                padding: const EdgeInsets.all(16),
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
                              'Seq.',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nome do Streamer',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Horário',
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
                              'Link do Canal',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
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
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      streamer['nome_do_streamer'] ?? '',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      streamer['horario'] ?? '',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      streamer['data'] ?? '',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      streamer['link_do_canal'] ?? '',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _getStatusText(streamer['status'] ?? 0),
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0,
                                        color: Colors.black,
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

  Color? _getRowColor(Map<String, dynamic> streamer) {
    // Implementar lógica de cor baseada no status ou outros critérios
    final status = streamer['status'] ?? 0;

    switch (status) {
      case 1: // Ativo
        return Colors.green.withOpacity(0.1);
      case 2: // Pendente
        return Colors.orange.withOpacity(0.1);
      case 3: // Cancelado
        return Colors.red.withOpacity(0.1);
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
