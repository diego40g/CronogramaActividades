import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  StreamSubscription<AppUser?>? _authSubscription;

  AuthBloc(this._authRepository, this._signInWithGoogle, this._signOut)
    : super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithGooglePressed>(_onSignInWithGooglePressed);
    on<AuthSignOutPressed>(_onSignOutPressed);
    on<AuthUserChanged>(_onUserChanged);

    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(AuthState.authenticated(currentUser));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onSignInWithGooglePressed(
    AuthSignInWithGooglePressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _signInWithGoogle();

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignOutPressed(
    AuthSignOutPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _signOut();

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

@Freezed(fromJson: false, toJson: false)
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkRequested() = AuthCheckRequested;
  const factory AuthEvent.signInWithGooglePressed() =
      AuthSignInWithGooglePressed;
  const factory AuthEvent.signOutPressed() = AuthSignOutPressed;
  const factory AuthEvent.userChanged(AppUser? user) = AuthUserChanged;
}

@Freezed(fromJson: false, toJson: false)
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AppUser user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
