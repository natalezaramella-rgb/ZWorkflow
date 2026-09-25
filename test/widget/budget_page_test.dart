import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/budget/domain/models/budget.dart';
import 'package:z_workflow/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:z_workflow/features/budget/presentation/pages/budget_page.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../helpers/mock_repositories.dart';

void main() {
  late MockBudgetBloc mockBudgetBloc;

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<BudgetBloc>.value(
        value: mockBudgetBloc,
        child: const BudgetPage(),
      ),
    );
  }

  testWidgets('renders loading spinner when BudgetLoading', (tester) async {
    when(() => mockBudgetBloc.state).thenReturn(const BudgetLoading());
    when(() => mockBudgetBloc.stream)
        .thenAnswer((_) => Stream.value(const BudgetLoading()));

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders budget cards with department names when BudgetLoaded',
      (tester) async {
    const statuses = [
      BudgetStatus(
        departmentId: 'dept-it',
        departmentName: 'IT & Infrastructure',
        year: 2026,
        allocatedCapex: 100000,
        allocatedOpex: 50000,
        consumedCapex: 40000,
        consumedOpex: 25000,
      ),
    ];

    when(() => mockBudgetBloc.state).thenReturn(const BudgetLoaded(statuses));
    when(() => mockBudgetBloc.stream)
        .thenAnswer((_) => Stream.value(const BudgetLoaded(statuses)));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('IT & Infrastructure'), findsOneWidget);
    expect(find.text('CAPEX'), findsOneWidget);
    expect(find.text('OPEX'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget); // 40000 / 100000
    expect(find.text('50%'), findsOneWidget); // 25000 / 50000
  });
}
