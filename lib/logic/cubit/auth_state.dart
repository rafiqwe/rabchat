import 'package:equatable/equatable.dart';
import 'package:rabchats/data/model/user_model.dart';

enum AuthStatus { initial, loading, error, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  // the class constructor
  const AuthState({
     this.error,
    this.user,
    this.status = AuthStatus.initial,
  });

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      error: error ?? this.error,
      user: user ?? this.user,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status, error, user];
}
