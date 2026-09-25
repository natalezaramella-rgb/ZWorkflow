import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/auth/domain/models/app_user.dart';
import 'package:z_workflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:z_workflow/features/organization/data/organization_repository.dart';
import 'package:z_workflow/features/purchase_request/domain/enums/request_enums.dart';
import 'package:z_workflow/features/purchase_request/domain/models/purchase_request.dart';
import 'package:z_workflow/features/purchase_request/presentation/pages/request_detail_page.dart';
import 'package:z_workflow/features/workflow/data/workflow_repository.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../helpers/mock_repositories.dart';

void main() {
  final sampleRequest = PurchaseRequest(
    id: 'req_test_01',
    requesterId: 'emp_it_dev',
    requesterName: 'Marco Neri',
    departmentId: 'dept_it',
    description: 'Postazione di lavoro MacBook Pro per sviluppatore',
    estimatedAmount: 2800,
    type: RequestType.opex,
    status: RequestStatus.pendingApproval,
    currentApprovalLevel: 0,
    requiredApprovalLevels: 2,
    currentApproverEmployeeId: 'emp_it_lead',
    currentApproverName: 'Anna Verdi',
  );

  Widget buildTestWidget({
    required AppUser currentUser,
    required MockAuthBloc authBloc,
    required MockWorkflowRepository workflowRepo,
    required MockOrganizationRepository orgRepo,
  }) {
    when(() => authBloc.state).thenReturn(AuthAuthenticated(currentUser));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => workflowRepo.approvalStepsStream(any(), any()))
        .thenAnswer((_) => Stream.value([]));

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WorkflowRepository>.value(value: workflowRepo),
        RepositoryProvider<OrganizationRepository>.value(value: orgRepo),
      ],
      child: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: RequestDetailPage(request: sampleRequest),
        ),
      ),
    );
  }

  testWidgets('RequestDetailPage renders request information and timeline header',
      (tester) async {
    final authBloc = MockAuthBloc();
    final workflowRepo = MockWorkflowRepository();
    final orgRepo = MockOrganizationRepository();

    const regularUser = AppUser(
      uid: 'uid_other',
      email: 'other@zaramella.com',
      displayName: 'Other Employee',
      employeeId: 'emp_other',
    );

    await tester.pumpWidget(
      buildTestWidget(
        currentUser: regularUser,
        authBloc: authBloc,
        workflowRepo: workflowRepo,
        orgRepo: orgRepo,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Postazione di lavoro MacBook Pro per sviluppatore'), findsOneWidget);
    expect(find.text('€ 2800.00'), findsOneWidget);
    expect(find.text('dept_it'), findsOneWidget);
    expect(find.text('Cronologia approvazioni'), findsOneWidget);

    // Regular employee who is NOT the current approver should NOT see the bottom action bar
    expect(find.text('Approva'), findsNothing);
  });

  testWidgets('RequestDetailPage shows approval buttons and confirmation dialog for approver',
      (tester) async {
    final authBloc = MockAuthBloc();
    final workflowRepo = MockWorkflowRepository();
    final orgRepo = MockOrganizationRepository();

    // Current approver: Anna Verdi (emp_it_lead)
    const approverUser = AppUser(
      uid: 'uid_anna_verdi',
      email: 'anna.verdi@zaramella.com',
      displayName: 'Anna Verdi',
      employeeId: 'emp_it_lead',
    );

    await tester.pumpWidget(
      buildTestWidget(
        currentUser: approverUser,
        authBloc: authBloc,
        workflowRepo: workflowRepo,
        orgRepo: orgRepo,
      ),
    );
    await tester.pumpAndSettle();

    // Verify action buttons appear in the bottom bar
    expect(find.text('Approva'), findsOneWidget);
    expect(find.text('Rifiuta'), findsOneWidget);
    expect(find.text('Modifiche'), findsOneWidget);

    // Tap Approva -> Open confirmation dialog
    await tester.tap(find.text('Approva'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Vuoi confermare l\'approvazione per il livello 1 di 2?'), findsOneWidget);

    // Cancel dialog
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);

    // Tap Rifiuta -> Open reject dialog with mandatory reason
    await tester.tap(find.text('Rifiuta'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Inserisci il motivo obbligatorio del rifiuto:'), findsOneWidget);

    // Cancel dialog
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
