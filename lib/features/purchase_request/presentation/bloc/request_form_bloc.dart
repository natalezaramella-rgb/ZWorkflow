import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/purchase_request_repository.dart';
import '../../domain/enums/request_enums.dart';
import '../../domain/models/purchase_request.dart';

// ── Events ─────────────────────────────────────────────────────────

sealed class RequestFormEvent extends Equatable {
  const RequestFormEvent();
  @override
  List<Object?> get props => [];
}

class RequestFormSubmit extends RequestFormEvent {
  const RequestFormSubmit({
    required this.tenantId,
    required this.request,
  });
  final String tenantId;
  final PurchaseRequest request;
  @override
  List<Object?> get props => [tenantId, request];
}

// ── States ─────────────────────────────────────────────────────────

sealed class RequestFormState extends Equatable {
  const RequestFormState();
  @override
  List<Object?> get props => [];
}

class RequestFormInitial extends RequestFormState {
  const RequestFormInitial();
}

class RequestFormSubmitting extends RequestFormState {
  const RequestFormSubmitting();
}

class RequestFormSuccess extends RequestFormState {
  const RequestFormSuccess(this.requestId);
  final String requestId;
  @override
  List<Object?> get props => [requestId];
}

class RequestFormError extends RequestFormState {
  const RequestFormError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────

class RequestFormBloc extends Bloc<RequestFormEvent, RequestFormState> {
  RequestFormBloc({required this.repository})
      : super(const RequestFormInitial()) {
    on<RequestFormSubmit>(_onSubmit);
  }

  final PurchaseRequestRepository repository;

  Future<void> _onSubmit(
      RequestFormSubmit event, Emitter<RequestFormState> emit) async {
    emit(const RequestFormSubmitting());
    try {
      final requestToSubmit = event.request.copyWith(
        status: RequestStatus.submitted,
        requestDate: DateTime.now(),
      );

      final id = await repository.createRequest(
          event.tenantId, requestToSubmit);
      emit(RequestFormSuccess(id));
    } catch (e) {
      emit(RequestFormError(e.toString()));
    }
  }
}
