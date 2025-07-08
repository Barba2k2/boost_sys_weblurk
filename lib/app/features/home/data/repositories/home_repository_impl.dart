import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/services/home_service.dart';
import '../../domain/services/polling_service.dart';
import '../../domain/services/webview_service.dart';
import '../../../../core/result/result.dart';
import 'package:result_dart/result_dart.dart' as rd;

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required HomeService homeService,
    required PollingService pollingService,
    required WebViewService webViewService,
    required AppLogger logger,
  })  : _homeService = homeService,
        _pollingService = pollingService,
        _webViewService = webViewService,
        _logger = logger;

  final HomeService _homeService;
  final PollingService _pollingService;
  final WebViewService _webViewService;
  final AppLogger _logger;

  @override
  Future<AppResult<List<dynamic>>> fetchSchedules() async {
    try {
      _logger.info('Repository: Iniciando busca de schedules');
      final data = await _homeService.fetchSchedules();
      _logger.info('Repository: Schedules buscados com sucesso: ${data.length}');
      return AppSuccess(data);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar schedules', e, s);
      return AppFailure(Exception('Erro ao buscar schedules: $e'));
    }
  }

  @override
  Future<AppResult<List<ScheduleListEntity>>> fetchScheduleLists() async {
    try {
      _logger.info('Repository: Iniciando busca de listas de schedules');
      final data = await _homeService.fetchScheduleLists();
      _logger.info('Repository: Listas de schedules buscadas com sucesso: ${data.length}');
      return AppSuccess(data);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar listas de schedules', e, s);
      return AppFailure(Exception('Erro ao buscar listas de schedules: $e'));
    }
  }

  @override
  Future<AppResult<List<String>>> getAvailableListNames() async {
    try {
      _logger.info('Repository: Iniciando busca de nomes das listas');
      final data = await _homeService.getAvailableListNames();
      _logger.info('Repository: Nomes das listas buscados com sucesso: ${data.length}');
      return AppSuccess(data);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar nomes das listas', e, s);
      return AppFailure(Exception('Erro ao buscar nomes das listas: $e'));
    }
  }

  @override
  Future<AppResult<ScheduleListEntity?>> fetchScheduleListByName(String listName) async {
    try {
      _logger.info('Repository: Iniciando busca de lista por nome: $listName');
      final data = await _homeService.fetchScheduleListByName(listName);
      _logger.info('Repository: Lista buscada com sucesso: ${data?.name ?? 'não encontrada'}');
      return AppSuccess(data);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar lista por nome', e, s);
      return AppFailure(Exception('Erro ao buscar lista por nome: $e'));
    }
  }

  @override
  Future<AppResult<void>> updateLists() async {
    try {
      _logger.info('Repository: Iniciando atualização de listas');
      await _homeService.updateLists();
      _logger.info('Repository: Listas atualizadas com sucesso');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao atualizar listas', e, s);
      return AppFailure(Exception('Erro ao atualizar listas: $e'));
    }
  }

  @override
  Future<AppResult<String?>> fetchCurrentChannel() async {
    try {
      _logger.info('Repository: Iniciando busca de canal atual');
      final data = await _homeService.fetchCurrentChannel();
      _logger.info('Repository: Canal atual buscado com sucesso: $data');
      return AppSuccess(data);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar canal atual', e, s);
      return AppFailure(Exception('Erro ao buscar canal atual: $e'));
    }
  }

  @override
  Future<AppResult<String?>> fetchCurrentChannelForList(String listName) async {
    try {
      _logger.info('Repository: Iniciando busca de canal atual para lista: $listName');
      final data = await _homeService.fetchCurrentChannelForList(listName);
      _logger.info('Repository: Canal atual para lista buscado com sucesso: $data');
      return AppSuccess(data);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar canal atual para lista', e, s);
      return AppFailure(Exception('Erro ao buscar canal atual para lista: $e'));
    }
  }

  @override
  Future<AppResult<void>> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  ) async {
    try {
      _logger.info('Repository: Iniciando salvamento de score');
      await _homeService.saveScore(streamerId, date, hour, minute, points);
      _logger.info('Repository: Score salvo com sucesso');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao salvar score', e, s);
      return AppFailure(Exception('Erro ao salvar score: $e'));
    }
  }

  @override
  Future<AppResult<void>> startPolling(int streamerId) async {
    try {
      _logger.info('Repository: Iniciando polling para streamer: $streamerId');
      await _pollingService.startPolling(streamerId);
      _logger.info('Repository: Polling iniciado com sucesso');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao iniciar polling', e, s);
      return AppFailure(Exception('Erro ao iniciar polling: $e'));
    }
  }

  @override
  Future<AppResult<void>> stopPolling() async {
    try {
      _logger.info('Repository: Parando polling');
      await _pollingService.stopPolling();
      _logger.info('Repository: Polling parado com sucesso');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao parar polling', e, s);
      return AppFailure(Exception('Erro ao parar polling: $e'));
    }
  }

  @override
  Future<AppResult<void>> loadUrl(String url) async {
    try {
      _logger.info('Repository: Carregando URL: $url');
      await _webViewService.loadUrl(url);
      _logger.info('Repository: URL carregada com sucesso');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao carregar URL', e, s);
      return AppFailure(Exception('Erro ao carregar URL: $e'));
    }
  }

  @override
  Future<AppResult<void>> reloadWebView() async {
    try {
      _logger.info('Repository: Recarregando WebView');
      await _webViewService.reloadWebView();
      _logger.info('Repository: WebView recarregado com sucesso');
      return AppSuccess(null);
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao recarregar WebView', e, s);
      return AppFailure(Exception('Erro ao recarregar WebView: $e'));
    }
  }
}
