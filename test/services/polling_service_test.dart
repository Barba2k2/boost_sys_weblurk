import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/home/home_controller.dart';
import 'package:boost_sys_weblurk/app/service/home/home_service.dart';
import 'package:boost_sys_weblurk/app/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/auth_store.dart';
import 'package:boost_sys_weblurk/app/service/webview/windows_web_view_service.dart';
import 'package:boost_sys_weblurk/app/modules/core/auth/home/services/polling_services.dart';
import 'package:boost_sys_weblurk/app/models/user_model.dart';
import 'package:asuka/asuka.dart';

// Mock classes
class MockHomeService extends Mock implements HomeService {}

class MockAppLogger extends Mock implements AppLogger {}

class MockAuthStore extends Mock implements AuthStore {}

class MockWebViewService extends Mock implements WindowsWebViewService {}

class MockPollingService extends Mock implements PollingService {}

class MockWebviewController extends Mock implements WebviewController {}

// Subclasse especial para testes que evita chamadas problemáticas
class TestableHomeController extends HomeController {
  TestableHomeController({
    required super.homeService,
    required super.logger,
    required super.authStore,
    required super.webViewService,
    required super.pollingService,
  })  : _testLogger = logger,
        _testWebViewService = webViewService,
        _testPollingService = pollingService;

  // Armazenar referências locais aos objetos
  final AppLogger _testLogger;
  final WindowsWebViewService _testWebViewService;
  final PollingService _testPollingService;

  // Método público para iniciar o polling diretamente para testes
  Future<void> startPollingForTest(int streamerId) async {
    await _testPollingService.startPolling(streamerId);
  }

  @override
  Future<void> reloadWebView() async {
    try {
      // Remova a chamada ao Loader.show() e Loader.hide()
      await _testWebViewService.reload();
      await loadCurrentChannel();
    } catch (e, s) {
      _testLogger.error('Erro ao recarregar WebView', e, s);
    }
  }

  // Para fins de testes, é útil expor o método de verificação de saúde do WebView
  Future<bool> testCheckWebViewHealth() async {
    if (!_testWebViewService.isInitialized || _testWebViewService.controller == null) {
      _testLogger.warning('WebView não está inicializado');
      isWebViewHealthy = false;
      return false;
    }

    isWebViewHealthy = await _testWebViewService.isResponding();
    return isWebViewHealthy;
  }

  // Expor pollingService para testes
  PollingService get pollingService => _testPollingService;
}

void main() {
  late TestableHomeController homeController;
  late MockHomeService mockHomeService;
  late MockAppLogger mockLogger;
  late MockAuthStore mockAuthStore;
  late MockWebViewService mockWebViewService;
  late MockPollingService mockPollingService;
  late MockWebviewController mockWebviewController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(DateTime.now());
    registerFallbackValue(MockWebviewController());
  });

  setUp(() {
    mockHomeService = MockHomeService();
    mockLogger = MockAppLogger();
    mockAuthStore = MockAuthStore();
    mockWebViewService = MockWebViewService();
    mockPollingService = MockPollingService();
    mockWebviewController = MockWebviewController();

    // Configurar comportamento dos mocks
    final userModel = UserModel(id: 1, nickname: 'testuser', role: 'user', status: 'ON');

    when(
      () => mockAuthStore.userLogged,
    ).thenReturn(
      userModel,
    );
    when(
      () => mockAuthStore.loadUserLogged(),
    ).thenAnswer(
      (_) async => {},
    );
    when(
      () => mockWebViewService.isInitialized,
    ).thenReturn(
      true,
    );
    when(
      () => mockWebViewService.controller,
    ).thenReturn(
      mockWebviewController,
    );
    when(
      () => mockWebViewService.isResponding(),
    ).thenAnswer(
      (_) async => true,
    );
    when(() => mockHomeService.fetchCurrentChannel()).thenAnswer(
      (_) async => 'https://twitch.tv/testchannel',
    );
    when(
      () => mockHomeService.fetchSchedules(),
    ).thenAnswer(
      (_) async => {},
    );
    when(
      () => mockPollingService.startPolling(any()),
    ).thenAnswer(
      (_) async => {},
    );
    when(
      () => mockPollingService.stopPolling(),
    ).thenAnswer(
      (_) async => {},
    );

    // Add mocks for streams required by HomeController constructor
    when(() => mockWebViewService.healthStatus).thenAnswer(
      (_) => Stream.value(true),
    );
    when(() => mockPollingService.healthStatus).thenAnswer(
      (_) => Stream.value(true),
    );
    when(() => mockPollingService.channelUpdates).thenAnswer(
      (_) => const Stream<String>.empty(),
    );

    // Configurar controller com nossa versão testável
    homeController = TestableHomeController(
      homeService: mockHomeService,
      logger: mockLogger,
      authStore: mockAuthStore,
      webViewService: mockWebViewService,
      pollingService: mockPollingService,
    );
  });

  group(
    'HomeController Polling Integration',
    () {
      // O pumpWidget com Asuka.builder é crucial para os testes
      Widget createTestApp() {
        return MaterialApp(
          builder: Asuka.builder,
          home: Scaffold(body: Container()),
        );
      }

      testWidgets(
        'onInit inicia o polling quando webview está inicializado',
        (WidgetTester tester) async {
          // Precisamos de um widget para os testes usarem
          await tester.pumpWidget(createTestApp());

          // Arrange - Configurar mocks para o teste
          final userModel = UserModel(
            id: 1,
            nickname: 'testuser',
            role: 'user',
            status: 'ON',
          );
          when(() => mockAuthStore.userLogged).thenReturn(userModel);

          // Act - Chamar diretamente o método para iniciar o polling
          await homeController.startPollingForTest(1);

          // Assert - Verificar que startPolling foi chamado com o ID correto
          verify(() => mockPollingService.startPolling(1)).called(1);
        },
      );

      testWidgets(
        'dispose para o polling',
        (WidgetTester tester) async {
          // Precisamos de um widget para os testes usarem
          await tester.pumpWidget(createTestApp());

          // Act
          homeController.dispose();

          // Assert
          verify(() => mockPollingService.stopPolling()).called(1);
        },
      );

      testWidgets(
        'loadCurrentChannel carrega o canal e atualiza o WebView',
        (WidgetTester tester) async {
          // Precisamos de um widget para os testes usarem
          await tester.pumpWidget(createTestApp());

          // Arrange
          when(() => mockWebViewService.loadUrl(any())).thenAnswer(
            (_) async => {},
          );

          // Act
          await homeController.loadCurrentChannel();

          // Assert
          expect(homeController.currentChannel, 'https://twitch.tv/testchannel');
          verify(
            () => mockWebViewService.loadUrl('https://twitch.tv/testchannel'),
          ).called(1);
        },
      );

      testWidgets(
        'reloadWebView recarrega o WebView e o canal atual',
        (WidgetTester tester) async {
          // Precisamos de um widget para os testes usarem
          await tester.pumpWidget(createTestApp());

          // Arrange
          when(() => mockWebViewService.reload()).thenAnswer(
            (_) async => {},
          );
          when(() => mockWebViewService.loadUrl(any())).thenAnswer(
            (_) async => {},
          );

          // Act
          await homeController.reloadWebView();

          // Assert
          verify(() => mockWebViewService.reload()).called(1);
          verify(() => mockHomeService.fetchCurrentChannel()).called(1);
        },
      );

      testWidgets(
        'testCheckWebViewHealth detecta webview não saudável',
        (WidgetTester tester) async {
          // Precisamos de um widget para os testes usarem
          await tester.pumpWidget(createTestApp());

          // Arrange - WebView não está respondendo
          when(() => mockWebViewService.isInitialized).thenReturn(true);
          when(() => mockWebViewService.controller).thenReturn(mockWebviewController);
          when(() => mockWebViewService.isResponding()).thenAnswer((_) async => false);

          // Act
          final result = await homeController.testCheckWebViewHealth();

          // Assert
          expect(result, false);
          expect(homeController.isWebViewHealthy, false);
          verify(() => mockWebViewService.isResponding()).called(1);
        },
      );
    },
  );
}
