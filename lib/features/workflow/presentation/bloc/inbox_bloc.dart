import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../purchase_request/data/purchase_request_repository.dart';
import '../../../purchase_request/domain/models/purchase_request.dart';

// ── Events ─────────────────────────────────────────────────────────

sealed class InboxEvent extends Equatable {
  const InboxEvent();
  @override
  List<Object?> get props => [];
}

class InboxLoadPending extends InboxEvent {
  const InboxLoadPending({
    required this.tenantId,
    required this.approverEmployeeId,
  });
  final String tenantId;
  final String approverEmployeeId;
  @override
  List<Object?> get props => [tenantId, approverEmployeeId];
}

class _InboxUpdated extends InboxEvent {
  const _InboxUpdated(this.requests);
  final List<PurchaseRequest> requests;
  @override
  List<Object?> get props => [requests];
}

// ── States ─────────────────────────────────────────────────────────

sealed class InboxState extends Equatable {
  const InboxState();
  @override
  List<Object?> get props => [];
}

class InboxInitial extends InboxState {
  const InboxInitial();
}

class InboxLoading extends InboxState {
  const InboxLoading();
}

class InboxLoaded extends InboxState {
  const InboxLoaded(this.pendingRequests);
  final List<PurchaseRequest> pendingRequests;
  @override
  List<Object?> get props => [pendingRequests];
}

class InboxError extends InboxState {
  const InboxError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  InboxBloc({required this.requestRepository})
      : super(const InboxInitial()) {
    on<InboxLoadPending>(_onLoadPending);
    on<_InboxUpdated>(_onUpdated);
  }

  final PurchaseRequestRepository requestRepository;
  StreamSubscription<List<PurchaseRequest>>? _subscription;

  void _onLoadPending(InboxLoadPending event, Emitter<InboxState> emit) {
    emit(const InboxLoading());
    _subscription?.cancel();
    _subscription = requestRepository
        .pendingApprovalsStream(event.tenantId, event.approverEmployeeId)
        .listen(
          (requests) => add(_InboxUpdated(requests)),
          onError: (Object error) => add(const _InboxUpdated([])),
        );
  }

  void _onUpdated(_InboxUpdated event, Emitter<InboxState> emit) {
    emit(InboxLoaded(event.requests));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
