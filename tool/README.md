# Monorepo 级脚本

由 `avmc-mobile-desktop-monorepo` skill 维护。复制到 `mobile-desktop-service/tool/` 目录使用。

## 脚本列表

| 脚本 | 用途 |
|------|------|
| `init_monorepo.sh` | 初始化 monorepo 骨架 |
| `gen_clients.sh` | proto → 多端客户端生成 |
| `sync_design_tokens.sh` | design tokens → 各端代码 |
| `run_all_checks.sh` | 跨端 lint/test 调度 |
| `upgrade_dependencies.sh` | 跨端依赖升级 |

## 调用顺序

```bash
# 首次创建仓库后
./tool/init_monorepo.sh

# backend-service proto 变更后
./tool/gen_clients.sh

# 设计令牌变更后
./tool/sync_design_tokens.sh

# pre-commit / CI
./tool/run_all_checks.sh

# 季度依赖维护
./tool/upgrade_dependencies.sh
```
