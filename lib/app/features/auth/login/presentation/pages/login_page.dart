import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/ui/widgets/boost_text_form_field.dart';
import '../../../../../core/ui/widgets/messages.dart';
import '../../../../../core/services/error_message_service.dart';
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
  void dispose() {
    _nicknameEC.dispose();
    _passwordEC.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      final params = LoginParams(
        email: _nicknameEC.text.trim(),
        password: _passwordEC.text.trim(),
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
          Align(
            child: Image.asset(
              'assets/images/background.png',
              scale: 2,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Login Form Container
          Align(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
                color: Colors.purple[800],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(32),
              width: 500,
              height: 380,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Título
                    Text(
                      'BoostTeam SysWebLurk',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo de usuário
                    BoostTextFormField(
                      controller: _nicknameEC,
                      label: 'Usuário',
                      validator: Validatorless.required('Login obrigatório'),
                    ),
                    const SizedBox(height: 16),

                    // Campo de senha
                    BoostTextFormField(
                      controller: _passwordEC,
                      label: 'Password',
                      validator: Validatorless.required('Senha obrigatória'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Botão de login
                    ListenableBuilder(
                      listenable: widget.viewModel.loginCommand,
                      builder: (context, child) {
                        final command = widget.viewModel.loginCommand;

                        return SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: command.running ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[900],
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
                                    color: Colors.white)
                                : Text(
                                    'Entrar',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Listener para navegação e erros
          ListenableBuilder(
            listenable: widget.viewModel.loginCommand,
            builder: (context, child) {
              final command = widget.viewModel.loginCommand;

              // Reagir ao resultado do comando
              if (command.completed) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(AppRoutes.home);
                });
              }

              if (command.error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final error = command.result?.errorOrNull;

                  // Usar o ErrorMessageService para tratar o erro
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
