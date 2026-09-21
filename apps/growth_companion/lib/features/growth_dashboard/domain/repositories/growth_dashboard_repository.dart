import '../entities/growth_dashboard.dart';

/// GrowthDashboard 仓储接口。
///
/// 由 data 层实现，application 层通过 Riverpod 注入。
abstract interface class GrowthDashboardRepository {
  Future<GrowthDashboard> getById(String id);

  Future<List<GrowthDashboard>> list({int pageSize = 20, String? pageToken});

  Future<GrowthDashboard> create({required String name});
}
