import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBarUserInfo extends StatelessWidget {
  final String username;

  const AppBarUserInfo({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFA162FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_circle,
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            username,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 