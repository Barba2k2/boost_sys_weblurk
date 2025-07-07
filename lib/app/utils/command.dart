import 'package:flutter/foundation.dart';
import '../core/result/result.dart';

abstract class Command<T> extends ChangeNotifier {
  Command();
  bool _running = false;
  AppResult<T>? _result;

  bool get running => _running;
  AppResult<T>? get result => _result;
  bool get error => _result?.isError ?? false;
  bool get completed => _result != null;

  Future<void> _execute(Future<AppResult<T>> Function() action) async {
    if (_running) return;
    _running = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

class Command0<T> extends Command<T> {
  Command0(this._action);
  final Future<AppResult<T>> Function() _action;
  Future<void> execute() async => _execute(_action);
}

class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final Future<AppResult<T>> Function(A) _action;
  Future<void> execute(A arg) async => _execute(() => _action(arg));
} 