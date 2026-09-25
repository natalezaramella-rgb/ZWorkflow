import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../../domain/models/app_user.dart';

// ── Events ─────────────────────────────────────────────────────────

/// Base event for [AuthBloc].
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the app starts to check auth state.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Triggered when the auth state changes from Firebase.
class _AuthUserChanged extends AuthEvent {
  const _AuthUserChanged(this.user);
  final AppUser user;

  @override
  List<Object?> get props => [user];
}

/// Triggered when the user requests sign in with email/password.
class AuthSignInWithEmailRequested extends AuthEvent {
  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Triggered when the user requests registration with email/password.
class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Triggered when the user requests Google Sign-In.
class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

/// Triggered when the user requests sign out.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

// ── States ─────────────────────────────────────────────────────────

/// Base state for [AuthBloc].
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state while checking auth.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// The user is authenticated.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AppUser user;

  @override
  List<Object?> get props => [user];
}

/// The user is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An authentication operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// An authentication error occurred.
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────

/// BLoC that manages authentication state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc].
  AuthBloc({required this.authRepository})
      : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<_AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final AuthRepository authRepository;
  StreamSubscription<AppUser>? _userSubscription;

  void _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) {
    _userSubscription?.cancel();
    _userSubscription = authRepository.userStream.listen(
      (user) => add(_AuthUserChanged(user)),
    );
  }

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user.isEmpty) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(event.user));
    }
  }

  Future<void> _onSignInWithEmail(
      AuthSignInWithEmailRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRegister(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithGoogle(
      AuthSignInWithGoogleRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.signInWithGoogle();
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await authRepository.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
