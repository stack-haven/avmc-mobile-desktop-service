# Codegen

跨端代码生成器配置。

## 文件

| 文件 | 用途 |
|------|------|
| `buf.gen.yaml` | proto → Dart + TS（同时生成） |
| `buf-gen-dart.yaml` | proto → Dart（仅） |
| `buf-gen-ts.yaml` | proto → TS（仅） |
| `style-dictionary.config.json` | design tokens → 各端代码 |

## 调用方式

通过根目录脚本：

```bash
./tool/gen_clients.sh          # 跨端客户端生成
./tool/sync_design_tokens.sh   # 设计令牌同步
```

## ⚠️ 不要手动运行 buf generate

直接调用 `buf generate` 可能因为路径问题生成到错误位置。
统一通过脚本调用。
