import 'package:webview_windows/webview_windows.dart';

import '../../../../utils/utils.dart';
import '../repositories/webview_repository.dart';

class InitializeWebViewUseCase {
  final WebViewRepository _repository;

  InitializeWebViewUseCase(this._repository);

  Future<Result<void>> execute(WebviewController controller) async {
    return await _repository.initializeWebView(controller);
  }
}
