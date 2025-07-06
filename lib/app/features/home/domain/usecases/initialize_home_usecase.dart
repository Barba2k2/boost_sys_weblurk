import '../../../../utils/utils.dart';
import '../repositories/home_repository.dart';

class InitializeHomeUseCase {
  final HomeRepository _repository;

  InitializeHomeUseCase(this._repository);

  Future<Result<void>> execute() async {
    return await _repository.initializeHome();
  }
}
