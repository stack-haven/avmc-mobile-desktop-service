# @avmc/design-tokens

跨端设计令牌。`tokens.json` 是单一事实来源（SSOT），由 `./tool/sync_design_tokens.sh` 自动生成各端代码。

## 目录结构

```
design-tokens/
├── tokens.json                # ⚠️ SSOT（手动编辑此文件）
├── lib/theme.dart             # Flutter 使用（自动生成）
├── src/theme.ts               # React Native 使用（自动生成）
├── src/theme.scss             # uni-app 使用（自动生成）
└── README.md
```

## 修改令牌

1. 编辑 `tokens.json`
2. 跑 `./tool/sync_design_tokens.sh`
3. 各端 apps 自动看到变更（通过 workspace: protocol）
4. CI 验证生成代码无 lint 错误
