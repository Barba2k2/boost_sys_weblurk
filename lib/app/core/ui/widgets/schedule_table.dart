// import 'package:flutter/material.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:flutter_modular/flutter_modular.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../modules/core/auth/home/home_controller.dart';

// class ScheduleTable extends StatelessWidget {
//   const ScheduleTable({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final homeController = Modular.get<HomeController>();

//     return Observer(
//       builder: (_) => Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           color: Colors.white.withOpacity(0.8),
//           child: DataTable(
//             border: TableBorder.all(
//               color: Colors.black,
//               width: 1.0,
//             ),
//             columns: [
//               DataColumn(
//                 label: Text(
//                   'Seq.',
//                   style: GoogleFonts.inter(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.0,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               DataColumn(
//                 label: Text(
//                   'Nome do Streamer',
//                   style: GoogleFonts.inter(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.0,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               DataColumn(
//                 label: Text(
//                   'Horário',
//                   style: GoogleFonts.inter(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.0,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               DataColumn(
//                 label: Text(
//                   'Data',
//                   style: GoogleFonts.inter(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.0,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               DataColumn(
//                 label: Text(
//                   'Link do Canal',
//                   style: GoogleFonts.inter(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.0,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               DataColumn(
//                 label: Text(
//                   'Status',
//                   style: GoogleFonts.inter(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.0,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//             rows: homeController.schedule
//                 .map(
//                   (streamer) => DataRow(
//                     color: WidgetStateProperty.resolveWith<Color?>(
//                       (Set<WidgetState> states) =>
//                           homeController.getRowColor(streamer),
//                     ),
//                     cells: [
//                       DataCell(
//                         Text(
//                           streamer['seq'].toString(),
//                           style: GoogleFonts.inter(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 12.0,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       DataCell(
//                         Text(
//                           streamer['nome_do_streamer'] ?? '',
//                           style: GoogleFonts.inter(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 12.0,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       DataCell(
//                         Text(
//                           streamer['horario'] ?? '',
//                           style: GoogleFonts.inter(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 12.0,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       DataCell(
//                         Text(
//                           streamer['data'] ?? '',
//                           style: GoogleFonts.inter(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 12.0,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       DataCell(
//                         Text(
//                           streamer['link_do_canal'] ?? '',
//                           style: GoogleFonts.inter(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 12.0,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       DataCell(
//                         Text(
//                           homeController.getStatusText(
//                             streamer['status'] ?? 0,
//                           ),
//                           style: GoogleFonts.inter(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 12.0,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//                 .toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }
