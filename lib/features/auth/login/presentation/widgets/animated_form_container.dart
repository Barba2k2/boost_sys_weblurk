import 'package:flutter/material.dart';
import '../../../../../core/ui/app_colors.dart';
import '../../../../../core/ui/widgets/boost_text_form_field.dart';
import 'typing_text_widget.dart';

class AnimatedFormContainer extends StatelessWidget {
  final bool isRegisterMode;
  final TextEditingController nicknameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? Function(String?) nicknameValidator;
  final String? Function(String?) passwordValidator;
  final String? Function(String?, String?) confirmPasswordValidator;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final bool isLoading;

  const AnimatedFormContainer({
    super.key,
    required this.isRegisterMode,
    required this.nicknameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nicknameValidator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
    required this.onLogin,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.text,
          child: BoostTextFormField(
            controller: nicknameController,
            label: isRegisterMode ? 'Nickname' : 'Usuário',
            validator: nicknameValidator,
          ),
        ),
        const SizedBox(height: 20),
        MouseRegion(
          cursor: SystemMouseCursors.text,
          child: BoostTextFormField(
            controller: passwordController,
            label: 'Senha',
            validator: passwordValidator,
            obscureText: true,
          ),
        ),

        // Campo de confirmar senha (animado)
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: isRegisterMode ? 80 : 0,
          child: isRegisterMode
              ? Column(
                  children: [
                    const SizedBox(height: 20),
                    MouseRegion(
                      cursor: SystemMouseCursors.text,
                      child: BoostTextFormField(
                        controller: confirmPasswordController,
                        label: 'Confirmar Senha',
                        validator: (value) => confirmPasswordValidator(
                            value, passwordController.text),
                        obscureText: true,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 32),

        // Login/Register Button
        MouseRegion(
          cursor: isLoading
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: isLoading
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cosmicButtonStart.withValues(alpha: 0.6),
                        AppColors.cosmicButtonEnd.withValues(alpha: 0.6),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cosmicButtonStart,
                        AppColors.cosmicButtonEnd,
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cosmicBorder.withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed:
                  isLoading ? null : (isRegisterMode ? onRegister : onLogin),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : TypingTextWidget(
                      text: isRegisterMode ? 'Cadastrar' : 'Entrar',
                      style: const TextStyle(
                        fontFamily: 'Ibrand',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                      typingDuration: const Duration(milliseconds: 800),
                      cursorBlinkDuration: const Duration(milliseconds: 600),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
