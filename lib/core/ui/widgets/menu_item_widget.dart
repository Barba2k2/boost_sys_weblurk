import 'package:flutter/material.dart';
import '../app_colors.dart';

class MenuItemWidget extends PopupMenuItem<String> {
  MenuItemWidget({
    super.key,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) : super(
          value: label,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppColors.cosmicAccent,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Ibrand',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
}
