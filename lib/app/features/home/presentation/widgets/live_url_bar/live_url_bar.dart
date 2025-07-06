import 'package:flutter/material.dart';
import 'url_bar_container.dart';
import 'url_bar_text.dart';

class LiveUrlBar extends StatelessWidget {
  const LiveUrlBar({
    required this.currentChannel,
    super.key,
  });

  final String? currentChannel;

  @override
  Widget build(BuildContext context) {
    return UrlBarContainer(
      child: UrlBarText(currentChannel: currentChannel),
    );
  }
} 