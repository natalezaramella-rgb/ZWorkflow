import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:z_workflow/features/purchase_request/domain/enums/request_enums.dart';
import 'package:z_workflow/features/purchase_request/domain/models/purchase_request.dart';
import 'package:z_workflow/features/purchase_request/presentation/bloc/request_list_bloc.dart';

import '../../helpers/mock_repositories.dart';

void main() {
  late MockPurchaseRequestRepository mockRepository;

  const sampleRequests = [
    PurchaseRequest(
      id: 'req-1',
      requesterId: 'emp-1',
      requesterName: 'Mario',
      departmentId: 'dept-1',
      description: 'Laptops',
      estimatedAmount: 2500,
      type: RequestType.capex,
      status: RequestStatus.pendingApproval,
    ),
  ];

  setUp(() {
    mockRepository = MockPurchaseRequestRepository();
  });

  group('RequestListBloc', () {
    test('initial state is RequestListInitial', () {
      final bloc = RequestListBloc(repository: mockRepository);
      expect(bloc.state, equals(const RequestListInitial()));
    });

    blocTest<RequestListBloc, RequestListState>(
      'emits [RequestListLoading, RequestListLoaded] when requests stream emits',
      setUp: () {
        when(() => mockRepository.requestsStream('tenant-1'))
            .thenAnswer((_) => Stream.value(sampleRequests));
      },
      build: () => RequestListBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const RequestListLoadAll('tenant-1')),
      expect: () => [
        const RequestListLoading(),
        const RequestListLoaded(sampleRequests),
      ],
    );

    blocTest<RequestListBloc, RequestListState>(
      'emits [RequestListLoading, RequestListLoaded] for myRequestsStream',
      setUp: () {
        when(() => mockRepository.myRequestsStream('tenant-1', 'emp-1'))
            .thenAnswer((_) => Stream.value(sampleRequests));
      },
      build: () => RequestListBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const RequestListLoadMine(
        'tenant-1',
        'emp-1',
      )),
      expect: () => [
        const RequestListLoading(),
        const RequestListLoaded(sampleRequests),
      ],
    );
  });
}
