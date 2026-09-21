# Contributing to Mobile Desktop Service

## 提交规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/)：

```
feat(apps/evie-mobile): 新增词库中心移动端
fix(apps/evie-desktop): 修复 macOS 启动崩溃
chore(monorepo): 升级 melos 到 6.0.0
docs(skill): 补充 RN 实战经验到 skill
```

## 分支策略

- `main` — 受保护，仅通过 PR 合并
- `feat/<feature>` — 功能开发
- `fix/<bug>` — 缺陷修复
- `release/<version>` — 发布准备

## PR 检查清单

- [ ] `./tool/run_all_checks.sh` 全绿
- [ ] 涉及 proto 变更时 `./tool/gen_clients.sh` 已重新生成客户端
- [ ] 涉及设计令牌变更时 `./tool/sync_design_tokens.sh` 已同步
- [ ] CHANGELOG.md 已更新（重大变更）
- [ ] 至少一个 reviewer 通过
