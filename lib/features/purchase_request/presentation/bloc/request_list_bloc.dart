import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/purchase_request_repository.dart';
import '../../domain/models/purchase_request.dart';

// ── Events ─────────────────────────────────────────────────────────

sealed class RequestListEvent extends Equatable {
  const RequestListEvent();
  @override
  List<Object?> get props => [];
}

class RequestListLoadAll extends RequestListEvent {
  const RequestListLoadAll(this.tenantId);
  final String tenantId;
  @override
  List<Object?> get props => [tenantId];
}

class RequestListLoadMine extends RequestListEvent {
  const RequestListLoadMine(this.tenantId, this.requesterId);
  final String tenantId;
  final String requesterId;
  @override
  List<Object?> get props => [tenantId, requesterId];
}

class _RequestListUpdated extends RequestListEvent {
  const _RequestListUpdated(this.requests);
  final List<PurchaseRequest> requests;
  @override
  List<Object?> get props => [requests];
}

// ── States ─────────────────────────────────────────────────────────

sealed class RequestListState extends Equatable {
  const RequestListState();
  @override
  List<Object?> get props => [];
}

class RequestListInitial extends RequestListState {
  const RequestListInitial();
}

class RequestListLoading extends RequestListState {
  const RequestListLoading();
}

class RequestListLoaded extends RequestListState {
  const RequestListLoaded(this.requests);
  final List<PurchaseRequest> requests;
  @override
  List<Object?> get props => [requests];
}

class RequestListError extends RequestListState {
  const RequestListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────

class RequestListBloc extends Bloc<RequestListEvent, RequestListState> {
  RequestListBloc({required this.repository})
      : super(const RequestListInitial()) {
    on<RequestListLoadAll>(_onLoadAll);
    on<RequestListLoadMine>(_onLoadMine);
    on<_RequestListUpdated>(_onUpdated);
  }

  final PurchaseRequestRepository repository;
  StreamSubscription<List<PurchaseRequest>>? _subscription;

  void _onLoadAll(RequestListLoadAll event, Emitter<RequestListState> emit) {
    emit(const RequestListLoading());
    _subscription?.cancel();
    _subscription = repository.requestsStream(event.tenantId).listen(
          (requests) => add(_RequestListUpdated(requests)),
          onError: (Object error) =>
              add(_RequestListUpdated(const [])),
        );
  }

  void _onLoadMine(
      RequestListLoadMine event, Emitter<RequestListState> emit) {
    emit(const RequestListLoading());
    _subscription?.cancel();
    _subscription = repository
        .myRequestsStream(event.tenantId, event.requesterId)
        .listen(
          (requests) => add(_RequestListUpdated(requests)),
          onError: (Object error) =>
              add(_RequestListUpdated(const [])),
        );
  }

  void _onUpdated(
      _RequestListUpdated event, Emitter<RequestListState> emit) {
    emit(RequestListLoaded(event.requests));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
