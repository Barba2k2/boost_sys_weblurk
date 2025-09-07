import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/services/error_message_service.dart';
import '../../../../../core/ui/app_colors.dart';
import '../../../../../core/ui/widgets/boost_text_form_field.dart';
import '../../../../../core/utils/result.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../../../../core/ui/widgets/messages.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Messages.setGlobalContext(context);
    });

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
              height: 350,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Boost Team SysWebLurk',
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
                      label: 'Usuário',
                      validator: widget.viewModel.validateUser,
                    ),
                    const SizedBox(height: 16),
                    BoostTextFormField(
                      controller: _passwordEC,
                      label: 'Password',
                      validator: widget.viewModel.validatePassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ListenableBuilder(
                          listenable: widget.viewModel.loginCommand,
                          builder: (context, child) {
                            final command = widget.viewModel.loginCommand;

                            return SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    command.running ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: command.running
                                    ? const CircularProgressIndicator(
                                        color: AppColors.cardHeaderText,
                                      )
                                    : const Text(
                                        'Entrar',
                                        style: TextStyle(
                                          fontFamily: 'Ibrand',
                                          color: AppColors.cardHeaderText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () async {
                            print(
                                'Botão Cadastrar clicado - navegando para: ${AppRoutes.register}');
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            if (mounted) {
                              GoRouter.of(context).go(AppRoutes.register);
                            }
                          },
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.cardHeaderText,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Cadastrar',
                                style: TextStyle(
                                  fontFamily: 'Ibrand',
                                  color: AppColors.cardHeaderText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.0,
                                ),
                              ),
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
