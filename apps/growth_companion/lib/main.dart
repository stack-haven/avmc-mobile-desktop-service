// 默认入口（dev flavor）
//
// very_good_cli 用 flavor-based 启动模式，但 Flutter 默认需要 lib/main.dart。
// 此文件作为默认入口桥接到 main_development.dart。
//
// 其他 flavor:
//   flutter run --flavor development -t lib/main_development.dart
//   flutter run --flavor staging      -t lib/main_staging.dart
//   flutter run --flavor production   -t lib/main_production.dart
//
// 或直接修改 main_development.dart 的 import 切换 flavor。

export 'main_development.dart';
