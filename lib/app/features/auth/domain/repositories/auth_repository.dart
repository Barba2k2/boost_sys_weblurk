import '../../../../utils/utils.dart';
import '../entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';

abstract class AuthRepository {
  Future<Result<UserEntity, Exception>> login(String username, String password);
  Future<Result<void, Exception>> logout();
  Future<Result<bool, Exception>> checkLoginStatus();
}
