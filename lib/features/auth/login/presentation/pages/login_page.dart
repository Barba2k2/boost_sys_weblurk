import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/services/error_message_service.dart';
import '../../../../../core/ui/app_colors.dart';
import '../../../../../core/ui/widgets/messages.dart';
import '../../../../../core/utils/result.dart';
import '../../../register/presentation/viewmodels/register_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/animated_form_container.dart';
import '../widgets/mode_toggle_link.dart';
import '../widgets/typing_text_widget.dart';

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
  final _confirmPasswordEC = TextEditingController();

  bool _isRegisterMode = false;
  late final RegisterViewModel _registerViewModel;

  @override
  void initState() {
    super.initState();
    _registerViewModel = i<RegisterViewModel>();
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

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      if (!_isRegisterMode) {
        _confirmPasswordEC.clear();
      }
    });
  }

  void _handleRegister() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      final params = RegisterParams(
        nickname: _nicknameEC.text,
        password: _passwordEC.text,
        confirmPassword: _confirmPasswordEC.text,
      );
      _registerViewModel.registerCommand.execute(params);
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
          // Dark cosmic background overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.cosmicDarkPurple.withValues(alpha: 0.3),
                    AppColors.cosmicBlue.withValues(alpha: 0.4),
                    AppColors.cosmicNavy.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 20,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.cosmicPurple,
                          AppColors.cosmicDarkPurple,
                          AppColors.cosmicBlue,
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.cosmicBorder.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cosmicBorder.withValues(alpha: 0.4),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 30,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo and Title
                          Column(
                            children: [
                              Image.asset(
                                'assets/images/logo-cla-boost.png',
                                height: 200,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Boost Team',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Ibrand',
                                  letterSpacing: 3.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'SysWebLurk',
                                style: TextStyle(
                                  color: AppColors.cosmicAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Ibrand',
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // Login/Register Form
                          Column(
                            children: [
                              TypingTextWidget(
                                text: _isRegisterMode
                                    ? 'Criar Conta'
                                    : 'Fazer Login',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Ibrand',
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ListenableBuilder(
                                listenable: Listenable.merge([
                                  widget.viewModel.loginCommand,
                                  _registerViewModel.registerCommand,
                                ]),
                                builder: (context, child) {
                                  final isLoginLoading =
                                      widget.viewModel.loginCommand.running;
                                  final isRegisterLoading = _registerViewModel
                                      .registerCommand.running;
                                  final isLoading =
                                      isLoginLoading || isRegisterLoading;

                                  return AnimatedFormContainer(
                                    isRegisterMode: _isRegisterMode,
                                    nicknameController: _nicknameEC,
                                    passwordController: _passwordEC,
                                    confirmPasswordController:
                                        _confirmPasswordEC,
                                    nicknameValidator: _isRegisterMode
                                        ? _registerViewModel.validateNickname
                                        : widget.viewModel.validateUser,
                                    passwordValidator: _isRegisterMode
                                        ? _registerViewModel.validatePassword
                                        : widget.viewModel.validatePassword,
                                    confirmPasswordValidator: _registerViewModel
                                        .validateConfirmPassword,
                                    onLogin: _handleLogin,
                                    onRegister: _handleRegister,
                                    isLoading: isLoading,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Toggle Mode Link
                          ModeToggleLink(
                            isRegisterMode: _isRegisterMode,
                            onToggle: _toggleMode,
                          ),
                        ],
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
                  ErrorMessageService.instance.handleLoginError(error);
                });
              }

              return const SizedBox.shrink();
            },
          ),

          // Register Command Listener
          ListenableBuilder(
            listenable: _registerViewModel.registerCommand,
            builder: (context, child) {
              final command = _registerViewModel.registerCommand;

              if (command.completed) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Messages.success('Cadastro realizado com sucesso!');
                  _toggleMode(); // Volta para o modo de login
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
