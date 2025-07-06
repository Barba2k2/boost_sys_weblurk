import '../../../../utils/utils.dart';
import '../repositories/webview_repository.dart';

class ReloadWebViewUseCase {
  final WebViewRepository _repository;

  ReloadWebViewUseCase(this._repository);

  Future<Result<void>> execute() async {
    return await _repository.reload();
  }
}
