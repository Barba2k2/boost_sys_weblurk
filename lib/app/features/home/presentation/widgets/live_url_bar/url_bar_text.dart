import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UrlBarText extends StatelessWidget {
  const UrlBarText({
    super.key,
    required this.currentChannel,
  });

  final String? currentChannel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        currentChannel ?? 'https://www.twitch.tv/BootTeam_',
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
