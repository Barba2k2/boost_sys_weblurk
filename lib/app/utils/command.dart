import 'package:flutter/foundation.dart';
import 'result.dart';

abstract class Command<T> extends ChangeNotifier {
  Command();
  bool _running = false;
  Result<T>? _result;

  bool get running => _running;
  Result<T>? get result => _result;
  bool get error => _result is ErrorResult<T>;
  bool get completed => _result is OkResult<T>;

  Future<void> _execute(Future<Result<T>> Function() action) async {
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
  final Future<Result<T>> Function() _action;
  Future<void> execute() async => _execute(_action);
}

class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final Future<Result<T>> Function(A) _action;
  Future<void> execute(A arg) async => _execute(() => _action(arg));
} 