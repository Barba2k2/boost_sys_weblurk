import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final Future<void> Function(BuildContext) onSelectDate;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: TextEditingController(
                text: DateFormat('dd/MM/yyyy').format(selectedDate),
              ),
              decoration: InputDecoration(
                labelText: 'Data',
                labelStyle: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              readOnly: true,
              onTap: () => onSelectDate(context),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => onSelectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Icon(Icons.calendar_today_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
