import 'package:flutter/material.dart';

class UrlBarContainer extends StatelessWidget {
  const UrlBarContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: Colors.purple[300],
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: child,
    );
  }
}
