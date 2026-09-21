// 如启用 auto_route 路由，取消下一行 import 和类上的 @RoutePage() 注解。
// import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../growth_dashboard.dart';
import '../../domain/usecases/get_growth_dashboard.dart';

/// GrowthDashboard 页面（bloc 风格）。
///
/// 使用前提：在 main.dart 的 MultiRepositoryProvider 中注册 GrowthDashboardRepository。
// @RoutePage()
class GrowthDashboardPage extends StatelessWidget {
  const GrowthDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GrowthDashboardCubit(
        getGrowthDashboard: GetGrowthDashboard(context.read<GrowthDashboardRepository>()),
      )..load(),
      child: const GrowthDashboardView(),
    );
  }
}

/// GrowthDashboard View（纯 UI，订阅 cubit 状态）。
class GrowthDashboardView extends StatelessWidget {
  const GrowthDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GrowthDashboard')),
      body: BlocBuilder<GrowthDashboardCubit, GrowthDashboardState>(
        builder: (context, state) => switch (state) {
          GrowthDashboardInitial() => const Center(
              child: ElevatedButton(
                onPressed: null,
                child: Text('Tap to load'),
              ),
            ),
          GrowthDashboardLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          GrowthDashboardLoaded(:final item) => ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.label),
                  title: Text(item.name),
                  subtitle: Text(item.id),
                ),
              ],
            ),
          GrowthDashboardError(:final error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $error', textAlign: TextAlign.center),
              ),
            ),
        },
      ),
    );
  }
}
