import '../repositories/auth_repository.dart';

class SignOut {
  const SignOut(this._repository);
  final AuthRepository _repository;

  Future call() => _repository.signOut();
}
