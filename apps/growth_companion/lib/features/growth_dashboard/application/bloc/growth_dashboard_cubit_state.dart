part of 'growth_dashboard_cubit.dart';

/// GrowthDashboard 状态（sealed class，bloc 风格，不依赖 Equatable/freezed）。
sealed class GrowthDashboardState {
  const GrowthDashboardState();
}

final class GrowthDashboardInitial extends GrowthDashboardState {
  const GrowthDashboardInitial();
}

final class GrowthDashboardLoading extends GrowthDashboardState {
  const GrowthDashboardLoading();
}

final class GrowthDashboardLoaded extends GrowthDashboardState {
  const GrowthDashboardLoaded(this.item);
  final GrowthDashboard item;
}

final class GrowthDashboardError extends GrowthDashboardState {
  const GrowthDashboardError(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;
}
