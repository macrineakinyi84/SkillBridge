import '../repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._repository);
  final AuthRepository _repository;

  Future call({
    required String email,
    required String password,
  }) =>
      _repository.signInWithEmailAndPassword(email: email, password: password);
}
