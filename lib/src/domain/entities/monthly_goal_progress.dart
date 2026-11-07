import 'monthly_goal.dart';

class MonthlyGoalProgress {
  final MonthlyGoalType type;
  final int completed;
  final int target;

  const MonthlyGoalProgress({
    required this.type,
    required this.completed,
    required this.target,
  });

  int get remaining => (target - completed).clamp(0, target);
  bool get isComplete => completed >= target;
  double get fraction => target <= 0 ? 1 : (completed / target).clamp(0.0, 1.0);
  int get percentage => (fraction * 100).floor().clamp(0, 100);
}

class MonthlyProgress {
  final DateTime month;
  final List<MonthlyGoalProgress> goals;

  const MonthlyProgress({required this.month, required this.goals});

  bool get hasGoals => goals.isNotEmpty;
  bool get isComplete => hasGoals && goals.every((goal) => goal.isComplete);
}
