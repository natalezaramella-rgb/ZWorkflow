import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/auth/domain/models/app_user.dart';
import 'package:z_workflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:z_workflow/features/budget/data/budget_repository.dart';
import 'package:z_workflow/features/organization/data/organization_repository.dart';
import 'package:z_workflow/features/purchase_request/data/purchase_request_repository.dart';
import 'package:z_workflow/features/purchase_request/presentation/pages/request_form_page.dart';
import 'package:z_workflow/features/workflow/data/workflow_repository.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../helpers/mock_repositories.dart';

void main() {
  testWidgets('RequestFormPage renders all input fields and validates empty submission',
      (tester) async {
    const user = AppUser(
      uid: 'uid_test',
      email: 'test@zaramella.com',
      displayName: 'Test User',
      tenantId: 'tenant_zaramella',
      departmentId: 'dept_it',
      employeeId: 'emp_it_dev',
    );

    final authBloc = MockAuthBloc();
    final purchaseRepo = MockPurchaseRequestRepository();
    final budgetRepo = MockBudgetRepository();
    final orgRepo = MockOrganizationRepository();
    final workflowRepo = MockWorkflowRepository();

    when(() => authBloc.state).thenReturn(const AuthAuthenticated(user));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => orgRepo.departmentsStream(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => orgRepo.categoriesStream(any()))
        .thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PurchaseRequestRepository>.value(
            value: purchaseRepo,
          ),
          RepositoryProvider<BudgetRepository>.value(
            value: budgetRepo,
          ),
          RepositoryProvider<OrganizationRepository>.value(
            value: orgRepo,
          ),
          RepositoryProvider<WorkflowRepository>.value(
            value: workflowRepo,
          ),
        ],
        child: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            locale: Locale('it'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: RequestFormPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify fields
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.text('Invia'), findsOneWidget);

    // Ensure button is visible in scroll view, then tap
    await tester.ensureVisible(find.text('Invia'));
    await tester.tap(find.text('Invia'));
    await tester.pumpAndSettle();

    expect(find.text('Obbligatorio'), findsWidgets);
  });
}


