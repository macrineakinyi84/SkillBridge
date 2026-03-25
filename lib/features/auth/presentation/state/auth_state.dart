import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? message,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        message: message,
      );

  @override
  List<Object?> get props => [status, user, message];
}
