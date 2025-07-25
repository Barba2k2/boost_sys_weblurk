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
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.menuItemIconInactive,
              ),
              const SizedBox(width: 10),
              Text(label),
            ],
          ),
        );
}
