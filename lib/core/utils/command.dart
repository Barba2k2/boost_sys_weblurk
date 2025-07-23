import 'package:flutter/foundation.dart';
import 'result.dart';

// Tipos de função para Commands
typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A params);
typedef CommandAction2<T, A, B> = Future<Result<T>> Function(
    A params1, B params2);

// Command base abstrato
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Result<T>? _result;
  Result<T>? get result => _result;

  bool get error => _result is Error;
  bool get completed => _result is Ok;

  Future<void> _execute(CommandAction0<T> action) async {
    if (_running) return;
    _result = null;
    _running = true;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

// Command sem parâmetros
class Command0<T> extends Command<T> {
  Command0(this.action);
  final CommandAction0<T> action;

  Future<void> execute() async {
    await _execute(action);
  }
}

// Command com 1 parâmetro
class Command1<T, A> extends Command<T> {
  Command1(this.action);
  final CommandAction1<T, A> action;

  Future<void> execute(A params) async {
    await _execute(() => action(params));
  }
}

// Command com 2 parâmetros
class Command2<T, A, B> extends Command<T> {
  Command2(this.action);
  final CommandAction2<T, A, B> action;

  Future<void> execute(A params1, B params2) async {
    await _execute(() => action(params1, params2));
  }
}
