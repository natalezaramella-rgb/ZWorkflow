import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/auth/data/auth_repository.dart';
import 'package:z_workflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:z_workflow/features/budget/data/budget_repository.dart';
import 'package:z_workflow/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:z_workflow/features/organization/data/organization_repository.dart';
import 'package:z_workflow/features/purchase_request/data/purchase_request_repository.dart';
import 'package:z_workflow/features/purchase_request/presentation/bloc/request_list_bloc.dart';
import 'package:z_workflow/features/workflow/data/workflow_repository.dart';
import 'package:z_workflow/features/workflow/presentation/bloc/inbox_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOrganizationRepository extends Mock
    implements OrganizationRepository {}

class MockPurchaseRequestRepository extends Mock
    implements PurchaseRequestRepository {}

class MockWorkflowRepository extends Mock implements WorkflowRepository {}

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockRequestListBloc
    extends MockBloc<RequestListEvent, RequestListState>
    implements RequestListBloc {}

class MockInboxBloc extends MockBloc<InboxEvent, InboxState>
    implements InboxBloc {}

class MockBudgetBloc extends MockBloc<BudgetEvent, BudgetState>
    implements BudgetBloc {}
