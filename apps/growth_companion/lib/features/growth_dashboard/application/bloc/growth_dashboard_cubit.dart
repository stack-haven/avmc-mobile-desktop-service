import 'package:bloc/bloc.dart';

import '../../domain/entities/growth_dashboard.dart';
import '../../domain/repositories/growth_dashboard_repository.dart';
import '../../domain/usecases/get_growth_dashboard.dart';

part 'growth_dashboard_cubit_state.dart';

/// GrowthDashboard Cubit（bloc 状态管理，兼容 very_good_cli 默认）。
class GrowthDashboardCubit extends Cubit<GrowthDashboardState> {
  GrowthDashboardCubit({required GetGrowthDashboard getGrowthDashboard})
      : _getGrowthDashboard = getGrowthDashboard,
        super(const GrowthDashboardInitial());

  final GetGrowthDashboard _getGrowthDashboard;

  /// 加载 GrowthDashboard。首次进入页面或下拉刷新时调用。
  Future<void> load() async {
    emit(const GrowthDashboardLoading());
    try {
      final item = await _getGrowthDashboard.call('');
      emit(GrowthDashboardLoaded(item));
    } catch (e, st) {
      emit(GrowthDashboardError(e, st));
    }
  }
}
