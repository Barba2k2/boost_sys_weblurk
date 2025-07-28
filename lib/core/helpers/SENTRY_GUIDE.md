# Guia de Uso do Sentry Flutter

## Configuração

O Sentry Flutter foi configurado no projeto com as seguintes funcionalidades:

### 1. Configuração Principal (`sentry_config.dart`)

- Configuração centralizada do Sentry
- Métodos para captura de exceções e mensagens
- Configuração de ambiente e release

### 2. Error Handler (`error_handler.dart`)

- Captura automática de erros não tratados
- Setup de handlers globais para FlutterError e PlatformDispatcher

### 3. Sentry Mixin (`sentry_mixin.dart`)

- Mixin para facilitar o uso do Sentry nos ViewModels
- Métodos para captura de erros, informações e warnings
- Configuração de contexto do usuário

## Como Usar

### 1. Em ViewModels

```dart
class MeuViewModel extends ChangeNotifier with SentryMixin {

  Future<void> minhaOperacao() async {
    try {
      // Captura informação
      await captureInfo('Iniciando operação');

      // Sua lógica aqui
      await fazerAlgumaCoisa();

      // Captura sucesso
      await captureInfo('Operação concluída com sucesso');

    } catch (e, stackTrace) {
      // Captura erro
      await captureError(e, stackTrace, context: 'minha_operacao');
    }
  }

  Future<void> configurarUsuario(UserModel user) async {
    await setUserContext(
      id: user.id.toString(),
      username: user.nickname,
    );
  }
}
```

### 2. Captura Manual de Erros

```dart
import 'package:boost_sys_weblurk/core/helpers/error_handler.dart';

// Em qualquer lugar do código
await ErrorHandler.captureError(
  exception,
  stackTrace,
  context: 'contexto_do_erro',
);

await ErrorHandler.captureInfo(
  'Informação importante',
  data: {'chave': 'valor'},
);
```

### 3. Configuração de Ambiente

Para configurar diferentes ambientes, você pode usar variáveis de ambiente:

```bash
# Para desenvolvimento
flutter run --dart-define=ENVIRONMENT=development

# Para produção
flutter run --dart-define=ENVIRONMENT=production
```

### 4. Configuração do DSN

**IMPORTANTE**: Você precisa substituir o DSN no arquivo `sentry_config.dart`:

```dart
static const String _dsn = 'https://seu-dsn@sentry.io/seu-projeto';
```

## Funcionalidades Disponíveis

### SentryMixin

- `captureError()` - Captura exceções
- `captureInfo()` - Captura informações
- `captureWarning()` - Captura warnings
- `setUserContext()` - Define contexto do usuário
- `setTag()` - Define tags para segmentação

### ErrorHandler

- `setupErrorHandling()` - Configura handlers globais
- `captureError()` - Captura erros manualmente
- `captureInfo()` - Captura informações
- `captureWarning()` - Captura warnings

### SentryConfig

- `init()` - Inicializa o Sentry
- `captureException()` - Captura exceções
- `captureMessage()` - Captura mensagens
- `addBreadcrumb()` - Adiciona breadcrumbs

## Boas Práticas

1. **Sempre capture o contexto**: Use o parâmetro `context` para identificar onde o erro ocorreu
2. **Use breadcrumbs**: Adicione breadcrumbs para rastrear o fluxo da aplicação
3. **Configure o usuário**: Sempre configure o contexto do usuário após login
4. **Não capture dados sensíveis**: Evite capturar senhas, tokens, etc.
5. **Use tags para segmentação**: Configure tags para facilitar a análise

## Exemplo Completo

```dart
class LoginViewModel extends ChangeNotifier with SentryMixin {

  Future<Result<UserModel>> login(String email, String password) async {
    try {
      await captureInfo('Iniciando login', data: {'email': email});

      final user = await userService.login(email, password);

      await setUserContext(
        id: user.id.toString(),
        username: user.nickname,
      );

      await captureInfo('Login realizado com sucesso');
      return Result.ok(user);

    } catch (e, stackTrace) {
      await captureError(e, stackTrace, context: 'login_error');
      return Result.error(e);
    }
  }
}
```
