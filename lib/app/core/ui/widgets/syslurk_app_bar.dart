import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/url_launch_controller.dart';

class SyslurkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SyslurkAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // final urlController = Modular.get<UrlController>();

    return AppBar(
      backgroundColor: Colors.grey[200],
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'update_list') {
                // Get.find<HomeController>().updateLists();
              } else if (value == 'terminate') {
                // Get.find<HomeController>().terminate();
              } else if (value == 'audio') {
                // Get.find<HomeController>().toggleAudio();
              } else if (value == 'timezone') {
                // Future feature, no action needed now
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'update_list',
                  child: const Text('Atualizar Listas'),
                  onTap: () {
                    // Get.find<HomeController>().updateLists();
                  },
                ),
                PopupMenuItem<String>(
                  value: 'terminate',
                  child: const Text('Encerrar'),
                  onTap: () {
                    // Get.find<HomeController>().terminate();
                  },
                ),
                PopupMenuItem<String>(
                  value: 'audio',
                  child: const Text('Audio'),
                  onTap: () {
                    // Get.find<HomeController>().toggleAudio();
                  },
                ),
                const PopupMenuItem<String>(
                  value: 'timezone',
                  child: Text('Fuso Horário'),
                ),
              ];
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opções',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                const Icon(Icons.more_vert),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'score',
                  child: const Text('Pontuação'),
                  onTap: () async {
                    // await urlController.launchURL(
                    //   'https://docs.google.com/spreadsheets/d/1kh4zc2INhLEOGbLqqte8NnP4NsNRvFTgSWvKNKKM9qk/edit?usp=sharing',
                    // );
                  },
                ),
                PopupMenuItem<String>(
                  value: 'discord',
                  child: const Text('Discord'),
                  onTap: () async {
                    // await urlController.launchURL(
                    //   'https://discord.gg/udteYpaGuB',
                    // );
                  },
                ),
                PopupMenuItem<String>(
                  value: 'social_media',
                  child: const Text('Redes Sociais'),
                  onTap: () async {
                    // await urlController.launchURL(
                    //   'https://www.twitch.com/BoostTeam_',
                    // );
                  },
                ),
                PopupMenuItem<String>(
                  value: 'schedule_form',
                  child: const Text('Formulário de horários'),
                  onTap: () async {
                    // await urlController.launchURL(
                    //   'https://forms.gle/RN4NGWm8Qvi1daqp7',
                    // );
                  },
                ),
                PopupMenuItem<String>(
                  value: 'weblurk',
                  child: const Text('WebLurk'),
                  onTap: () async {
                    // await urlController.launchURL(
                    //   'https://drive.google.com/drive/folders/1XsmNh_gpKYLEkMSaBPFLuT3Y5vDmeWC3?usp=sharing',
                    // );
                  },
                ),
              ];
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Links',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                const Icon(Icons.link),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'about',
                  child: const Text('Sobre o WebLurk'),
                  onTap: () async {
                    // await urlController.launchURL('https://www.google.com');
                  },
                ),
              ];
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sobre',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Icon(Icons.info),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 20);
}