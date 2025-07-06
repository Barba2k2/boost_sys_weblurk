import 'package:flutter/material.dart';

class AppBarMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const AppBarMenuItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      value: label,
      child: Builder(
        builder: (context) => ListTile(
          leading: Icon(icon, color: const Color(0xFF2C1F4A)),
          title: Text(label),
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            onTap();
          },
        ),
      ),
    );
  }
} 