/// GrowthDashboard 领域实体。
///
/// 业务核心模型，不依赖任何外部（无 JSON 序列化、无 RPC 类型引用）。
/// 使用 const + final 不可变，不依赖 Equatable/freezed。
class GrowthDashboard {
  const GrowthDashboard({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;
}
