# 安装 protoc_plugin（Dart gRPC stub 生成器）

`tool/gen_clients.sh` 依赖 `protoc-gen-dart`（`protoc_plugin` Dart pub 包）。

## 安装

```bash
dart pub global activate protoc_plugin
```

确保 `~/.pub-cache/bin` 在 PATH 中（macOS 默认已有）。

## 验证

```bash
which protoc-gen-dart
# 应输出: /Users/<user>/.pub-cache/bin/protoc-gen-dart
```

## 版本

当前测试使用 protoc_plugin **25.1.0**（集成 message + gRPC stub 生成）。

## 为什么不用 BSR 官方 plugin

- `buf.build/protocolbuffers/dart` — 只生成 message
- `buf.build/grpc/dart` — BSR 上**不存在**
- 替代：`protoc-gen-dart`（本地插件，v25+ 集成 message + gRPC）
