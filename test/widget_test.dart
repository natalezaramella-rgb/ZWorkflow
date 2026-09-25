import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/app/app.dart';
import 'package:z_workflow/features/auth/domain/models/app_user.dart';
import 'package:z_workflow/features/auth/presentation/bloc/auth_bloc.dart';

import 'helpers/mock_repositories.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockOrganizationRepository mockOrganizationRepository;
  late MockPurchaseRequestRepository mockPurchaseRequestRepository;
  late MockWorkflowRepository mockWorkflowRepository;
  late MockBudgetRepository mockBudgetRepository;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockOrganizationRepository = MockOrganizationRepository();
    mockPurchaseRequestRepository = MockPurchaseRequestRepository();
    mockWorkflowRepository = MockWorkflowRepository();
    mockBudgetRepository = MockBudgetRepository();
    mockAuthBloc = MockAuthBloc();

    when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(const AuthUnauthenticated()));
    when(() => mockAuthRepository.currentUser)
        .thenAnswer((_) async => AppUser.empty);
  });

  testWidgets('ZWorkflowApp loads and displays login screen when unauthenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ZWorkflowApp(
        authRepository: mockAuthRepository,
        organizationRepository: mockOrganizationRepository,
        purchaseRequestRepository: mockPurchaseRequestRepository,
        workflowRepository: mockWorkflowRepository,
        budgetRepository: mockBudgetRepository,
        authBloc: mockAuthBloc,
        locale: const Locale('it'),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the login page is rendered
    expect(find.text('Accedi con email'), findsOneWidget);
  });
}
