import '../entities/growth_dashboard.dart';
import '../repositories/growth_dashboard_repository.dart';

/// 获取 GrowthDashboard 用例。
///
/// 单一职责：通过仓储获取单个 GrowthDashboard。
class GetGrowthDashboard {
  const GetGrowthDashboard(this._repository);

  final GrowthDashboardRepository _repository;

  Future<GrowthDashboard> call(String id) => _repository.getById(id);
}
