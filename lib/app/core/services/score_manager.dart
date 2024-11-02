import 'dart:async';

import '../../modules/core/auth/auth_store.dart';
import '../../service/home/home_service.dart';
import '../exceptions/failure.dart';
import '../logger/app_logger.dart';

class ScoreManager {
  final AppLogger _logger;
  final HomeService _homeService;
  final AuthStore _authStore;
  Timer? _scoreCheckTimer;

  static const Duration checkInterval = Duration(minutes: 6);

  ScoreManager(this._logger, this._homeService, this._authStore);

  Future<void> startChecking() async {
    _logger.info('Iniciando verificação de scores...');

    _scoreCheckTimer?.cancel();

    try {
      await _saveScore();
      _startPeriodicCheck();
    } catch (e, s) {
      _logger.error('Erro ao iniciar verificação de scores', e, s);
    }
  }

  void _startPeriodicCheck() {
    _scoreCheckTimer = Timer.periodic(
      checkInterval,
      (timer) async {
        try {
          _logger.info('Executando verificação periódica de score');
          await _saveScore();
          _logger.info('Verificação periódica de score executada com sucesso');
        } catch (e, s) {
          _logger.error('Erro durante verificação periódica de score', e, s);
        }
      },
    );
  }

  Future<void> _saveScore() async {
    _logger.info('Iniciando salvamento de score...');

    try {
      if (_authStore.userLogged == null) {
        _logger.warning('Nenhum usuário logado para salvar score');
        return;
      }

      final streamerId = _getCurrentStreamerId();
      if (streamerId <= 0) {
        _logger.warning('ID do streamer inválido: $streamerId');
        return;
      }

      final now = DateTime.now();

      _logger.info(
        'Salvando score para streamer $streamerId em ${now.toString()}',
      );

      await _homeService.saveScore(
        streamerId,
        DateTime(now.year, now.month, now.day),
        now.hour,
        now.minute,
        10,
      );

      _logger.info('Score salvo com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao salvar score', e, s);

      if (e is Failure) {
        _logger.error('Motivo do erro: ${e.message}');
      }

      throw Failure(message: 'Erro ao salvar a pontuação');
    }
  }

  int _getCurrentStreamerId() {
    try {
      if (_authStore.userLogged == null) {
        _logger.warning('Nenhum usuário está logado');
        return 0;
      }

      final userId = _authStore.userLogged?.id;
      if (userId == null) {
        _logger.warning('ID do usuário é null');
        return 0;
      }

      final streamerId = int.tryParse(userId.toString());
      if (streamerId == null || streamerId <= 0) {
        _logger.warning('ID do streamer inválido: $streamerId');
        return 0;
      }

      _logger.info('Streamer ID obtido com sucesso: $streamerId');
      return streamerId;
    } catch (e, s) {
      _logger.error('Erro ao obter ID do streamer', e, s);
      return 0;
    }
  }

  void dispose() {
    try {
      _scoreCheckTimer?.cancel();
    } catch (e, s) {
      _logger.error('Erro ao fazer dispose do ScoreManager', e, s);
    }
  }
}
