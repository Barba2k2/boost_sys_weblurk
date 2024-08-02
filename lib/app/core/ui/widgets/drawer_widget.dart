import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 400,
      child: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          ListTile(
            title: Text(
              'Painel de Agendamento',
              style: GoogleFonts.poppins(
                fontSize: 22,
              ),
            ),
            leading: const Icon(
              Icons.home_rounded,
              size: 30,
              color: Colors.black54,
            ),
            onTap: () => Modular.to.navigate('/home/'),
          ),
          ListTile(
            title: Text(
              'Cadastrar Streamer',
              style: GoogleFonts.poppins(
                fontSize: 22,
              ),
            ),
            leading: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 30,
              color: Colors.black54,
            ),
            onTap: () => Modular.to.navigate('/add-user/'),
          ),
          ListTile(
            title: Text(
              'Streamers Status',
              style: GoogleFonts.poppins(
                fontSize: 22,
              ),
            ),
            leading: const Icon(
              Icons.signal_cellular_alt_rounded,
              size: 30,
              color: Colors.black54,
            ),
            onTap: () => Modular.to.navigate('/streamers-status/'),
          ),
          ListTile(
            title: Text(
              'Pontuacao',
              style: GoogleFonts.poppins(
                fontSize: 22,
              ),
            ),
            leading: const Icon(
              Icons.settings_input_antenna_rounded,
              size: 30,
              color: Colors.black54,
            ),
            onTap: () => Modular.to.navigate('/scores/'),
          ),
          ListTile(
            title: Text(
              'Sair',
              style: GoogleFonts.poppins(
                fontSize: 22,
              ),
            ),
            leading: const Icon(
              CupertinoIcons.escape,
              size: 30,
              color: Colors.black54,
            ),
            onTap: () => Modular.to.navigate('/auth/login/'),
          ),
        ],
      ),
    );
  }
}
