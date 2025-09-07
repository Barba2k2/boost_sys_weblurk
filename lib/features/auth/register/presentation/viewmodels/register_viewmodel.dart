import 'package:flutter/foundation.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../../core/helpers/sentry_mixin.dart';
import '../../../../../core/services/error_message_service.dart';
import '../../../../../core/utils/command.dart';
import '../../../../../core/utils/result.dart';
import '../../../../../service/user/user_service.dart';

class RegisterParams {
  final String nickname;
  final String password;
  final String confirmPassword;

  RegisterParams({
    required this.nickname,
    required this.password,
    required this.confirmPassword,
  });
}

class RegisterViewModel extends ChangeNotifier with SentryMixin {
  RegisterViewModel({
    required UserService userService,
  }) : _userService = userService;

  final UserService _userService;

  late final registerCommand = Command1<String, RegisterParams>(
    (params) => _register(params),
  );

  Future<Result<String>> _register(RegisterParams params) async {
    try {
      await _userService.register(
        params.nickname,
        params.password,
      );

      await captureInfo(
        'Cadastro realizado com sucesso',
        data: {'nickname': params.nickname},
      );

      return Result.ok('Cadastro realizado com sucesso');
    } catch (e) {
      await captureError(e, StackTrace.current, context: 'register_error');
      final errorMessage =
          ErrorMessageService.instance.extractUserFriendlyMessage(e);
      return Result.error(
        Exception(errorMessage),
      );
    }
  }

  String? validateNickname(String? value) {
    return Validatorless.multiple([
      Validatorless.required('Nickname é obrigatório'),
      Validatorless.min(3, 'Nickname deve ter pelo menos 3 caracteres'),
      Validatorless.max(20, 'Nickname deve ter no máximo 20 caracteres'),
    ])(value);
  }

  String? validatePassword(String? value) {
    return Validatorless.multiple([
      Validatorless.required('Senha é obrigatória'),
      Validatorless.min(6, 'Senha deve ter pelo menos 6 caracteres'),
      Validatorless.max(50, 'Senha deve ter no máximo 50 caracteres'),
    ])(value);
  }

  String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != password) {
      return 'Senhas não coincidem';
    }
    return null;
  }
}
