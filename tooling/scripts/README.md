# 内部工具脚本

跨 monorepo 使用的工具脚本。

## 文件

- `version_bump.sh` — 批量更新 packages/ 下所有包的版本号
- `changelog.sh` — 从 git log 生成 CHANGELOG.md

调用方式：

```bash
./tooling/scripts/version_bump.sh --bump minor
./tooling/scripts/changelog.sh --since v1.0.0
```
