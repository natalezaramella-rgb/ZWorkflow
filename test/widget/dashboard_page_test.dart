import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/auth/domain/models/app_user.dart';
import 'package:z_workflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:z_workflow/features/budget/domain/models/budget.dart';
import 'package:z_workflow/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:z_workflow/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:z_workflow/features/purchase_request/domain/enums/request_enums.dart';
import 'package:z_workflow/features/purchase_request/domain/models/purchase_request.dart';
import 'package:z_workflow/features/purchase_request/presentation/bloc/request_list_bloc.dart';
import 'package:z_workflow/features/purchase_request/presentation/pages/request_detail_page.dart';
import 'package:z_workflow/features/workflow/presentation/bloc/inbox_bloc.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../helpers/mock_repositories.dart';

void main() {
  testWidgets('DashboardPage renders welcome header and summary cards',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DashboardPage(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify presence of dashboard title and key cards with exact Italian strings
    expect(find.text('Bentornato!'), findsOneWidget);
    expect(find.text('Da approvare'), findsOneWidget);
    expect(find.text('Le mie richieste'), findsOneWidget);
    expect(find.text('Budget CAPEX totale'), findsOneWidget);
    expect(find.text('Budget OPEX totale'), findsOneWidget);
  });

  group('DashboardPage dynamic live counters and recent requests', () {
    late MockAuthBloc mockAuthBloc;
    late MockInboxBloc mockInboxBloc;
    late MockRequestListBloc mockRequestListBloc;
    late MockBudgetBloc mockBudgetBloc;

    const testUser = AppUser(
      uid: 'uid_test',
      email: 'mario.rossi@zaramella.com',
      displayName: 'Mario Rossi',
      tenantId: 'tenant_zaramella',
      employeeId: 'emp_mario',
      departmentId: 'dept_it',
      roles: [UserRole.approver, UserRole.requester],
    );

    final sampleRequests = [
      PurchaseRequest(
        id: 'req_1',
        requesterId: 'emp_mario',
        requesterName: 'Mario Rossi',
        departmentId: 'dept_it',
        description: 'Licenze IDE JetBrains',
        estimatedAmount: 3200,
        type: RequestType.opex,
        status: RequestStatus.approved,
        requestDate: DateTime(2026, 9, 20),
      ),
      PurchaseRequest(
        id: 'req_2',
        requesterId: 'emp_other',
        requesterName: 'Luigi Bianchi',
        departmentId: 'dept_it',
        description: 'Server Rack Dell',
        estimatedAmount: 15000,
        type: RequestType.capex,
        status: RequestStatus.pendingApproval,
        requestDate: DateTime(2026, 9, 22),
      ),
    ];

    const sampleBudgets = [
      BudgetStatus(
        departmentId: 'dept_it',
        departmentName: 'IT & Sistemi',
        year: 2026,
        allocatedCapex: 50000,
        allocatedOpex: 20000,
        consumedCapex: 10000,
        consumedOpex: 5000,
      ),
    ];

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockInboxBloc = MockInboxBloc();
      mockRequestListBloc = MockRequestListBloc();
      mockBudgetBloc = MockBudgetBloc();

      when(() => mockAuthBloc.state)
          .thenReturn(const AuthAuthenticated(testUser));
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const AuthAuthenticated(testUser)));

      when(() => mockInboxBloc.state)
          .thenReturn(InboxLoaded([sampleRequests[1]]));
      when(() => mockInboxBloc.stream).thenAnswer(
          (_) => Stream.value(InboxLoaded([sampleRequests[1]])));

      when(() => mockRequestListBloc.state)
          .thenReturn(RequestListLoaded(sampleRequests));
      when(() => mockRequestListBloc.stream).thenAnswer(
          (_) => Stream.value(RequestListLoaded(sampleRequests)));

      when(() => mockBudgetBloc.state)
          .thenReturn(const BudgetLoaded(sampleBudgets));
      when(() => mockBudgetBloc.stream).thenAnswer(
          (_) => Stream.value(const BudgetLoaded(sampleBudgets)));
    });

    testWidgets('renders user name, live counters and recent requests',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DashboardPage(
            authBloc: mockAuthBloc,
            inboxBloc: mockInboxBloc,
            requestListBloc: mockRequestListBloc,
            budgetBloc: mockBudgetBloc,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // User greeting
      expect(find.text('Mario Rossi'), findsWidgets);

      // Pending approvals banner
      expect(find.text('1 richiesta da approvare'), findsOneWidget);

      // 4 cards live counts:
      // Da approvare: 1
      expect(find.text('1'), findsOneWidget);
      // Le mie richieste: 1 (only req_1 belongs to emp_mario)
      // Capex: 50k
      expect(find.text('€ 50k'), findsOneWidget);
      // Opex: 20k
      expect(find.text('€ 20k'), findsOneWidget);

      // Recent requests listed
      expect(find.text('Licenze IDE JetBrains'), findsOneWidget);
      expect(find.text('Server Rack Dell'), findsOneWidget);
      expect(find.text('€ 3200.00'), findsOneWidget);
      expect(find.text('€ 15000.00'), findsOneWidget);

      // Tap on recent request opens RequestDetailPage
      await tester.tap(find.text('Licenze IDE JetBrains'));
      await tester.pumpAndSettle();

      expect(find.byType(RequestDetailPage), findsOneWidget);
    });
  });
}
