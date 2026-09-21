# Mobile Desktop Service

Ark Tech Platform 多端应用承载层（桌面端 + 移动端 + 小程序端）。

**不实现业务逻辑**，只承载各 Ark Product Service（Evie / GEO / Workbench）的端产物。

## 架构

```
backend-service/proto/    → 契约源
        ↓ buf generate
packages/api-client/      → Dart + TS 客户端
        ↓ workspace 引用
apps/{product}-{platform}/  → 端应用
```

详细规范见 `docs/services/mobile-desktop/SERVICE.md`。

## 当前应用

| 产品 | 端 | 路径 | 技术栈 |
|------|----|-----|--------|
| — | — | — | — |

（待 init_monorepo.sh 完成后填充）

## 开发

```bash
# 初始化（首次）
./tool/init_monorepo.sh

# proto 变更后生成客户端
./tool/gen_clients.sh

# 设计令牌变更后同步
./tool/sync_design_tokens.sh

# pre-commit
./tool/run_all_checks.sh

# 升级依赖
./tool/upgrade_dependencies.sh
```

## 相关文档

- 服务资料：`docs/services/mobile-desktop/README.md`（在根仓库）
- 技术规范：`docs/services/mobile-desktop/SERVICE.md`（在根仓库）
- Skill：`avmc-mobile-desktop-monorepo`（根仓库 `.agents/skills/`）
