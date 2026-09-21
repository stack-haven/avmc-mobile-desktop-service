import '../../domain/entities/growth_dashboard.dart';

/// GrowthDashboard 数据传输对象（DTO）。
/// data 层专用：包含 JSON 序列化、与 proto/RPC 类型转换。
/// 不暴露到 application / presentation 层。
///
/// 不使用 freezed / json_serializable / equatable 以兼容 very_good_cli 默认依赖；
/// 如已添加 freezed 依赖，可改回 freezed 风格。
class GrowthDashboardModel {
  const GrowthDashboardModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  factory GrowthDashboardModel.fromJson(Map<String, dynamic> json) =>
      GrowthDashboardModel(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  /// DTO → Domain Entity。
  GrowthDashboard toEntity() => GrowthDashboard(
        id: id,
        name: name,
        createdAt: createdAt,
      );
}

/// Domain Entity → DTO。
GrowthDashboardModel growth_dashboardModelFromEntity(GrowthDashboard entity) =>
    GrowthDashboardModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
    );
