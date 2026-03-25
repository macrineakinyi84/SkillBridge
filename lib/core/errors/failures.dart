import 'package:equatable/equatable.dart';

// Domain failures instead of raw exceptions so presentation can show
// user-friendly messages and retry without depending on data-layer types.
abstract class Failure extends Equatable {
  const Failure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Auth-related failure (login, register, OTP).
class AuthFailure extends Failure {
  const AuthFailure({super.message});
}

/// Network or API failure.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

/// Assessment / skills engine failure.
class AssessmentFailure extends Failure {
  const AssessmentFailure({super.message});
}
