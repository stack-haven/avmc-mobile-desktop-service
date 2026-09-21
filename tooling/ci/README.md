# CI 配置

GitHub Actions 模板。被 `.github/workflows/mobile-desktop-ci.yml` 引用。

## 模板文件

| 文件 | 用途 |
|------|------|
| `flutter-ci.yml` | Flutter 应用 CI（lint + test + build） |
| `react-native-ci.yml` | React Native CI |
| `uniapp-ci.yml` | uni-app CI |

## 复用工作流

主工作流 `mobile-desktop-ci.yml` 用 `jobs.<name>.uses:` 引用这些模板：

```yaml
flutter-ci:
  uses: ./.github/workflows/_flutter-ci.yml
```

模板化避免主工作流文件臃肿。
