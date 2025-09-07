import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/services/error_message_service.dart';
import '../../../../../core/ui/app_colors.dart';
import '../../../../../core/ui/widgets/boost_text_form_field.dart';
import '../../../../../core/ui/widgets/messages.dart';
import '../../../../../core/utils/result.dart';
import '../viewmodels/register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.viewModel,
  });
  final RegisterViewModel viewModel;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameEC = TextEditingController();
  final _passwordEC = TextEditingController();
  final _confirmPasswordEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Messages.setGlobalContext(context);
    });
  }

  @override
  void dispose() {
    _nicknameEC.dispose();
    _passwordEC.dispose();
    _confirmPasswordEC.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      final params = RegisterParams(
        nickname: _nicknameEC.text,
        password: _passwordEC.text,
        confirmPassword: _confirmPasswordEC.text,
      );
      widget.viewModel.registerCommand.execute(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            child: Image.asset(
              'assets/images/background.png',
              scale: 2,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.menuItemIconInactive.withValues(alpha: 0.8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: 600,
              height: 450,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Cadastro - Boost Team',
                      style: TextStyle(
                        color: AppColors.cardHeaderText,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Ibrand',
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    BoostTextFormField(
                      controller: _nicknameEC,
                      label: 'Nickname',
                      validator: widget.viewModel.validateNickname,
                    ),
                    const SizedBox(height: 16),
                    BoostTextFormField(
                      controller: _passwordEC,
                      label: 'Senha',
                      validator: widget.viewModel.validatePassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    BoostTextFormField(
                      controller: _confirmPasswordEC,
                      label: 'Confirmar Senha',
                      validator: (value) =>
                          widget.viewModel.validateConfirmPassword(
                        value,
                        _passwordEC.text,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ListenableBuilder(
                      listenable: widget.viewModel.registerCommand,
                      builder: (context, child) {
                        final command = widget.viewModel.registerCommand;
                        final isLoading = command.running;

                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.menuButtonActive,
                              foregroundColor: AppColors.menuItemIcon,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.menuItemIcon,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Cadastrar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text(
                        'Já tem conta? Faça login',
                        style: TextStyle(
                          color: AppColors.cardHeaderText,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: widget.viewModel.registerCommand,
            builder: (context, child) {
              final command = widget.viewModel.registerCommand;

              if (command.completed) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Messages.success('Cadastro realizado com sucesso!');
                  context.go(AppRoutes.login);
                });
              }

              if (command.error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final error = command.result?.errorOrNull;
                  ErrorMessageService.instance.handleLoginError(error);
                });
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
