import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatorless/validatorless.dart';
import '../../../../core/ui/widgets/boost_text_form_field.dart';
import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameEC = TextEditingController();
  final _passwordEC = TextEditingController();
  final controller = Modular.get<LoginController>();

  @override
  void dispose() {
    _nicknameEC.dispose();
    _passwordEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/background.png',
              scale: 2,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.center,
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
                    const SizedBox(
                      height: 20,
                    ),
                    BoostTextFormField(
                      controller: _nicknameEC,
                      label: 'Usuário',
                      validator: Validatorless.required('Login obrigatório'),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    BoostTextFormField(
                      controller: _passwordEC,
                      label: 'Password',
                      validator: Validatorless.required('Senha obrigatória'),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final formValid =
                              _formKey.currentState?.validate() ?? false;
                          if (formValid) {
                            final nickname = _nicknameEC.text.trim();
                            final password = _passwordEC.text.trim();
                            controller.login(
                              nickname: nickname,
                              password: password,
                            );
                          }
                        },
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
                        child: Text(
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
          ),
        ],
      ),
    );
  }
}
