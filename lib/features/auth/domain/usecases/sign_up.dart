import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);
  final AuthRepository _repository;

  Future call({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _repository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
}
