import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/auth/domain/models/app_user.dart';
import 'package:z_workflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:z_workflow/features/purchase_request/domain/enums/request_enums.dart';

import '../../helpers/mock_repositories.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  const testUser = AppUser(
    uid: 'usr-1',
    email: 'mario.rossi@company.com',
    displayName: 'Mario Rossi',
    tenantId: 'tenant-1',
    roles: [UserRole.requester],
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(authRepository: mockAuthRepository);
      expect(bloc.state, equals(const AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when user stream emits authenticated user',
      setUp: () {
        when(() => mockAuthRepository.userStream)
            .thenAnswer((_) => Stream.value(testUser));
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when user stream emits empty user',
      setUp: () {
        when(() => mockAuthRepository.userStream)
            .thenAnswer((_) => Stream.value(AppUser.empty));
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading] when signInWithEmailAndPassword succeeds',
      setUp: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
              email: 'mario.rossi@company.com',
              password: 'password123',
            )).thenAnswer((_) async => testUser);
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(
        email: 'mario.rossi@company.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, AuthUnauthenticated] when signInWithEmailAndPassword throws',
      setUp: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
              email: 'mario.rossi@company.com',
              password: 'wrong',
            )).thenThrow(Exception('Invalid credentials'));
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(
        email: 'mario.rossi@company.com',
        password: 'wrong',
      )),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'calls signOut on AuthSignOutRequested',
      setUp: () {
        when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
      },
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      verify: (_) {
        verify(() => mockAuthRepository.signOut()).called(1);
      },
    );
  });
}
