import 'package:flutter/material.dart';
import '../../../../../core/ui/app_colors.dart';

class TypingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration typingDuration;
  final Duration cursorBlinkDuration;

  const TypingTextWidget({
    super.key,
    required this.text,
    this.style,
    this.typingDuration = const Duration(milliseconds: 1500),
    this.cursorBlinkDuration = const Duration(milliseconds: 500),
  });

  @override
  State<TypingTextWidget> createState() => _TypingTextWidgetState();
}

class _TypingTextWidgetState extends State<TypingTextWidget>
    with TickerProviderStateMixin {
  late AnimationController _typingController;
  late AnimationController _cursorController;
  late Animation<int> _typingAnimation;
  late Animation<double> _cursorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTyping();
  }

  void _setupAnimations() {
    _typingController = AnimationController(
      duration: widget.typingDuration,
      vsync: this,
    );

    _cursorController = AnimationController(
      duration: widget.cursorBlinkDuration,
      vsync: this,
    );

    _typingAnimation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    ));
  }

  void _startTyping() {
    _typingController.forward();
    _cursorController.repeat(reverse: true);
  }

  void restartTyping() {
    _typingController.reset();
    _cursorController.reset();
    _typingAnimation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));
    _startTyping();
  }

  @override
  void didUpdateWidget(TypingTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      restartTyping();
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_typingAnimation, _cursorAnimation]),
      builder: (context, child) {
        final visibleLength = _typingAnimation.value;
        final visibleText = widget.text.substring(0, visibleLength);
        final isTyping = visibleLength < widget.text.length;
        final cursorOpacity = _cursorAnimation.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              visibleText,
              style: widget.style,
            ),
            if (isTyping)
              AnimatedOpacity(
                opacity: cursorOpacity,
                duration: const Duration(milliseconds: 100),
                child: Text(
                  '|',
                  style: (widget.style ?? const TextStyle()).copyWith(
                    color: AppColors.cosmicAccent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
