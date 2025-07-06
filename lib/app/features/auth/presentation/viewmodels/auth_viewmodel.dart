
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/local_storage/local_storage.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../utils/utils.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/check_login_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;
  final LocalStorage _localStorage;
  final AppLogger _logger;

  late final Command0<void> _checkUserLoggedCommand;
  late final Command1<void, Map<String, String>> _loginCommand;

  AuthViewModel({
    LoginUseCase? loginUseCase,
    LogoutUseCase? logoutUseCase,
    CheckLoginStatusUseCase? checkLoginStatusUseCase,
    AppLogger? logger,
    LocalStorage? localStorage,
  })  : _loginUseCase = loginUseCase ??
            LoginUseCase(
              AuthRepositoryImpl(
                dataSource: AuthDataSourceImpl(
                  restClient: di.get(),
                  logger: di.get(),
                ),
                logger: di.get(),
                authStore: di.get(),
              ),
            ),
        _logoutUseCase = logoutUseCase ??
            LogoutUseCase(
              AuthRepositoryImpl(
                dataSource: AuthDataSourceImpl(
                  restClient: di.get(),
                  logger: di.get(),
                ),
                logger: di.get(),
                authStore: di.get(),
              ),
            ),
        _checkLoginStatusUseCase = checkLoginStatusUseCase ??
            CheckLoginStatusUseCase(
              AuthRepositoryImpl(
                dataSource: AuthDataSourceImpl(
                  restClient: di.get(),
                  logger: di.get(),
                ),
                logger: di.get(),
                authStore: di.get(),
              ),
            ),
        _localStorage = localStorage ?? di.get<LocalStorage>(),
        _logger = logger ?? di.get<AppLogger>() {
    _checkUserLoggedCommand = Command0(_checkUserLoggedAction);
    _loginCommand = Command1(_loginAction);
  }

  Future<Result<void>> _checkUserLoggedAction() async {
    try {
      final result = await _checkLoginStatusUseCase.execute();

      if (result.isSuccess && result.asSuccess) {
        _logger.info('Usuário autenticado, navegando para home');
        Loader.show();
        await Future.delayed(const Duration(milliseconds: 200));
        // TODO: Navigate to home using proper navigation
        Loader.hide();
        return Result.ok(null);
      }

      _logger.info('Permanece na tela de login');
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao verificar login', e, s);
      await _logoutUseCase.execute();
      return Result.error(e as Exception);
    }
  }

  Future<Result<void>> _loginAction(Map<String, String> credentials) async {
    try {
      Loader.show();

      final result = await _loginUseCase.execute(
        credentials['nickname']!,
        credentials['password']!,
      );

      if (result.isSuccess) {
        await Future.delayed(const Duration(milliseconds: 200));
        // TODO: Navigate to home using proper navigation
        return Result.ok(null);
      } else {
        Messages.alert('Usuario e/ou senha incorretos');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      Messages.alert('Usuario e/ou senha incorretos');
      _logger.error('Erro ao realizar login', e, s);
      return Result.error(e as Exception);
    } finally {
      Loader.hide();
    }
  }

  Future<void> checkUserLogged() async {
    await _checkUserLoggedCommand.execute();
  }

  Future<void> login({
    required String nickname,
    required String password,
  }) async {
    await _loginCommand.execute({
      'nickname': nickname,
      'password': password,
    });
  }

  bool get isCheckingUser => _checkUserLoggedCommand.running;
  bool get isLoggingIn => _loginCommand.running;
  bool get hasError => _checkUserLoggedCommand.error || _loginCommand.error;
  Exception? get error =>
      _checkUserLoggedCommand.result?.asErrorValue ??
      _loginCommand.result?.asErrorValue;

  @override
  void dispose() {
    _checkUserLoggedCommand.dispose();
    _loginCommand.dispose();
    super.dispose();
  }
}
