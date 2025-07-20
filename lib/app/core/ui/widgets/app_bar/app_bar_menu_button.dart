import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBarMenuButton extends StatelessWidget {
  const AppBarMenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
  });

  final String label;
  final IconData icon;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => items.cast<PopupMenuEntry<String>>(),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
