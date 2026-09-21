import '../models/growth_dashboard_model.dart';

/// GrowthDashboard 本地数据源接口。
///
/// 具体实现：Drift / Hive / SharedPreferences / secure_storage。
abstract interface class GrowthDashboardLocalDataSource {
  Future<List<GrowthDashboardModel>> getCachedList();

  Future<void> cacheList(List<GrowthDashboardModel> models);
}
