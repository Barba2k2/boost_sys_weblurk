import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../service/home/home_service_impl.dart';
import '../../../../service/webview/windows_web_view_service_impl.dart';
import '../../../../utils/utils.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/datasources/polling_datasource.dart';
import '../../data/datasources/webview_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/repositories/polling_repository_impl.dart';
import '../../data/repositories/webview_repository_impl.dart';
import '../../domain/usecases/check_and_update_channel_usecase.dart';
import '../../domain/usecases/check_and_update_score_usecase.dart';
import '../../domain/usecases/initialize_home_usecase.dart';
import '../../domain/usecases/initialize_webview_usecase.dart';
import '../../domain/usecases/load_url_usecase.dart';
import '../../domain/usecases/reload_webview_usecase.dart';
import '../../domain/usecases/start_polling_usecase.dart';
import '../../domain/usecases/start_polling_with_id_usecase.dart';
import '../../domain/usecases/stop_polling_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final InitializeHomeUseCase _initializeHomeUseCase;
  final StartPollingUseCase _startPollingUseCase;
  final StartPollingWithIdUseCase _startPollingWithIdUseCase;
  final StopPollingUseCase _stopPollingUseCase;
  final CheckAndUpdateChannelUseCase _checkAndUpdateChannelUseCase;
  final CheckAndUpdateScoreUseCase _checkAndUpdateScoreUseCase;
  final InitializeWebViewUseCase _initializeWebViewUseCase;
  final LoadUrlUseCase _loadUrlUseCase;
  final ReloadWebViewUseCase _reloadWebViewUseCase;
  final AppLogger _logger;

  late final Command0<void> _initializeHomeCommand;
  late final Command0<void> _startPollingCommand;
  late final Command1<void, int> _startPollingWithIdCommand;
  late final Command0<void> _stopPollingCommand;
  late final Command0<void> _checkAndUpdateChannelCommand;
  late final Command1<void, int> _checkAndUpdateScoreCommand;
  late final Command1<void, dynamic> _initializeWebViewCommand;
  late final Command1<void, String> _loadUrlCommand;
  late final Command0<void> _reloadWebViewCommand;

  HomeViewModel({
    InitializeHomeUseCase? initializeHomeUseCase,
    StartPollingUseCase? startPollingUseCase,
    StartPollingWithIdUseCase? startPollingWithIdUseCase,
    StopPollingUseCase? stopPollingUseCase,
    CheckAndUpdateChannelUseCase? checkAndUpdateChannelUseCase,
    CheckAndUpdateScoreUseCase? checkAndUpdateScoreUseCase,
    InitializeWebViewUseCase? initializeWebViewUseCase,
    LoadUrlUseCase? loadUrlUseCase,
    ReloadWebViewUseCase? reloadWebViewUseCase,
    AppLogger? logger,
  })  : _initializeHomeUseCase = initializeHomeUseCase ??
            InitializeHomeUseCase(
              HomeRepositoryImpl(
                dataSource: HomeDataSourceImpl(
                  restClient: di.get(),
                  logger: di.get(),
                ),
                logger: di.get(),
              ),
            ),
        _startPollingUseCase = startPollingUseCase ??
            StartPollingUseCase(
              HomeRepositoryImpl(
                dataSource: HomeDataSourceImpl(
                  restClient: di.get(),
                  logger: di.get(),
                ),
                logger: di.get(),
              ),
            ),
        _startPollingWithIdUseCase = startPollingWithIdUseCase ??
            StartPollingWithIdUseCase(
              PollingRepositoryImpl(
                dataSource: PollingDataSourceImpl(
                  homeService: HomeServiceImpl(
                    homeRepository: di.get(),
                    logger: di.get(),
                  ),
                  logger: di.get(),
                ),
                logger: di.get(),
              ),
            ),
        _stopPollingUseCase = stopPollingUseCase ??
            StopPollingUseCase(
              HomeRepositoryImpl(
                dataSource: HomeDataSourceImpl(
                  restClient: di.get(),
                  logger: di.get(),
                ),
                logger: di.get(),
              ),
            ),
        _checkAndUpdateChannelUseCase = checkAndUpdateChannelUseCase ??
            CheckAndUpdateChannelUseCase(
              PollingRepositoryImpl(
                dataSource: PollingDataSourceImpl(
                  homeService: HomeServiceImpl(
                    homeRepository: di.get(),
                    logger: di.get(),
                  ),
                  logger: di.get(),
                ),
                logger: di.get(),
              ),
            ),
        _checkAndUpdateScoreUseCase = checkAndUpdateScoreUseCase ??
            CheckAndUpdateScoreUseCase(
              PollingRepositoryImpl(
                dataSource: PollingDataSourceImpl(
                  homeService: HomeServiceImpl(
                    homeRepository: di.get(),
                    logger: di.get(),
                  ),
                  logger: di.get(),
                ),
                logger: di.get(),
              ),
            ),
        _initializeWebViewUseCase = initializeWebViewUseCase ??
            InitializeWebViewUseCase(
              WebViewRepositoryImpl(
                dataSource: WebViewDataSourceImpl(
                  logger: di.get(),
                  webViewService: WindowsWebViewServiceImpl(logger: di.get()),
                ),
                logger: di.get(),
              ),
            ),
        _loadUrlUseCase = loadUrlUseCase ??
            LoadUrlUseCase(
              WebViewRepositoryImpl(
                dataSource: WebViewDataSourceImpl(
                  logger: di.get(),
                  webViewService: WindowsWebViewServiceImpl(logger: di.get()),
                ),
                logger: di.get(),
              ),
            ),
        _reloadWebViewUseCase = reloadWebViewUseCase ??
            ReloadWebViewUseCase(
              WebViewRepositoryImpl(
                dataSource: WebViewDataSourceImpl(
                  logger: di.get(),
                  webViewService: WindowsWebViewServiceImpl(logger: di.get()),
                ),
                logger: di.get(),
              ),
            ),
        _logger = logger ?? di.get<AppLogger>() {
    _initializeHomeCommand = Command0(_initializeHomeAction);
    _startPollingCommand = Command0(_startPollingAction);
    _startPollingWithIdCommand = Command1(_startPollingWithIdAction);
    _stopPollingCommand = Command0(_stopPollingAction);
    _checkAndUpdateChannelCommand = Command0(_checkAndUpdateChannelAction);
    _checkAndUpdateScoreCommand = Command1(_checkAndUpdateScoreAction);
    _initializeWebViewCommand = Command1(_initializeWebViewAction);
    _loadUrlCommand = Command1(_loadUrlAction);
    _reloadWebViewCommand = Command0(_reloadWebViewAction);
  }

  Future<Result<void>> _initializeHomeAction() async {
    try {
      _logger.info('Inicializando home');
      Loader.show();

      final result = await _initializeHomeUseCase.execute();

      if (result.isSuccess) {
        _logger.info('Home inicializada com sucesso');
        await Future.delayed(const Duration(milliseconds: 200));
        return Result.ok(null);
      } else {
        _logger.error('Falha ao inicializar home: ${result.asErrorValue}');
        Messages.alert('Erro ao inicializar home');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao inicializar home', e, s);
      Messages.alert('Erro ao inicializar home');
      return Result.error(e as Exception);
    } finally {
      Loader.hide();
    }
  }

  Future<Result<void>> _startPollingAction() async {
    try {
      _logger.info('Iniciando polling');

      final result = await _startPollingUseCase.execute();

      if (result.isSuccess) {
        _logger.info('Polling iniciado com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao iniciar polling: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao iniciar polling', e, s);
      return Result.error(e as Exception);
    }
  }

  Future<Result<void>> _startPollingWithIdAction(int streamerId) async {
    try {
      _logger.info('Iniciando polling para streamer ID: $streamerId');

      final result = await _startPollingWithIdUseCase.execute(streamerId);

      if (result.isSuccess) {
        _logger
            .info('Polling iniciado com sucesso para streamer ID: $streamerId');
        return Result.ok(null);
      } else {
        _logger.error(
            'Falha ao iniciar polling para streamer ID $streamerId: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error(
          'Erro inesperado ao iniciar polling para streamer ID $streamerId',
          e,
          s);
      return Result.error(e as Exception);
    }
  }

  Future<Result<void>> _stopPollingAction() async {
    try {
      _logger.info('Parando polling');

      final result = await _stopPollingUseCase.execute();

      if (result.isSuccess) {
        _logger.info('Polling parado com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao parar polling: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao parar polling', e, s);
      return Result.error(e as Exception);
    }
  }

  Future<Result<void>> _checkAndUpdateChannelAction() async {
    try {
      _logger.info('Verificando e atualizando canal');

      final result = await _checkAndUpdateChannelUseCase.execute();

      if (result.isSuccess) {
        _logger.info('Canal verificado e atualizado com sucesso');
        return Result.ok(null);
      } else {
        _logger.error(
            'Falha ao verificar e atualizar canal: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao verificar e atualizar canal', e, s);
      return Result.error(e as Exception);
    }
  }

  Future<Result<void>> _checkAndUpdateScoreAction(int streamerId) async {
    try {
      _logger.info(
          'Verificando e atualizando score para streamer ID: $streamerId');

      final result = await _checkAndUpdateScoreUseCase.execute(streamerId);

      if (result.isSuccess) {
        _logger.info(
            'Score verificado e atualizado com sucesso para streamer ID: $streamerId');
        return Result.ok(null);
      } else {
        _logger.error(
            'Falha ao verificar e atualizar score para streamer ID $streamerId: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error(
          'Erro inesperado ao verificar e atualizar score para streamer ID $streamerId',
          e,
          s);
      return Result.error(e as Exception);
    }
  }

  Future<Result<void>> _initializeWebViewAction(dynamic controller) async {
    try {
      _logger.info('Inicializando WebView');

      final result = await _initializeWebViewUseCase.execute(controller);

      if (result.isSuccess) {
        _logger.info('WebView inicializado com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao inicializar WebView: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao inicializar WebView', e, s);
      return Result.error(e as Exception);
    }
  }

  Future<Result<void>> _loadUrlAction(String url) async {
    try {
      _logger.info('Carregando URL: $url');

      final result = await _loadUrlUseCase.execute(url);

      if (result.isSuccess) {
        _logger.info('URL carregada com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao carregar URL: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao carregar URL', e, s);
      return Result.error(e as Exception);
    }
  }

  Future<Result<void>> _reloadWebViewAction() async {
    try {
      _logger.info('Recarregando WebView');

      final result = await _reloadWebViewUseCase.execute();

      if (result.isSuccess) {
        _logger.info('WebView recarregado com sucesso');
        return Result.ok(null);
      } else {
        _logger.error('Falha ao recarregar WebView: ${result.asErrorValue}');
        return Result.error(result.asErrorValue);
      }
    } catch (e, s) {
      _logger.error('Erro inesperado ao recarregar WebView', e, s);
      return Result.error(e as Exception);
    }
  }

  Future<void> initializeHome() async {
    await _initializeHomeCommand.execute();
  }

  Future<void> startPolling() async {
    await _startPollingCommand.execute();
  }

  Future<void> startPollingWithId(int streamerId) async {
    await _startPollingWithIdCommand.execute(streamerId);
  }

  Future<void> stopPolling() async {
    await _stopPollingCommand.execute();
  }

  Future<void> checkAndUpdateChannel() async {
    await _checkAndUpdateChannelCommand.execute();
  }

  Future<void> checkAndUpdateScore(int streamerId) async {
    await _checkAndUpdateScoreCommand.execute(streamerId);
  }

  Future<void> initializeWebView(dynamic controller) async {
    await _initializeWebViewCommand.execute(controller);
  }

  Future<void> loadUrl(String url) async {
    await _loadUrlCommand.execute(url);
  }

  Future<void> reloadWebView() async {
    await _reloadWebViewCommand.execute();
  }

  bool get isInitializing => _initializeHomeCommand.running;
  bool get isStartingPolling => _startPollingCommand.running;
  bool get isStartingPollingWithId => _startPollingWithIdCommand.running;
  bool get isStoppingPolling => _stopPollingCommand.running;
  bool get isCheckingAndUpdatingChannel =>
      _checkAndUpdateChannelCommand.running;
  bool get isCheckingAndUpdatingScore => _checkAndUpdateScoreCommand.running;
  bool get isInitializingWebView => _initializeWebViewCommand.running;
  bool get isLoadingUrl => _loadUrlCommand.running;
  bool get isReloadingWebView => _reloadWebViewCommand.running;
  bool get hasError =>
      _initializeHomeCommand.error ||
      _startPollingCommand.error ||
      _startPollingWithIdCommand.error ||
      _stopPollingCommand.error ||
      _checkAndUpdateChannelCommand.error ||
      _checkAndUpdateScoreCommand.error ||
      _initializeWebViewCommand.error ||
      _loadUrlCommand.error ||
      _reloadWebViewCommand.error;
  Exception? get error =>
      _initializeHomeCommand.result?.asErrorValue ??
      _startPollingCommand.result?.asErrorValue ??
      _startPollingWithIdCommand.result?.asErrorValue ??
      _stopPollingCommand.result?.asErrorValue ??
      _checkAndUpdateChannelCommand.result?.asErrorValue ??
      _checkAndUpdateScoreCommand.result?.asErrorValue ??
      _initializeWebViewCommand.result?.asErrorValue ??
      _loadUrlCommand.result?.asErrorValue ??
      _reloadWebViewCommand.result?.asErrorValue;

  @override
  void dispose() {
    _initializeHomeCommand.dispose();
    _startPollingCommand.dispose();
    _startPollingWithIdCommand.dispose();
    _stopPollingCommand.dispose();
    _checkAndUpdateChannelCommand.dispose();
    _checkAndUpdateScoreCommand.dispose();
    _initializeWebViewCommand.dispose();
    _loadUrlCommand.dispose();
    _reloadWebViewCommand.dispose();
    super.dispose();
  }
}
