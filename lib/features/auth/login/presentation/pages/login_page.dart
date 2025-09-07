import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/services/error_message_service.dart';
import '../../../../../core/ui/app_colors.dart';
import '../../../../../core/ui/widgets/boost_text_form_field.dart';
import '../../../../../core/ui/widgets/messages.dart';
import '../../../../../core/utils/result.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.viewModel,
  });
  final LoginViewModel viewModel;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameEC = TextEditingController();
  final _passwordEC = TextEditingController();

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
    super.dispose();
  }

  void _handleLogin() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      final params = LoginParams(
        nickname: _nicknameEC.text,
        password: _passwordEC.text,
      );
      widget.viewModel.loginCommand.execute(params);
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
                              shaderCallback: (bounds) => const LinearGradient(
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

                            // Login Form
                            const Text(
                              'Fazer Login',
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
                              label: 'Usuário',
                              validator: widget.viewModel.validateUser,
                            ),
                            const SizedBox(height: 20),
                            BoostTextFormField(
                              controller: _passwordEC,
                              label: 'Senha',
                              validator: widget.viewModel.validatePassword,
                              obscureText: true,
                            ),
                            const SizedBox(height: 32),

                            // Login Button with enhanced styling
                            ListenableBuilder(
                              listenable: widget.viewModel.loginCommand,
                              builder: (context, child) {
                                final command = widget.viewModel.loginCommand;

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
                                        color: AppColors.primary
                                            .withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        command.running ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: command.running
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Entrar',
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

                            // Register Link with enhanced styling
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Não tem conta? ',
                                    style: TextStyle(
                                      color: AppColors.cardHeaderText
                                          .withValues(alpha: 0.8),
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
                                        context.go(AppRoutes.register);
                                      }
                                    },
                                    child: const Text(
                                      'Cadastre-se',
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
          // Login Command Listener
          ListenableBuilder(
            listenable: widget.viewModel.loginCommand,
            builder: (context, child) {
              final command = widget.viewModel.loginCommand;

              if (command.completed) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(AppRoutes.home);
                });
              }

              if (command.error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final error = command.result?.errorOrNull;

                  log('error: $error');
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
