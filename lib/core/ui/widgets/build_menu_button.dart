import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class BuildMenuButton extends StatelessWidget {
  const BuildMenuButton({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.menuButton,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.menuItemIcon,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              icon,
              size: 20,
              color: AppColors.menuItemIcon,
            ),
          ],
        ),
      ),
    );
  }
}
