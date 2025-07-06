import '../../../../utils/utils.dart';
import '../repositories/webview_repository.dart';

class LoadUrlUseCase {
  final WebViewRepository _repository;

  LoadUrlUseCase(this._repository);

  Future<Result<void>> execute(String url) async {
    return await _repository.loadUrl(url);
  }
}
