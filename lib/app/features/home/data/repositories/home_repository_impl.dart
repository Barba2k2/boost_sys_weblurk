import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../utils/utils.dart';
import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/services/home_service.dart';
import '../../domain/services/polling_service.dart';
import '../../domain/services/webview_service.dart';

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
  Future<Result<List<dynamic>>> fetchSchedules() async {
    try {
      _logger.info('Repository: Iniciando busca de schedules');
      
      final data = await _homeService.fetchSchedules();
      
      return Result.ok(data).when(
        success: (schedules) {
          _logger.info('Repository: Schedules buscados com sucesso: ${schedules.length}');
          return Result.ok(schedules);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao buscar schedules', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Buscando schedules...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar schedules', e, s);
      return Result.error(Failure('Erro ao buscar schedules: $e'));
    }
  }

  @override
  Future<Result<List<ScheduleListEntity>>> fetchScheduleLists() async {
    try {
      _logger.info('Repository: Iniciando busca de listas de schedules');
      
      final data = await _homeService.fetchScheduleLists();
      
      return Result.ok(data).when(
        success: (lists) {
          _logger.info('Repository: Listas de schedules buscadas com sucesso: ${lists.length}');
          return Result.ok(lists);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao buscar listas de schedules', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Buscando listas de schedules...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar listas de schedules', e, s);
      return Result.error(Failure('Erro ao buscar listas de schedules: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getAvailableListNames() async {
    try {
      _logger.info('Repository: Iniciando busca de nomes das listas');
      
      final data = await _homeService.getAvailableListNames();
      
      return Result.ok(data).when(
        success: (names) {
          _logger.info('Repository: Nomes das listas buscados com sucesso: ${names.length}');
          return Result.ok(names);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao buscar nomes das listas', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Buscando nomes das listas...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar nomes das listas', e, s);
      return Result.error(Failure('Erro ao buscar nomes das listas: $e'));
    }
  }

  @override
  Future<Result<ScheduleListEntity?>> fetchScheduleListByName(String listName) async {
    try {
      _logger.info('Repository: Iniciando busca de lista por nome: $listName');
      
      final data = await _homeService.fetchScheduleListByName(listName);
      
      return Result.ok(data).when(
        success: (list) {
          _logger.info('Repository: Lista buscada com sucesso: ${list?.name ?? 'não encontrada'}');
          return Result.ok(list);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao buscar lista por nome', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Buscando lista por nome...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar lista por nome', e, s);
      return Result.error(Failure('Erro ao buscar lista por nome: $e'));
    }
  }

  @override
  Future<Result<void>> updateLists() async {
    try {
      _logger.info('Repository: Iniciando atualização de listas');
      
      await _homeService.updateLists();
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: Listas atualizadas com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao atualizar listas', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Atualizando listas...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao atualizar listas', e, s);
      return Result.error(Failure('Erro ao atualizar listas: $e'));
    }
  }

  @override
  Future<Result<String?>> fetchCurrentChannel() async {
    try {
      _logger.info('Repository: Iniciando busca de canal atual');
      
      final data = await _homeService.fetchCurrentChannel();
      
      return Result.ok(data).when(
        success: (channel) {
          _logger.info('Repository: Canal atual buscado com sucesso: $channel');
          return Result.ok(channel);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao buscar canal atual', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Buscando canal atual...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar canal atual', e, s);
      return Result.error(Failure('Erro ao buscar canal atual: $e'));
    }
  }

  @override
  Future<Result<String?>> fetchCurrentChannelForList(String listName) async {
    try {
      _logger.info('Repository: Iniciando busca de canal atual para lista: $listName');
      
      final data = await _homeService.fetchCurrentChannelForList(listName);
      
      return Result.ok(data).when(
        success: (channel) {
          _logger.info('Repository: Canal atual para lista buscado com sucesso: $channel');
          return Result.ok(channel);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao buscar canal atual para lista', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Buscando canal atual para lista...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao buscar canal atual para lista', e, s);
      return Result.error(Failure('Erro ao buscar canal atual para lista: $e'));
    }
  }

  @override
  Future<Result<void>> saveScore(
    int streamerId,
    DateTime date,
    int hour,
    int minute,
    int points,
  ) async {
    try {
      _logger.info('Repository: Iniciando salvamento de score');
      
      await _homeService.saveScore(streamerId, date, hour, minute, points);
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: Score salvo com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao salvar score', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Salvando score...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao salvar score', e, s);
      return Result.error(Failure('Erro ao salvar score: $e'));
    }
  }

  @override
  Future<Result<void>> startPolling(int streamerId) async {
    try {
      _logger.info('Repository: Iniciando polling para streamer: $streamerId');
      
      await _pollingService.startPolling(streamerId);
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: Polling iniciado com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao iniciar polling', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Iniciando polling...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao iniciar polling', e, s);
      return Result.error(Failure('Erro ao iniciar polling: $e'));
    }
  }

  @override
  Future<Result<void>> stopPolling() async {
    try {
      _logger.info('Repository: Parando polling');
      
      await _pollingService.stopPolling();
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: Polling parado com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao parar polling', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Parando polling...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao parar polling', e, s);
      return Result.error(Failure('Erro ao parar polling: $e'));
    }
  }

  @override
  Future<Result<void>> loadUrl(String url) async {
    try {
      _logger.info('Repository: Carregando URL: $url');
      
      await _webViewService.loadUrl(url);
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: URL carregada com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao carregar URL', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Carregando URL...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao carregar URL', e, s);
      return Result.error(Failure('Erro ao carregar URL: $e'));
    }
  }

  @override
  Future<Result<void>> reloadWebView() async {
    try {
      _logger.info('Repository: Recarregando WebView');
      
      await _webViewService.reloadWebView();
      
      return Result.ok(null).when(
        success: (_) {
          _logger.info('Repository: WebView recarregado com sucesso');
          return Result.ok(null);
        },
        error: (failure) {
          _logger.error('Repository: Erro ao recarregar WebView', failure);
          return Result.error(failure);
        },
        loading: () {
          _logger.info('Repository: Recarregando WebView...');
          return Result.loading();
        },
      );
    } catch (e, s) {
      _logger.error('Repository: Erro inesperado ao recarregar WebView', e, s);
      return Result.error(Failure('Erro ao recarregar WebView: $e'));
    }
  }
}
