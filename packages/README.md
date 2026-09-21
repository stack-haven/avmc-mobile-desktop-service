# Packages

跨应用共享代码。每个子目录是一个 workspace 包。

## 当前包

| 包名 | 类型 | 说明 |
|------|------|------|
| `api-client` | API 客户端 | 跨端共享，由 proto 自动生成 |
| `design-tokens` | 设计令牌 | 跨端设计令牌 SSOT + 各端代码生成 |

## 命名规范

- 单技术栈包：`<name>-flutter` / `<name>-react` / `<name>-uniapp`
- 跨技术栈包：直接 `<name>`（如 `api-client`）
- 业务核心：`<product>-core`（如 `evie-core`、`geo-core`）

## 新增包

1. 创建目录：`mkdir -p packages/<name>`
2. 添加元数据：`pubspec.yaml`（Dart）或 `package.json`（TS）
3. 跑 `./tool/run_all_checks.sh` 验证
4. 在 apps/* 中通过 `path:` 或 `workspace:*` 引用
