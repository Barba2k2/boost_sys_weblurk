import 'package:flutter/material.dart';
import '../../../../../core/ui/app_colors.dart';

class ModeToggleLink extends StatelessWidget {
  final bool isRegisterMode;
  final VoidCallback onToggle;

  const ModeToggleLink({
    super.key,
    required this.isRegisterMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isRegisterMode ? 'Já tem conta? ' : 'Não tem conta? ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onToggle,
            child: Text(
              isRegisterMode ? 'Faça login' : 'Cadastre-se',
              style: const TextStyle(
                color: AppColors.cosmicAccent,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.cosmicAccent,
                decorationThickness: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
