import 'package:flutter/material.dart';
import '../app_colors.dart';

class BuildMenuItem extends PopupMenuEntry<String> {
  const BuildMenuItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      value: label,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.menuItemIcon,
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  @override
  double get height => 48.0;

  @override
  bool represents(String? value) => value == label;

  @override
  State<BuildMenuItem> createState() => _BuildMenuItemState();
}

class BuildMenuItemReactive extends PopupMenuEntry<String> {
  const BuildMenuItemReactive({
    super.key,
    required this.builder,
    required this.onTap,
  });

  final Widget Function() builder;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      onTap: onTap,
      child: builder(),
    );
  }

  @override
  double get height => 48.0;

  @override
  bool represents(String? value) => false;

  @override
  State<BuildMenuItemReactive> createState() => _BuildMenuItemReactiveState();
}

class _BuildMenuItemState extends State<BuildMenuItem> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      value: widget.label,
      onTap: widget.onTap,
      child: Row(
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: AppColors.menuItemIcon,
          ),
          const SizedBox(width: 10),
          Text(widget.label),
        ],
      ),
    );
  }
}

class _BuildMenuItemReactiveState extends State<BuildMenuItemReactive> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      onTap: widget.onTap,
      child: widget.builder(),
    );
  }
}
