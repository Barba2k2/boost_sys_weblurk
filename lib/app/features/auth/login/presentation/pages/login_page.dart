import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/utils/result.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou título
              const Text(
                'Boost System',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Campo de email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão de login
              ListenableBuilder(
                listenable: widget.viewModel.loginCommand,
                builder: (context, child) {
                  final command = widget.viewModel.loginCommand;

                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: command.running ? null : () => _handleLogin(),
                      child: command.running
                          ? const CircularProgressIndicator()
                          : const Text('Entrar'),
                    ),
                  );
                },
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
                      final errorMessage =
                          command.result?.errorOrNull?.toString() ??
                              'Erro desconhecido';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro: $errorMessage'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final params = LoginParams(
        email: _emailController.text,
        password: _passwordController.text,
      );
      widget.viewModel.loginCommand.execute(params);
    }
  }
}
