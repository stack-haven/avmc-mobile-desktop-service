/// GrowthDashboard feature barrel file.
///
/// 对外只导出 GrowthDashboard 的：
///   - Domain entities（业务实体）
///   - Domain repository interfaces（仓储接口）
///   - Application providers（Riverpod 状态管理入口）
///   - Presentation pages（页面）
///
/// 不导出：
///   - data/* 的具体实现（仅通过 domain 接口暴露）
///   - usecases 的内部细节
library;
export 'domain/entities/growth_dashboard.dart';
export 'domain/repositories/growth_dashboard_repository.dart';
export 'application/bloc/growth_dashboard_cubit.dart';
export 'presentation/pages/growth_dashboard_page.dart';
