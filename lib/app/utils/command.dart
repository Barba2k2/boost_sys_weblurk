import 'package:flutter/widgets.dart';

import 'result.dart';

// Command 0 dont have input parameters
typedef CommandAction0<Output> = Future<Result<Output>> Function();

// Command 1 have input parameters
typedef CommandAction1<Output, Input> = Future<Result<Output>> Function(Input);

abstract class Command<Output> extends ChangeNotifier {
  // Verify if the command is running
  bool _running = false;

  bool get running => _running;

  // State representation => [Ok // Error // Null]
  Result<Output>? _result;

  Result<Output>? get result => _result;

  // Verify if the state is completed
  bool get completed => _result is Ok;

  // Verify if the state is in error
  bool get error => _result is Error;

  // Execute the command
  Future<void> _execute(CommandAction0<Output> action) async {
    if (_running) return;

    // Action in progress
    _running = true;

    // Reset the result
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

class Command0<Output> extends Command<Output> {
  final CommandAction0<Output> action;
  Command0(this.action);

  Future<void> execute() async {
    await _execute(() => action());
  }
}

class Command1<Output, Input> extends Command<Output> {
  final CommandAction1<Output, Input> action;
  Command1(this.action);

  Future<void> execute(Input input) async {
    await _execute(() => action(input));
  }
}
