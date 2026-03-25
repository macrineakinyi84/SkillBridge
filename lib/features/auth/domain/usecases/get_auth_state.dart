import '../repositories/auth_repository.dart';

class GetAuthState {
  const GetAuthState(this._repository);
  final AuthRepository _repository;

  Stream get call => _repository.authStateChanges;
}
