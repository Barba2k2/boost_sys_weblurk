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
          // Main content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f3460),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2c3e50),
                              Color(0xFF34495e),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo and Title
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/logo-cla-boost.png',
                                      height: 60,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Boost Team',
                                      style: TextStyle(
                                        color: AppColors.cardHeaderText,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Ibrand',
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    const Text(
                                      'SysWebLurk',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Ibrand',
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Register Form
                              const Text(
                                'Criar Conta',
                                style: TextStyle(
                                  color: AppColors.cardHeaderText,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Ibrand',
                                ),
                              ),
                              const SizedBox(height: 24),

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
                              const SizedBox(height: 24),

                              // Register Button
                              ListenableBuilder(
                                listenable: widget.viewModel.registerCommand,
                                builder: (context, child) {
                                  final command =
                                      widget.viewModel.registerCommand;
                                  final isLoading = command.running;

                                  return SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          isLoading ? null : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Cadastrar',
                                              style: TextStyle(
                                                fontFamily: 'Ibrand',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Já tem conta? ',
                                    style: TextStyle(
                                      color: AppColors.cardHeaderText
                                          .withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await Future.delayed(
                                          const Duration(milliseconds: 100));
                                      if (mounted) {
                                        GoRouter.of(context)
                                            .go(AppRoutes.login);
                                      }
                                    },
                                    child: const Text(
                                      'Faça login',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
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
