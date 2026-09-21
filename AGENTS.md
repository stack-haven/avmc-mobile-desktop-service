# 移动桌面服务（Mobile Desktop Service）— AI 编码工程宪法（Constitution）

> 本文件定义了 `mobile-desktop-service` monorepo 的工程治理、架构边界、仓库结构、依赖规则、开发工作流和 AI 编码 Agent 行为规范。
>
> 本文件是本仓库的权威工程规则。
>
> 应用专属规则由各应用级 `AGENTS.md` 定义，必须遵守本文件所确立的规则。
>
> **语言说明**：本文件为原 `AGENTS.md`（ChatGPT 生成英文原版）的中文直译版，并叠加了与 Ark Tech Platform（avmc）平台规范的架构对齐标注（见各章节内的「🟢 avmc 对齐」注脚）。原英文版请参见 `AGENTS.md`。

---

## 1. 仓库使命

`mobile-desktop-service` 是更大多产品 SaaS 技术平台内的**客户端应用 monorepo**。

其目的是为以下场景提供统一的工程环境，以构建和演进：

* 移动应用（Mobile applications）
* 桌面应用（Desktop applications）
* 共享的客户端能力
* 共享的设计系统
* 共享的基础设施包（Packages）
* 产品专属的客户端应用

本仓库围绕以下理念设计：

> **多产品 + Monorepo + 共享能力 + 独立产品演进**

本仓库必须支持多产品，**而不强制产品进入不必要的耦合**。

> 🟢 **avmc 对齐**：本仓库是 Ark Tech Platform（`avmc`）根仓库的第三个子仓库（与 `backend-service`、`frontend-service` 并列）。根仓库入口与决策权限分级见 `../.agents/AGENTS.md` 和 `../.agents/RULES.md`。仓库层文档（README / SERVICE / ONBOARDING）位于根仓库 `../docs/services/mobile-desktop/`。

---

## 2. 核心工程哲学

本仓库遵循以下原则：

```text
产品独立（Product Independence）
        ↓
清晰的边界（Clear Boundaries）
        ↓
显式的依赖（Explicit Dependencies）
        ↓
可复用的能力（Reusable Capabilities）
        ↓
持续演进（Continuous Evolution）
```

首要目标不是最大化的代码复用。

首要目标是：

> **安全的复用，同时不牺牲产品独立性。**

只有当共享抽象已经稳定、且复用的价值已被证明时，代码才应该被共享。

---

## 3. 仓库架构

本仓库采用两级组织：

```text
mobile-desktop-service/
│
├── apps/
│   ├── product_a/
│   ├── product_b/
│   └── growth_companion/
│
└── packages/
    ├── design_system/
    ├── networking/
    ├── authentication/
    ├── storage/
    └── ...
```

两个目录承担根本不同的职责。

### `apps/`

存放**独立可执行的产品应用**。

一个应用：

* 拥有自己的产品体验
* 拥有自己的产品专属业务特性
* 拥有自己的应用状态
* 拥有自己的产品专属 UI
* 可以消费共享包
* **禁止直接依赖**其他应用的内部实现

### `packages/`

存放**可复用的客户端能力**。

一个包应该代表一项稳定且有意义的能力。

示例：

```text
design_system
networking
authentication
storage
analytics
logging
```

**一个包不应该沦为通用杂物堆（generic dumping ground）**。

> 🟢 **avmc 对齐**：仓库实际结构除 `apps/` 与 `packages/` 外，还包含：
>
> - `tooling/` — 仓库级 CLI 工具与脚本（生成器、检测器）
> - `tool/` — 应用级脚本（每个 app 内部 `tool/` 复制自 `tooling/`）
> - `melos.yaml` — Flutter 应用 monorepo 编排器（Dart-only 项目使用）
> - `package.json` + `pnpm-workspace.yaml` — React Native / uni-app TypeScript 项目使用
> - `tokens.json` — 跨端设计令牌 SSOT（Single Source of Truth）
>
> 三栈（Flutter / RN / uni-app）工具链**不强求统一**，各自使用生态原生工具（详见 `../.agents/skills/avmc-mobile-desktop-monorepo/SKILL.md`）。

---

## 4. 应用边界（Application Boundary）

`apps/` 下的每个应用都是独立的产品边界。

示例：

```text
apps/
├── growth_companion/
├── product_a/
└── product_b/
```

每个应用必须能够：

* 独立构建
* 独立测试
* 独立演进
* 定义自己的产品特性
* 定义自己的产品专属 UI
* 定义自己的产品专属状态

一个应用**绝不能依赖另一个应用的私有实现**。

禁止：

```text
apps/growth_companion/
    ↓
apps/product_a/lib/internal/
```

禁止：

```dart
import '../../product_a/lib/features/xxx/...';
```

应用**只能通过显式定义的包**来共享功能。

推荐：

```text
apps/growth_companion/
        ↓
packages/design_system/
```

---

## 5. 应用独立性

一个应用的设计**不应围绕其他应用的实现**。

避免：

```text
Product A
    ↓
Product B
    ↓
Product C
```

推荐：

```text
             Shared Package
              /     |     \
             ↓      ↓      ↓
        Product A Product B Product C
```

共享依赖应该形成可复用的基础设施，而不是产品到产品的依赖。

---

## 6. 包边界（Package Boundary）

一个包的存在需要正当理由（被创建的合理性），前提是它代表的能力符合以下条件：

* 被多个应用使用
* 足够稳定以至于可以拥有明确的 API
* 与具体产品无关
* 集中维护有价值
* 作为单一实现比多份拷贝更易维护

**不应**仅仅因为以下理由而创建一个包：

* 某个文件很大
* 一个特性包含若干类
* 开发者想要更清晰的目录
* 代码可能某天会被复用
* AI Agent 想避免重复

**潜在的可复用性不是充分理由。**

---

## 7. 共享代码晋升规则

代码的默认生命周期是：

```text
特性级本地（Feature-local）
     ↓
应用内共享（Application-shared）
     ↓
跨应用复用已被证明
     ↓
共享包（Shared package）
```

**不要逆转此过程。**

**不要**从：

```text
packages/
```

开始就试图预测未来每一个可复用的抽象。

优先**先在本地拥有**。

只有当代码的复用和职责被充分理解后，才提升到共享包。

---

## 8. 共享包晋升标准

在将代码迁入 `packages/` 之前，评估：

```text
1. 是否被多个应用使用？
2. 职责是否清晰？
3. 公共 API 是否稳定？
4. 是否包含产品专属假设？
5. 独立版本管理或独立测试是否有用？
6. 集中所有权是否能降低长期维护成本？
7. 共享是否减少重复而不引入耦合？
```

如果多项答案不明确，**保持在本地实现**。

---

## 9. 禁止通用杂物堆

避免出现以下包：

```text
packages/common/
packages/utils/
packages/helpers/
packages/misc/
packages/shared_everything/
```

除非它们的职责被**显式定义**。

特别要避免：

```text
packages/common/utils/
```

作为一个无关功能的大杂烩位置。

优先采用语义化包：

```text
packages/
├── design_system/
├── networking/
├── authentication/
├── storage/
└── analytics/
```

包名应该传达其职责。

---

## 10. 依赖方向

依赖通常应按以下方向流动：

```text
应用（Application）
    ↓
共享包（Shared Packages）
    ↓
外部依赖（External Dependencies）
```

**共享包绝不能依赖应用专属代码。**

禁止：

```text
packages/design_system
    ↓
apps/growth_companion
```

禁止：

```text
packages/networking
    ↓
apps/product_a
```

推荐：

```text
apps/growth_companion
    ↓
packages/networking
```

---

## 11. 禁止循环依赖

循环依赖被严格禁止。

禁止：

```text
Package A
   ↓
Package B
   ↓
Package A
```

也要避免间接循环：

```text
Application
 ↓
Package A
 ↓
Package B
 ↓
Application
```

依赖图应该保持**有向且可理解**。

---

## 12. 共享包设计

一个共享包应暴露**较小的公共 API**。

推荐结构：

```text
Package
├── public API（公共 API）
├── internal implementation（内部实现）
└── tests（测试）
```

消费者应**依赖公共契约而非内部文件**。

避免不必要地暴露实现细节。

即使包位于同一个 Monorepo 内，也应被视为一个**架构边界**。

---

## 13. 公共 API 稳定性

一旦一个包被多个应用消费，其公共 API 就成为**兼容性边界**。

以下内容的修改必须谨慎考虑：

* 公共类（Public classes）
* 公共函数（Public functions）
* 公共模型（Public models）
* 公共接口（Public interfaces）
* 配置契约（Configuration contracts）
* 事件（Events）
* 序列化格式（Serialization formats）

破坏性变更（Breaking changes）需要：

* 影响分析
* 消费者审查
* 测试
* 必要时提供迁移策略

---

## 14. 设计系统策略

本仓库可以提供一个共享的 Design System 包。

示例：

```text
packages/design_system/
```

共享 Design System 应提供可复用的基础，例如：

```text
Colors（颜色）
Typography（字体）
Spacing（间距）
Radius（圆角）
Elevation（阴影）
Icons（图标）
Motion（动效）
Buttons（按钮）
Inputs（输入框）
Cards（卡片）
Dialogs（对话框）
Sheets（抽屉）
Navigation components（导航组件）
```

但**共享 Design System 不得包含产品专属的业务 UI**。

例如：

允许：

```text
AppButton（应用按钮）
AppCard（应用卡片）
AppTextField（应用文本框）
AppDialog（应用对话框）
```

不恰当：

```text
HabitCompletionCard（习惯完成卡片）
ChildGrowthTimeline（儿童成长时间线）
FamilyRewardWidget（家庭奖励组件）
```

除非此类组件已被证明可跨产品复用，且其语义确实与产品无关。

> 🟢 **avmc 对齐**：本仓库的 Design System 由 `tokens.json` 单一源驱动，通过 `tooling/scripts/sync_design_tokens.sh` 同步到：
>
> - **Flutter**：`packages/design_system/lib/tokens.dart`（生成）
> - **React Native**：`packages/design_system/src/tokens.ts`（生成）
> - **uni-app**：`packages/design_system/common/tokens.scss`（生成）
>
> 不允许直接编辑生成文件。详见 `../.agents/skills/avmc-mobile-desktop-monorepo/SKILL.md` 第五章。

---

## 15. 产品品牌 vs 共享设计系统

共享 Design System 提供**通用的交互和视觉基础**。

每个应用可以定义自己的：

* 品牌（Brand）
* 主题（Theme）
* 产品配色（Product colors）
* 产品字体选择（Product typography）
* 产品专属组件（Product-specific components）
* 产品专属交互模式（Product-specific interaction patterns）

因此：

```text
共享 Design System
        +
产品主题
        +
产品组件
        =
产品 UI
```

**不要强迫所有应用使用完全相同的视觉识别。**

---

## 16. 应用级架构

每个应用必须定义自己的架构。

例如，一个 Flutter 应用可能使用：

```text
Feature-first（特性优先目录）
+
MVVM
+
Riverpod
+
Repository（仓储）
+
Service（服务）
+
go_router
```

详细的框架和 UI 规则属于：

```text
apps/<application>/AGENTS.md
```

Monorepo 级别的规则**不应规定**某个应用框架专属的实现细节。

> 🟢 **avmc 对齐**：本仓库三栈共存，状态管理与导航库**不预设**：
>
> - **Flutter**：`avmc-flutter-app` skill 默认 `flutter_bloc`（兼容 `very_good_cli`），可切换 `riverpod`
> - **React Native**：`avmc-react-native-app` skill 默认 `zustand`（生态主流），可切换 Redux Toolkit
> - **uni-app**：`avmc-uniapp-app` skill 默认 `Pinia`（Vue 生态原生）
>
> 详细状态管理决策见 `../.agents/skills/avmc-{flutter-app,react-native-app,uniapp-app}/SKILL.md`。
>
> 导航库：Flutter `go_router` / RN `react-navigation` / uni-app `uni.navigateTo` + 自封装。

---

## 17. 应用级规则继承

规则层级为：

```text
仓库级（更高层）规则
            ↓
Monorepo 规则
            ↓
应用规则
            ↓
特性规则
            ↓
实现细节
```

应用级 `AGENTS.md` 可以**细化**仓库级规则。

但**不得违反**仓库级规则。

如果低层级规则与高层级规则冲突，**高层级规则优先**，除非有明确的架构决策文档记录该例外。

> 🟢 **avmc 对齐**：本仓库的规则层级与 avmc 根仓库的 `.agents/RULES.md` 一致，根仓库的 `RULES.md` 处于最高层级。

---

## 18. Growth Companion 示例

`growth_companion` 是本 Monorepo 内的产品应用。

其结构可能演化为：

```text
apps/growth_companion/
├── AGENTS.md
├── ARCHITECTURE.md
├── PRODUCT_PRINCIPLES.md
├── UI_GUIDELINES.md
├── docs/
│   ├── architecture/
│   ├── adr/
│   ├── product/
│   └── ui/
├── lib/
│   ├── app/
│   ├── core/
│   ├── shared/
│   └── features/
└── test/
```

该应用拥有自己的产品专属概念，例如：

```text
Child（孩子）
Family（家庭）
Growth（成长）
Habit（习惯）
Record（记录）
Plan（计划）
Reward（奖励）
```

这些概念必须保留在应用内部，除非跨产品复用已被证明。

---

## 19. 跨应用业务逻辑

不要仅仅因为两个应用当前有相似需求，就把业务逻辑移入共享包。

例如：

```text
Growth Companion
    Habit（习惯）

Product B
    Task（任务）
```

即使两者都包含：

```text
create（创建）
complete（完成）
archive（归档）
```

也不应自动共享一个 `TaskService`。

**语义相似不一定意味着架构同一。**

仅在以下条件下共享概念：

* 领域含义**确实相同**
* 行为**稳定**
* 所有权**清晰**
* API 对所有消费者**都合适**

---

## 20. 变更范围（Change Scope）

每个编码 Agent 任务必须在实施前确立**最小有效变更边界**。

默认范围：

```text
1. 当前特性
2. 当前应用
3. 仅在必要时触及共享包
4. 仅在必要时触及 Monorepo 级配置
```

Agent 不得修改不相关的应用。

Agent 不得仅仅为了简化本地实现就修改共享包。

Agent 在执行产品特性任务时**不得进行全仓库范围的重构**，除非被显式要求。

> 🟢 **avmc 对齐**：本规则与根仓库 `.agents/AGENTS.md` 的「Agent 决策权限分级」中的 `autonomous` 档位含义一致——Agent 默认只能在最小范围内自主行动。详见 `../.agents/skills/agent-decision-boundary/SKILL.md`。

---

## 21. 架构升级（Architecture Escalation）

当实现看起来需要修改共享包时，Agent 必须评估该需求是否真的跨应用。

如果不明确，**在做出共享修改前停下来并报告**：

```text
Architecture Escalation（架构升级）

Reason（原因）：
为什么共享包看起来需要修改。

Affected Package（受影响的包）：
packages/xxx

Current Consumer（当前消费者）：
apps/xxx

Potential Consumers（潜在消费者）：
apps/xxx
apps/yyy

Risk（风险）：
潜在的兼容性或耦合影响。

Recommendation（建议）：
建议的架构方向。
```

Agent 可以识别架构问题。

但 Agent **不得悄悄重新定义仓库架构**。

> 🟢 **avmc 对齐**：本节对应 avmc 根仓库的 `requires-confirmation` 决策档——任何会改变公共契约、跨产品公共能力、平台-产品边界的请求都必须先经过 skill 门禁。详见 `../.agents/skills/agent-decision-boundary/SKILL.md`。

---

## 22. 新包规则

在正常的特性实现过程中**不得创建新包**，除非：

* 现有包无法合理提供该能力
* 新能力有清晰的边界
* 包的所有权清晰
* 包的 API 可被定义
* 其依赖方向正确
* 其长期维护成本合理

对于架构级包的创建，当变更具有重大意义时，**应在 ADR 中记录该决策**。

---

## 23. 依赖管理

依赖在被引入前必须经过评估。

考虑以下因素：

```text
要解决的问题
仓库现有能力
Flutter/Dart 标准能力
维护状态
社区采用度
API 质量
许可证
平台兼容性
性能
包体积影响
安全性
长期风险
```

在合适时**优先使用仓库现有能力**。

**不要**在没有文档化理由的情况下引入解决同一问题的重复库。

---

## 24. 依赖版本管理

依赖应以一致的方式管理。

**不允许**单个应用在没有正当理由的情况下独立选择同一关键共享依赖的不兼容版本。

当某个依赖在 Monorepo 内被有意共享时，**优先采用集中式版本治理**（前提是仓库工具支持）。

破坏性的依赖升级应在所有受影响的应用和包上进行验证。

---

## 25. 工具链一致性

仓库应保持以下方面的一致性：

* Dart/Flutter 版本（在可行时）
* 格式化规则
* 静态分析
* 测试约定
* CI 行为
* 依赖管理
* 代码生成策略

应用可能有合理的差异，但**差异必须是刻意的**。

> 🟢 **avmc 对齐**：三栈（Flutter / RN / uni-app）工具链**不强求统一**：
>
> - Flutter：Melos 编排 + `very_good_analysis` 静态分析 + `flutter_test`
> - RN：pnpm workspaces + ESLint + `react-native-testing-library`
> - uni-app：HBuilderX（开发）+ CLI（CI 自动化）+ ESLint
>
> 仅在**公共契约**（proto 生成、设计令牌、CI 入口）上保持一致。

---

## 26. 代码生成（Code Generation）

生成代码不得成为隐藏的架构依赖。

代码生成必须满足：

* **可复现**（Reproducible）
* **有文档**（Documented）
* **在可行时是确定性的**（Deterministic）
* **在 CI 中被验证**（Validated in CI）

**不要**手动编辑生成文件，除非生成器明确要求。

> 🟢 **avmc 对齐**：本仓库跨端 API 客户端由 `backend-service/proto/` 单一源驱动，通过 `tooling/scripts/gen_clients.sh` 一次生成：
>
> - Dart 客户端（Flutter 用）
> - TypeScript 客户端（RN / uni-app 用）
>
> 生成产物不进入版本控制；CI 必须从干净环境拉取 proto + 生成 + 编译验证。详见 `../.agents/skills/avmc-mobile-desktop-monorepo/SKILL.md` 第六章。

---

## 27. 测试策略

测试在多个层级存在。

### 包测试

每个可复用包必须测试：

* 公共 API
* 重要行为
* 边界情况
* 兼容性敏感行为

### 应用测试

每个应用必须测试：

* 特性行为
* ViewModels / Cubits
* Repositories
* 重要 UI 状态
* 关键用户路径

### 集成测试

关键跨特性流程应在应用级进行测试。

不要要求每个包都采用完全相同的测试策略。

测试应与**职责和风险**相匹配。

---

## 28. CI 要求

CI 应验证受影响的范围。

最低限度，CI 应能验证：

```text
格式化
静态分析
单元测试
Widget 测试
集成测试（必要时）
代码生成一致性
依赖完整性
```

共享包的变更必须触发对其已知消费者的验证。

> 🟢 **avmc 对齐**：CI 通过 `dorny/paths-filter` 实现**变更驱动**——只对受影响的栈（Flutter / RN / uni-app）触发对应工作流。详见 `tooling/.github/workflows/`。

---

## 29. AI 编码 Agent 工作流

AI 编码 Agent 必须遵循以下顺序：

```text
理解（Understand）
   ↓
检查（Inspect）
   ↓
分析（Analyze）
   ↓
规划（Plan）
   ↓
实现（Implement）
   ↓
验证（Validate）
   ↓
审查（Review）
   ↓
文档（Document）
```

Agent 不得跳过仓库检查。

在修改代码前，检查：

* 适用的 `AGENTS.md` 文件
* 仓库结构
* 相关包边界
* 现有实现
* 测试
* ADR
* 共享依赖

> 🟢 **avmc 对齐**：本工作流与根仓库 `.agents/RULES.md` 的「三模式」（Explore / Implement / Review）一一对应：
>
> - 理解 + 检查 + 分析 → **Explore 模式**（只读）
> - 规划 + 实现 + 验证 → **Implement 模式**（写）
> - 审查 + 文档 → **Review 模式**（复盘）

---

## 30. AI Agent 上下文解析

当工作在以下位置时：

```text
apps/growth_companion/
```

Agent 应按以下顺序解析适用规则：

```text
仓库级规则（avmc 根 .agents/AGENTS.md）
        ↓
mobile-desktop-service/AGENTS.md（本文件）
        ↓
应用级规则（apps/<app>/AGENTS.md）
        ↓
特性级规则（如果存在）
```

**最具体的适用规则细化更宽泛的规则。**

具体规则**不得违反**高层架构边界。

---

## 31. AI Agent 必须在创建前检查

在创建以下内容前：

```text
新包
新共享组件
新工具类
新服务
新抽象
```

Agent **必须**搜索是否存在现有等价物。

**不要**创建重复的能力。

Agent 应优先采用以下顺序：

```text
复用现有抽象
        ↓
扩展现有抽象
        ↓
创建应用内本地抽象
        ↓
创建共享包
```

按此顺序进行。

---

## 32. AI Agent 不得过度共享

Agent 不得仅因为以下原因就将代码抽取到 `packages/`：

* 看起来可复用
* 在一个应用内被使用两次
* 看起来通用
* 实现很大
* Agent 想要减小本地文件大小

**复用是一个架构决策。**

---

## 33. AI Agent 不得跨越应用边界

Agent **绝不能**直接导入另一个应用的内部代码。

如果功能确实需要共享：

1. 识别共享能力
2. 定义公共契约
3. 创建或扩展一个包
4. 更新消费者
5. 添加测试
6. 在适当的时候记录该架构决策

---

## 34. AI Agent 变更报告

完成有意义的工作后，Agent 必须报告：

```text
Scope（范围）
Changed Applications（变更的应用）
Changed Packages（变更的包）
Architecture Impact（架构影响）
Tests（测试）
Validation（验证）
Potential Risks（潜在风险）
Follow-up Work（后续工作）
```

如果修改了共享包，必须显式指出：

```text
Consumers affected（受影响的消费者）
Compatibility impact（兼容性影响）
Migration requirements（迁移要求）
```

> 🟢 **avmc 对齐**：本节与根仓库 `.agents/skills/avmc-cross-repo-review/SKILL.md` 的交付检查清单一致——跨仓库改动必须明确标识子仓库影响、API 兼容性、子模块指针。

---

## 35. 不得进行不相关的重构

特性开发**不得**成为大规模清理的借口。

避免：

```text
特性变更
+
仓库范围重命名
+
架构迁移
+
依赖升级
+
全仓库格式化
```

除非被显式要求。

当为了安全实现特性而必须进行重构时：

* 保持重构最小化
* 解释为什么必要
* 将大型重构拆分为独立变更（如果可能）

---

## 36. 架构决策记录（ADR）

有意义的 Monorepo 架构决策应存储在：

```text
docs/adr/
```

推荐结构：

```text
docs/adr/
├── 0001-monorepo-structure.md
├── 0002-shared-package-policy.md
└── 0003-design-system-boundary.md
```

每个 ADR 应说明：

```text
Context（背景）
Problem（问题）
Options Considered（已考虑的选项）
Decision（决策）
Consequences（后果）
Revisit Conditions（重新审视的条件）
```

不要为琐碎的实现决策创建 ADR。

> 🟢 **avmc 对齐**：本仓库的 ADR 实际放在根仓库 `../docs/architecture/`，遵循 avmc 平台的「架构文档中心化」原则。子仓库的 ADR 可在 `mobile-desktop-service/docs/adr/` 单独记录，或在 `../docs/architecture/0-X-治理-mobile-desktop-service-*` 命名下统一管理。详见 `../.agents/RULES.md` 文档层级。

---

## 37. 技术债

技术债**必须显式化**。

当明知故犯地引入技术债时，文档化：

```text
它为什么存在
为什么现在可以接受
它创造了什么风险
应当在何时重新审视
```

**不要**让临时架构悄悄成为永久架构。

> 🟢 **avmc 对齐**：本仓库的技术债跟踪整合到根仓库 `../docs/architecture/4-6-治理-开发功能清单.md` 的「已知技术债」章节。

---

## 38. 演进原则

Monorepo **必须**通过证据演进。

优先采用：

```text
真实需求
    ↓
本地实现
    ↓
重复出现的模式
    ↓
稳定的抽象
    ↓
共享包
```

避免：

```text
假想的未来
    ↓
通用的抽象
    ↓
共享包
    ↓
强行的复用
```

架构应从稳定的模式中涌现。

---

## 39. 产品独立性

共享基础设施**不得**强制产品采用相同的产品行为。

一个共享包应**提供能力**，而不是**规定产品策略**。

例如：

```text
认证包（Authentication Package）
```

可以提供：

* 会话管理
* 令牌处理
* 认证状态

但**不应决定**：

* 产品如何展示登录页
* 引导流程长什么样
* 存在哪些业务角色
* 产品专属权限意味着什么

**基础设施提供能力。**

**产品拥有产品行为。**

---

## 40. 安全与隐私

本仓库**必须**遵循最小特权原则。

**绝不提交**：

```text
API 密钥
访问令牌
刷新令牌
私有证书
密码
生产环境凭证
```

**不得**通过以下渠道暴露敏感用户信息：

* 日志
* 分析
* 调试输出
* 测试夹具
* 示例文件

处理敏感信息的应用**必须**定义自己的数据处理规则。

> 🟢 **avmc 对齐**：本节与根仓库 `.agents/RULES.md` 的「权限控制必须在后端执行」和「Feature Flag 不替代权限校验」配合。所有跨端应用通过 `backend-service/pkg/auth` 统一鉴权，客户端**不存储**凭证。

---

## 41. 开源就绪

本仓库意图支持开源开发。

工程决策应考虑：

* 清晰的文档
* 可复现的开发
* 可理解的架构
* 贡献工作流
* 许可证兼容性
* 公共 API 稳定性
* 避免组织专属秘密
* 清晰的示例

**不要**依赖未文档化的内部知识。

重要的架构知识**必须**体现在仓库文档中。

---

## 42. 文档层级

仓库文档应按职责组织。

```text
AGENTS.md
    ↓
工程治理（Engineering governance）

ARCHITECTURE.md
    ↓
仓库架构（Repository architecture）

docs/adr/
    ↓
架构决策（Architectural decisions）

apps/<app>/AGENTS.md
    ↓
应用工程规则（Application engineering rules）

apps/<app>/ARCHITECTURE.md
    ↓
应用架构（Application architecture）

apps/<app>/PRODUCT_PRINCIPLES.md
    ↓
产品哲学（Product philosophy）

apps/<app>/UI_GUIDELINES.md
    ↓
产品 UI / UX 规则（Product UI / UX rules）
```

**不要**在每个文档中重复同一条规则。

每个文档应有**清晰的职责**。

> 🟢 **avmc 对齐**：本仓库的实际文档层级：
>
> - 根仓库 `../.agents/AGENTS.md` — Agent 入口与决策权限
> - 根仓库 `../.agents/RULES.md` — 平台规则
> - 根仓库 `../.agents/REVIEW.md` — Code Review 清单
> - 根仓库 `../docs/services/mobile-desktop/{README,SERVICE,ONBOARDING}.md` — 服务资料
> - 本文件 `mobile-desktop-service/AGENTS.md` — 仓库级工程宪法
> - `mobile-desktop-service/ARCHITECTURE.md`（待建）— 仓库架构
> - `apps/<app>/AGENTS.md` — 应用级规则

---

## 43. 仓库健康

仓库应定期评估：

* 依赖图
* 包边界
* 应用独立性
* 共享包使用率
* 测试健康度
* CI 可靠性
* 依赖重复度
* 技术债
* 构建性能
* 开发者体验
* AI 生成代码质量

目标不是永远保留当前架构。

目标是**维护一个能安全演进的系统**。

---

## 44. 决策层级

在做出仓库级工程决策时，按以下优先级排序：

```text
1. 产品独立
2. 架构完整性
3. 安全与隐私
4. 数据正确性
5. 可维护性
6. 可测试性
7. 开发者体验
8. 性能
9. 复用
10. 实现速度
```

复用**有意不放在产品独立之上**。

**最便宜的共享抽象不一定是最佳架构。**

> 🟢 **avmc 对齐**：本节与根仓库 `docs/architecture/0-4-架构总览-工程治理总纲.md` §五、§六 的「决策原则」一致。Agent 决策权限三档（autonomous / requires-confirmation / forbidden）即基于此层级。

---

## 45. 终极原则

`mobile-desktop-service` 不仅仅是应用的集合。

它是一个面向多产品的**长生命周期客户端工程平台**。

其架构应支持：

```text
多个产品
        ↓
独立演进
        ↓
选择性复用
        ↓
稳定的共享能力
        ↓
一致的工程质量
        ↓
持续演进
```

根本规则是：

> **共享能力，不共享所有权（Share capabilities, not ownership）。**

应用拥有自己的产品。

包拥有稳定的可复用能力。

Monorepo 拥有工程一致性。

编码 Agent **加速实现**。

**人类保留对产品方向和架构决策的责任。**

最终目标是：

> **构建一个客户端工程系统，使 AI 能够提高开发速度，而不允许短期的实现决策破坏长期的架构完整性。**

---

## 附录 A：avmc 平台对齐速查

> 本附录汇总本仓库与 avmc 根仓库规范的关联点，方便 Agent 快速查询。

### A.1 必读入口（按优先级）

| 顺序 | 文档 | 用途 |
|:---:|------|------|
| 1 | `../.agents/AGENTS.md` | 平台总入口 + Agent 决策权限 |
| 2 | `../.agents/RULES.md` | 平台规则 |
| 3 | `../.agents/REVIEW.md` | Code Review 清单 |
| 4 | `../docs/services/mobile-desktop/README.md` | 服务入口 |
| 5 | `../docs/services/mobile-desktop/SERVICE.md` | 服务定义 |
| 6 | `../docs/services/mobile-desktop/ONBOARDING.md` | 新成员入门 |
| 7 | 本文件 | 仓库级工程宪法 |
| 8 | `apps/<app>/AGENTS.md` | 应用级规则 |

### A.2 三栈共存（本仓库特性）

| 栈 | 目录约定 | 状态管理（默认） | 导航 | CI 触发器 |
|------|----------|------------------|------|----------|
| Flutter | `apps/<name>/` | `flutter_bloc` | `go_router` | `dorny/paths-filter` 检测 `apps/*/lib/**` |
| React Native | `apps/<name>/` | `zustand` | `react-navigation` | 检测 `apps/*/src/**` |
| uni-app | `apps/<name>/` | `Pinia` | `uni.navigateTo` | 检测 `apps/*/pages/**` |

### A.3 avmc-* Skill 集成

| Skill | 适用场景 | 决策档位 |
|-------|---------|----------|
| `avmc-mobile-desktop-monorepo` | monorepo 初始化、跨端生成、令牌同步 | `autonomous` |
| `avmc-flutter-app` | Flutter 应用脚手架、特性创建 | `autonomous` |
| `avmc-react-native-app` ⚠️ | RN 应用脚手架 | `requires-confirmation`（基础版待实战） |
| `avmc-uniapp-app` ⚠️ | uni-app 应用脚手架 | `requires-confirmation`（基础版待实战） |
| `avmc-submodule-sync` | 跨子仓库提交与指针更新 | `autonomous`（已确认方案） |
| `avmc-cross-repo-review` | 跨仓库交付完整性审查 | `autonomous` |
| `avmc-contract-first-backend` | 后端 proto→客户端生成 | `autonomous` |
| `agent-decision-boundary` | 决策档位判定 | **强制门禁** |

### A.4 与根仓库 4-6 治理清单的关联

本仓库的实战跟踪整合到 `../docs/architecture/4-6-治理-开发功能清单.md`：

- **4.3 Skill 实战跟踪**：RN/uni-app skill 实战验证进度
- **4.4 mobile-desktop-service 演进**：本仓库每次重大变更的记录

### A.5 提交流程（必须遵守）

```text
1. 在子仓库内完成代码与文档
2. 子仓库内 git commit（独立 commit）
3. 子仓库 git push
4. 回到根仓库，git add mobile-desktop-service（更新 gitlink 指针）
5. 根仓库 git commit "chore(submodule): mobile-desktop-service 指针更新 + 相关文档"
6. 根仓库 git push
```

详见 `../.agents/skills/avmc-submodule-sync/SKILL.md`。

---

## 附录 B：本文件与原 chatgpt 版本的差异

> 本节记录中文直译 + 架构对齐过程中对原 chatgpt 英文版的全部修改，便于 code review 与回溯。

### B.1 新增内容

| # | 位置 | 新增内容 | 原因 |
|---|------|---------|------|
| 1 | 顶部语言说明 | 双语说明 + 原版引用 | 让读者清楚本文件是中文直译版 + 对齐版 |
| 2 | §1 注脚 | avmc 子仓库定位 | 与根仓库 `.agents/AGENTS.md` 对齐 |
| 3 | §3 注脚 | `tooling/`、`tool/`、`tokens.json` 等实际目录 | 补齐仓库实际结构 |
| 4 | §14 注脚 | `tokens.json` → 三端生成 | 设计与 `sync_design_tokens.sh` 配套 |
| 5 | §16 注脚 | 三栈状态管理决策表 | 中立，不预设 |
| 6 | §17 注脚 | 与 `.agents/RULES.md` 层级一致 | 平台规则继承 |
| 7 | §20 注脚 | 决策档位映射 | `autonomous` ↔ 最小变更范围 |
| 8 | §21 注脚 | 映射到 `requires-confirmation` | 通过 `agent-decision-boundary` skill 门禁 |
| 9 | §25 注脚 | 三栈工具链不强求统一 | 实战选择 |
| 10 | §26 注脚 | proto→Dart+TS 生成 | 与 `gen_clients.sh` 配套 |
| 11 | §28 注脚 | `dorny/paths-filter` 变更驱动 | CI 实战 |
| 12 | §29 注脚 | 三模式映射 | Explore/Implement/Review |
| 13 | §34 注脚 | `avmc-cross-repo-review` 关联 | 跨仓库交付 |
| 14 | §36 注脚 | 指向根仓库 `docs/architecture/` | ADR 实际位置 |
| 15 | §37 注脚 | 指向 4-6 清单 | 技术债跟踪 |
| 16 | §40 注脚 | 后端统一鉴权 | 与 `pkg/auth` 集成 |
| 17 | §42 注脚 | 实际文档层级 | 列出 avmc 的真实文档清单 |
| 18 | §44 注脚 | 决策原则映射 | 与 0-4 治理总纲一致 |
| 19 | 附录 A | avmc 平台对齐速查 | 快速索引 |
| 20 | 附录 B | 差异记录 | code review 友好 |

### B.2 未修改内容

所有章节的**核心规则**（标题、规则列表、代码块示例）保持与 chatgpt 原版一致，仅通过注脚补充 avmc 项目特定信息，**未删除或削弱任何原规则**。

### B.3 待办

- [ ] 本仓库 `ARCHITECTURE.md` 尚未创建
- [ ] `docs/adr/` 目录尚未建立（当前 ADR 在根仓库 `docs/architecture/`）
- [ ] `apps/growth_companion/AGENTS.md`（chatgpt 生成，28KB）需要与本文件做对齐 review

---

> 📌 **使用建议**：本文件是 `mobile-desktop-service` 仓库的工程宪法。任何修改本文件或仓库架构的提议，应先在仓库的 GitHub Issue 中讨论，并附 ADR 记录。
