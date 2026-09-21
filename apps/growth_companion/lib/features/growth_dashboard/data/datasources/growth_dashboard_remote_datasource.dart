import '../models/growth_dashboard_model.dart';

/// GrowthDashboard 远程数据源接口。
///
/// 具体实现：gRPC client / Dio HTTP client。
abstract interface class GrowthDashboardRemoteDataSource {
  Future<GrowthDashboardModel> getById(String id);

  Future<List<GrowthDashboardModel>> list({int pageSize = 20, String? pageToken});

  Future<GrowthDashboardModel> create({required String name});
}
