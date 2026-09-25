import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/budget/domain/models/budget.dart';
import 'package:z_workflow/features/budget/presentation/bloc/budget_bloc.dart';

import '../../helpers/mock_repositories.dart';

void main() {
  late MockBudgetRepository mockBudgetRepository;

  const sampleStatuses = [
    BudgetStatus(
      departmentId: 'dept-1',
      departmentName: 'Operations',
      year: 2026,
      allocatedCapex: 20000,
      allocatedOpex: 10000,
      consumedCapex: 5000,
      consumedOpex: 2000,
    ),
  ];

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
  });

  group('BudgetBloc', () {
    test('initial state is BudgetInitial', () {
      final bloc = BudgetBloc(repository: mockBudgetRepository);
      expect(bloc.state, equals(const BudgetInitial()));
    });

    blocTest<BudgetBloc, BudgetState>(
      'emits [BudgetLoading, BudgetLoaded] on successful fetch',
      setUp: () {
        when(() => mockBudgetRepository.getAllBudgetStatuses('tenant-1', 2026))
            .thenAnswer((_) async => sampleStatuses);
      },
      build: () => BudgetBloc(repository: mockBudgetRepository),
      act: (bloc) => bloc.add(const BudgetLoadAll(
        tenantId: 'tenant-1',
        year: 2026,
      )),
      expect: () => [
        const BudgetLoading(),
        const BudgetLoaded(sampleStatuses),
      ],
    );

    blocTest<BudgetBloc, BudgetState>(
      'emits [BudgetLoading, BudgetError] on failure',
      setUp: () {
        when(() => mockBudgetRepository.getAllBudgetStatuses('tenant-1', 2026))
            .thenThrow(Exception('Firestore network error'));
      },
      build: () => BudgetBloc(repository: mockBudgetRepository),
      act: (bloc) => bloc.add(const BudgetLoadAll(
        tenantId: 'tenant-1',
        year: 2026,
      )),
      expect: () => [
        const BudgetLoading(),
        isA<BudgetError>(),
      ],
    );
  });
}
