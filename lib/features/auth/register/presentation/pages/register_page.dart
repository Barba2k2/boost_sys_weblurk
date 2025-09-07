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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay for better text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Card(
                    elevation: 20,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.surface.withValues(alpha: 0.95),
                            AppColors.background.withValues(alpha: 0.9),
                            AppColors.cardHeader.withValues(alpha: 0.8),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo and Title with glow effect
                            Image.asset(
                              'assets/images/logo-cla-boost.png',
                              height: 200,
                            ),
                            const SizedBox(height: 20),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [
                                  AppColors.cardHeaderText,
                                  AppColors.primary,
                                  AppColors.accent,
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'Boost Team',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Ibrand',
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'SysWebLurk',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Ibrand',
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // Register Form
                            const Text(
                              'Criar Conta',
                              style: TextStyle(
                                color: AppColors.cardHeaderText,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Ibrand',
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            BoostTextFormField(
                              controller: _nicknameEC,
                              label: 'Nickname',
                              validator: widget.viewModel.validateNickname,
                            ),
                            const SizedBox(height: 20),
                            BoostTextFormField(
                              controller: _passwordEC,
                              label: 'Senha',
                              validator: widget.viewModel.validatePassword,
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            BoostTextFormField(
                              controller: _confirmPasswordEC,
                              label: 'Confirmar Senha',
                              validator: (value) => widget.viewModel.validateConfirmPassword(
                                value,
                                _passwordEC.text,
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 32),
                            
                            // Register Button with enhanced styling
                            ListenableBuilder(
                              listenable: widget.viewModel.registerCommand,
                              builder: (context, child) {
                                final command = widget.viewModel.registerCommand;
                                final isLoading = command.running;

                                return Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.accent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _handleRegister,
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
                                              strokeWidth: 3,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Cadastrar',
                                            style: TextStyle(
                                              fontFamily: 'Ibrand',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Login Link with enhanced styling
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Já tem conta? ',
                                    style: TextStyle(
                                      color: AppColors.cardHeaderText.withValues(alpha: 0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      if (mounted) {
                                        context.go(AppRoutes.login);
                                      }
                                    },
                                    child: const Text(
                                      'Faça login',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.accent,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Register Command Listener
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