class BudgetSummary {
  final double budgetLimit;
  final double totalSpent;

  BudgetSummary({required this.budgetLimit, required this.totalSpent});

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      // Ép kiểu an toàn về double đề phòng NestJS trả về int hoặc float
      budgetLimit: (json['budgetLimit'] as num).toDouble(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
    );
  }
}
