import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveUrlBar extends StatelessWidget {
  const LiveUrlBar({
    required this.currentChannel,
    super.key,
  });

  final String? currentChannel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: Colors.purple[300],
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          currentChannel ?? 'https://www.twitch.tv/BootTeam_',
          style: GoogleFonts.inter(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
