import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/budget_repository.dart';
import '../../domain/models/budget.dart';

// ── Events ─────────────────────────────────────────────────────────

sealed class BudgetEvent extends Equatable {
  const BudgetEvent();
  @override
  List<Object?> get props => [];
}

class BudgetLoadAll extends BudgetEvent {
  const BudgetLoadAll({required this.tenantId, required this.year});
  final String tenantId;
  final int year;
  @override
  List<Object?> get props => [tenantId, year];
}

// ── States ─────────────────────────────────────────────────────────

sealed class BudgetState extends Equatable {
  const BudgetState();
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetLoaded extends BudgetState {
  const BudgetLoaded(this.statuses);
  final List<BudgetStatus> statuses;
  @override
  List<Object?> get props => [statuses];
}

class BudgetError extends BudgetState {
  const BudgetError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc({required this.repository})
      : super(const BudgetInitial()) {
    on<BudgetLoadAll>(_onLoadAll);
  }

  final BudgetRepository repository;

  Future<void> _onLoadAll(
      BudgetLoadAll event, Emitter<BudgetState> emit) async {
    emit(const BudgetLoading());
    try {
      final statuses = await repository.getAllBudgetStatuses(
          event.tenantId, event.year);
      emit(BudgetLoaded(statuses));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
