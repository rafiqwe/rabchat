import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabchats/data/repositories/auth_repo.dart';
import 'package:rabchats/logic/cubit/auth_state.dart';

class AuthCubit extends Cubit {
  final AuthRepo _authRepo;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({required AuthRepo authRepo})
    : _authRepo = authRepo,
      super(AuthState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(state: AuthStatus.initial));
    _authStateSubscription = _authRepo.authStateChanges!.listen((user) async {
      if (user != null) {
        try {
          final userData = await _authRepo.getUserData(user.uid);
          emit(
            state.copyWith(status: AuthStatus.authenticated, user: userData),
          );
        } catch (e) {
          emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
        }
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    });
  }
}
