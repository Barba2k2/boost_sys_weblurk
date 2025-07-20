import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/ui/widgets/boost_text_form_field.dart';
import '../../../../core/ui/widgets/messages/messages.dart';
import '../../domain/entities/auth_state.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameEC = TextEditingController();
  final _passwordEC = TextEditingController();
  late final AuthViewModel _viewModel;
  late final AuthState _authState;

  @override
  void initState() {
    super.initState();
    _authState = getIt<AuthState>();
    _viewModel = AuthViewModel(
      repository: getIt(),
      authState: _authState,
      secureStorage: getIt(),
    );

    _viewModel.login.addListener(() {
      if (mounted && _viewModel.login.error) {
        final error = _viewModel.login.result?.error;
        if (error != null) {
          Messages.error(error.toString());
        }
      }
    });

    _authState.addListener(() {
      if (mounted && _authState.isLoggedIn) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _nicknameEC.dispose();
    _passwordEC.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      final nickname = _nicknameEC.text.trim();
      final password = _passwordEC.text.trim();
      _viewModel.login.execute({
        'nickname': nickname,
        'password': password,
      });
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
          ListenableBuilder(
            listenable: _viewModel.login,
            builder: (context, child) {
              return Align(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
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
                        BoostTextFormField(
                          controller: _nicknameEC,
                          label: 'Usuário',
                          validator:
                              Validatorless.required('Login obrigatório'),
                        ),
                        const SizedBox(height: 16),
                        BoostTextFormField(
                          controller: _passwordEC,
                          label: 'Senha',
                          validator:
                              Validatorless.required('Senha obrigatória'),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                _viewModel.login.running ? null : _handleLogin,
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
                            child: _viewModel.login.running
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Entrar',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
