# Mobile Desktop Service 架构

## 顶层结构

```
mobile-desktop-service/
├── apps/         # 可独立发布的端应用
├── packages/     # 跨应用共享代码
├── tooling/      # 工具脚本和配置
└── tool/         # monorepo 级脚本
```

## 数据流

```
backend-service/proto (SSOT)
    ↓ buf generate
packages/api-client/  (Dart + TS)
    ↓ workspace 引用
apps/{product}-{platform}/
```

## 依赖方向

- `apps/*` → `packages/*`
- `apps/*` → `apps/*` ❌（禁止）
- `packages/*` → `packages/*` ⚠️（谨慎使用，避免循环）

## CI 协调

变更驱动：
- Flutter 变更 → Flutter CI
- RN 变更 → RN CI
- uni-app 变更 → uni-app CI
- proto 变更 → buf breaking check
- tokens 变更 → design-tokens 同步
