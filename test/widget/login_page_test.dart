import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:z_workflow/features/auth/presentation/pages/login_page.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../helpers/mock_repositories.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(const AuthUnauthenticated()));
  });

  Widget buildSubject() {
    return MaterialApp(
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('renders all core UI elements', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Accedi con email'), findsOneWidget);
      expect(find.text('Accedi con Google'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap the login button without filling fields
      final loginButtonFinder =
          find.widgetWithText(ElevatedButton, 'Accedi con email');
      await tester.tap(loginButtonFinder);
      await tester.pumpAndSettle();

      // Email and password required errors should appear
      expect(find.text('Email required'), findsOneWidget);
      expect(find.text('Password required'), findsOneWidget);
    });
  });
}
