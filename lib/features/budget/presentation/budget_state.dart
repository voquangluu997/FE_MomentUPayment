// features/budget/presentation/budget_state.dart

enum BudgetStatus { initial, loading, success, error }

class BudgetState {
  final BudgetStatus status;
  final String? errorMessage;
  final double? updatedLimit;

  BudgetState({required this.status, this.errorMessage, this.updatedLimit});

  factory BudgetState.initial() => BudgetState(status: BudgetStatus.initial);
  factory BudgetState.loading() => BudgetState(status: BudgetStatus.loading);
  factory BudgetState.success(double limit) =>
      BudgetState(status: BudgetStatus.success, updatedLimit: limit);
  factory BudgetState.error(String message) =>
      BudgetState(status: BudgetStatus.error, errorMessage: message);
}
