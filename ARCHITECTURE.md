# mobile-desktop-service 仓库架构

> 本文档描述 `mobile-desktop-service` 仓库的架构设计与组织方式。规则与治理约束见 [`AGENTS.md`](./AGENTS.md)；架构决策的历史与原因见 [`docs/adr/`](./docs/adr/)（如果存在）或根仓库 [`docs/architecture/`](../../docs/architecture/)。

## 一、定位

`mobile-desktop-service` 是 Ark Tech Platform（`avmc`）的**多端应用承载层**，负责承载各 Ark Product Service 的端产物（移动 App / 桌面 App / 小程序）。

**不是**：产品服务本身（不实现业务逻辑）。
**是**：跨产品共享的客户端工程平台。

## 二、目录结构

```text
mobile-desktop-service/
│
├── apps/                          # 独立可执行的产品应用
│   ├── growth_companion/          # Flutter 应用（very_good_cli 脚手架 + bloc）
│   ├── evie-mobile/               # （规划中）Flutter 移动端
│   ├── evie-desktop/              # （规划中）Flutter 桌面端
│   ├── workbench-mobile/          # （规划中）React Native
│   └── geo-mini/                  # （规划中）uni-app 小程序
│
├── packages/                      # 跨应用共享能力（语义化命名，禁止 common/）
│   ├── design-tokens/             # 设计令牌 SSOT（tokens.json）
│   ├── api-client/                # API 客户端（proto→Dart + proto→TS）
│   ├── design_system/             # （规划中）跨端 UI 组件
│   ├── networking/                # （规划中）网络层封装
│   └── storage/                   # （规划中）本地存储
│
├── tooling/                       # 仓库级工具与配置
│   ├── ci/                        # CI 模板与配置
│   ├── codegen/                   # 代码生成（buf / style-dictionary）
│   └── scripts/                   # 仓库级脚本
│
├── tool/                          # 应用级脚本模板（每个 app 内部 tool/ 复制此目录）
│   ├── init_monorepo.sh           # monorepo 初始化
│   ├── gen_clients.sh             # API 客户端生成
│   ├── sync_design_tokens.sh      # 设计令牌同步
│   ├── run_all_checks.sh          # 全量检查
│   └── upgrade_dependencies.sh    # 依赖升级
│
├── melos.yaml                     # Flutter 编排（仅对 Flutter 项目生效）
├── package.json                   # RN/uni-app workspaces
├── pnpm-workspace.yaml            # pnpm workspace 配置
├── tokens.json                    # 设计令牌 SSOT
├── AGENTS.md                      # 仓库级工程宪法
├── ARCHITECTURE.md                # 本文件
├── README.md                      # 仓库入口
├── CONTRIBUTING.md                # 贡献指南
├── LICENSE                        # 许可证
│
└── docs/                          # 仓库级文档
    └── adr/                       # 架构决策记录（如果创建）
```

## 三、技术栈矩阵

| 栈 | 应用 | 状态管理 | 导航 | 工具链 | 触发器 |
|------|------|---------|------|--------|-------|
| **Flutter** | `growth_companion` (✅), `evie-mobile` (规划), `evie-desktop` (规划) | bloc（默认）/ riverpod | go_router | Melos + very_good_analysis | `apps/*/lib/**` 变更 |
| **React Native** | `workbench-mobile` (规划) | zustand | react-navigation | pnpm workspaces | `apps/*/src/**` 变更 |
| **uni-app** | `geo-mini` (规划) | Pinia | uni.navigateTo | HBuilderX + CLI | `apps/*/pages/**` 变更 |

**原则**：三栈工具链不强求统一；只在**公共契约**（proto 生成、设计令牌、CI 入口）上保持一致。

## 四、跨端共享机制

### 4.1 设计令牌

```text
tokens.json (SSOT)
    ↓
tooling/codegen/style-dictionary.config.json
    ↓
├─→ packages/design-tokens/lib/theme.dart  (Flutter)
├─→ packages/design-tokens/src/theme.ts     (RN)
└─→ packages/design-tokens/src/theme.scss  (uni-app)
```

通过 `bash tool/sync_design_tokens.sh` 一次同步到三端。

### 4.2 API 客户端

```text
backend-service/proto/ (SSOT)
    ↓
tooling/codegen/buf.gen.yaml
    ↓
├─→ packages/api-client/lib/  (Dart, Flutter 用)
└─→ packages/api-client/src/  (TypeScript, RN/uni-app 用)
```

通过 `bash tool/gen_clients.sh` 一次生成两端。**生成产物不进入版本控制**（见 `.gitignore`）。

### 4.3 包升级

```bash
# 升级所有 Flutter 应用的共享依赖
bash tool/upgrade_dependencies.sh flutter

# 升级所有 RN 应用的共享依赖
bash tool/upgrade_dependencies.sh rn
```

## 五、CI 流水线

CI 由 `tooling/ci/` 与根仓库的 GitHub Actions 协同：

| Job | 触发条件 | 范围 |
|------|---------|------|
| `dorny/paths-filter` | PR 打开 | 检测改动文件所属栈（Flutter / RN / uni-app） |
| `flutter-ci` | `apps/*/lib/**` 改动 | 跑 `flutter analyze` + `flutter test` + `check_architecture.sh` |
| `rn-ci` | `apps/*/src/**` 改动 | 跑 `pnpm typecheck` + `pnpm test` |
| `uniapp-ci` | `apps/*/pages/**` 改动 | 跑 HBuilderX CLI 编译 |
| `submodule-pointer` | 任一文件改动 | 验证子仓库指针与根仓库一致 |

## 六、依赖方向

```text
应用 (apps/*)
    ↓
共享包 (packages/*)
    ↓
外部依赖 (pubspec / package.json)
```

**禁止**：`packages/*` → `apps/*`（包绝不能依赖应用）。
**禁止**：循环依赖。

## 七、演进路径

| 阶段 | 状态 | 关键动作 |
|------|:---:|---------|
| v0.1 monorepo 初始化 | ✅ | apps/packages/tooling 三层骨架 + 4 个 skill |
| v0.2 首批应用落地 | ✅ | growth_companion（Flutter） |
| v0.3 跨端设计令牌 | ⏸ | tokens.json + sync 脚本 |
| v0.4 proto→Dart/TS | ⏸ | gen_clients.sh + CI 验证 |
| v0.5 Evie Mobile 落地 | ⏸ | Flutter iOS/Android |
| v0.6 Evie Desktop 落地 | ⏸ | Flutter macOS/Windows/Linux |
| v0.7 Workbench Mobile | ⏸ | React Native（实战验证 skill） |
| v0.8 GEO Mini Program | ⏸ | uni-app（实战验证 skill） |

---

## 关联文档

- 仓库级规则：[`AGENTS.md`](./AGENTS.md)
- 根仓库架构总纲：[`../../docs/architecture/0-0-架构总览-架构总览.md`](../../docs/architecture/0-0-架构总览-架构总览.md)
- 端承载三分天下：[`../../docs/architecture/0-1-架构总览-平台分层设计.md`](../../docs/architecture/0-1-架构总览-平台分层设计.md)
- 服务资料：[`../../docs/services/mobile-desktop/`](../../docs/services/mobile-desktop/)

## 维护者

本架构文档与 `AGENTS.md` 同步演进。任何修改都应先在仓库的 GitHub Issue 中讨论，并附 ADR 记录。
