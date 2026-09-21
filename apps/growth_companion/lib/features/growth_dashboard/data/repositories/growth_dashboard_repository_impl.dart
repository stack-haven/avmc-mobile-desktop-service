import '../../domain/entities/growth_dashboard.dart';
import '../../domain/repositories/growth_dashboard_repository.dart';
import '../datasources/growth_dashboard_local_datasource.dart';
import '../datasources/growth_dashboard_remote_datasource.dart';

/// GrowthDashboard 仓储默认实现：远程优先，本地缓存。
class GrowthDashboardRepositoryImpl implements GrowthDashboardRepository {
  const GrowthDashboardRepositoryImpl({
    required GrowthDashboardRemoteDataSource remote,
    required GrowthDashboardLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final GrowthDashboardRemoteDataSource _remote;
  final GrowthDashboardLocalDataSource _local;

  @override
  Future<GrowthDashboard> getById(String id) async {
    final model = await _remote.getById(id);
    return model.toEntity();
  }

  @override
  Future<List<GrowthDashboard>> list({int pageSize = 20, String? pageToken}) async {
    try {
      final models = await _remote.list(
        pageSize: pageSize,
        pageToken: pageToken,
      );
      // 异步缓存，不阻塞返回
      unawaited(_local.cacheList(models));
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      // 降级到本地缓存
      final cached = await _local.getCachedList();
      return cached.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<GrowthDashboard> create({required String name}) async {
    final model = await _remote.create(name: name);
    return model.toEntity();
  }
}

/// 抑制 unawaited 警告的 import（Dart 3.0+ 需要）
void unawaited(Future<void> future) {}
