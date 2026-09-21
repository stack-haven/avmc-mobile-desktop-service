
# Growth Companion — AI Coding 工程宪章

> 本文件是 `mobile-desktop-service/apps/growth_companion` 的应用级 AI Coding 工程规范。
>
> 本文件继承并服从上级目录 `mobile-desktop-service/AGENTS.md` 的 Monorepo 工程规则。
>
> 本文件只定义 Growth Companion 应用自身的产品与 Flutter 工程规则，不重复定义 Monorepo 层面的通用规则。

## 0. 文档继承关系（avmc 平台对齐）

本文件继承并服从上级规则，遵循 avmc 平台「规则从最高到最低」的解析顺序：

```text
1. 平台总纲：avmc/.agents/AGENTS.md（avmc/.agents/RULES.md / REVIEW.md）
2. 仓库级：mobile-desktop-service/AGENTS.md（Monorepo 通用规则）
3. ADR 索引：avmc/docs/architecture/4-2-治理-架构决策记录索引.md
4. 本文件：Growth Companion 应用级 Flutter 规则（当前文件）
5. Feature 局部：lib/features/<name>/AGENTS.md（如存在）
```

**规则解析原则**：

- 低层级可**细化**高层级规则
- 低层级**不得违反**高层级规则
- 冲突时上层优先（除非有 ADR 例外记录）
- AI Agent 修改代码前必读：本文件 + 仓库级 AGENTS.md + 平台总纲

> 🟢 **avmc 对齐**：本文件不重复定义上层规则（Monorepo 通用、平台总纲、ADR），仅在「应用级」范围内补充。

---

# 1. 应用定位

Growth Companion 是一个面向儿童成长记录、习惯培养、家庭实践与成长过程管理的 Flutter 应用。

当前 `growth_companion` 是工程目录与代码标识，不代表最终产品品牌名称。

产品品牌、商业定位、视觉品牌等未来可以独立演进。

因此：

* 不得将 `growth_companion` 等同于最终产品品牌
* 不得在代码中大规模硬编码具体品牌名称
* 产品名称、Logo、品牌文案等应通过产品配置或 Design System 管理
* 技术架构必须允许未来进行品牌调整，而无需大规模修改业务代码

核心工程目标：

> 构建一个真正意义上的高质量移动应用，而不是将 Web 页面简单包装成 App。

---

# 2. 核心工程原则

本项目遵循以下优先级：

```text
产品体验
    ↓
用户任务完成效率
    ↓
交互与状态正确性
    ↓
应用架构
    ↓
代码质量
    ↓
工程效率
```

不要为了所谓“架构完整”牺牲真实用户体验。

不要为了“代码优雅”增加不必要的抽象。

不要为了“未来可能复用”提前建设复杂基础设施。

核心原则：

> 先解决真实产品问题，再设计合理架构；先建立稳定边界，再进行抽象。

---

# 3. Flutter 应用架构原则

本项目采用 Flutter 官方推荐的分层思想，并结合实际产品规模进行裁剪。

推荐基本结构：

```text
Presentation
    ↓
ViewModel
    ↓
Repository
    ↓
Service / Local Data / Remote API
```

必要时增加：

```text
Presentation
    ↓
ViewModel
    ↓
UseCase / Domain
    ↓
Repository
    ↓
Data Source
```

但：

> Domain / UseCase 不是所有功能的强制层。

只有当业务逻辑确实复杂、具有独立业务语义或需要跨多个数据源协调时，才引入 Domain / UseCase。

禁止为了“Clean Architecture”而机械创建：

```text
Entity
Repository Interface
Repository Impl
UseCase
Mapper
DTO
Model
Service
```

对于简单 CRUD 功能，不允许产生没有实际价值的层级。

---

# 4. 单向数据流

应用采用单向数据流：

```text
User Action
    ↓
ViewModel
    ↓
State Change
    ↓
View Update
    ↓
Repository
    ↓
Data Source
```

数据返回：

```text
Remote / Local
    ↓
Repository
    ↓
ViewModel
    ↓
Immutable State
    ↓
View
```

View 不应该直接修改业务状态。

View 不应该直接访问 Repository。

View 不应该直接调用 HTTP API。

---

# 5. UI 是状态的表现

必须建立以下开发认知：

> UI 不是数据请求的副作用，而是 State 的可视化表现。

页面必须能够明确描述：

```text
Initial
Loading
Loaded
Empty
Refreshing
Submitting
Success
Error
Offline
Syncing
```

具体状态根据业务需要裁剪。

禁止仅使用：

```dart
bool isLoading
```

试图管理整个复杂页面状态。

当一个页面存在多个独立异步状态时，应建立结构化 State。

---

# 6. State 管理

默认采用：

* Riverpod
* Immutable State
* Provider / Notifier 等 Riverpod 官方推荐模式

State 应满足：

1. 可预测
2. 可观察
3. 可测试
4. 可组合
5. 尽量不可变

推荐：

```text
State
    ↓
ViewModel / Notifier
    ↓
Repository
```

禁止：

```text
Widget
    ↓
大量业务逻辑
    ↓
API
```

> 🟢 **avmc 对齐**：本项目实际使用 **bloc + cubit**（`avmc-flutter-app` skill 默认值，兼容 very_good_cli 脚手架）。
>
> **两种选择**（以 ADR 记录选择原因）：
>
> | 模式 | 创建命令 | 依赖 |
> |------|---------|------|
> | bloc（默认） | `bash tool/create_feature.sh <name> --state-management bloc` | `flutter_bloc` / `bloc` / `bloc_test` / `mocktail`（v_g_cli 已含） |
> | riverpod（可选） | `bash tool/create_feature.sh <name> --state-management riverpod` | 需手动加 `flutter_riverpod` / `riverpod_annotation` / `freezed_annotation` / `json_serializable` / `build_runner` |
>
> **历史说明**：本项目初始化于 very_good_cli（bloc 默认），与 chatgpt §6 主张的 Riverpod 存在差异。如需从 bloc 迁移到 Riverpod，按 §45 流程先写 ADR-007 State Management Migration。

---

# 7. Widget 职责

Widget 主要负责：

* UI 结构
* 用户交互绑定
* UI 状态展示
* 动画
* 页面布局
* Design System 使用

Widget 不负责：

* HTTP 请求
* 数据库操作
* 复杂业务判断
* 数据转换
* 权限业务判断
* 多步骤业务流程
* 跨页面状态协调

如果 Widget 中出现大量：

```dart
if (...)
for (...)
try/catch
await repository.xxx()
```

应重新评估职责边界。

---

# 8. ViewModel 职责

ViewModel 是：

> 用户操作与业务状态之间的协调层。

ViewModel 可以负责：

* 响应用户操作
* 调用 Repository
* 管理页面状态
* 编排简单业务流程
* 处理页面级错误
* 管理加载与刷新状态
* 管理提交状态
* 触发本地更新
* 协调乐观更新

ViewModel 不应该：

* 直接操作 Flutter Widget
* 操作 BuildContext
* 直接进行 HTTP 请求
* 直接操作数据库
* 承担复杂领域模型
* 成为“万能 Service”

---

# 9. Repository 原则

Repository 是应用的数据访问抽象与数据真相边界。

职责包括：

* 获取远程数据
* 获取本地数据
* 保存数据
* 更新数据
* 删除数据
* 数据同步
* 缓存协调
* 本地与远程数据源协调

推荐：

```text
ViewModel
    ↓
Repository
    ↓
RemoteDataSource
    ↓
API
```

或者：

```text
ViewModel
    ↓
Repository
    ├── LocalDataSource
    └── RemoteDataSource
```

Repository 应尽可能成为：

> Feature 对数据来源的唯一认知边界。

---

# 10. Service 原则

Service 用于封装外部系统能力。

例如：

```text
ApiService
AuthService
StorageService
NotificationService
AnalyticsService
FileService
AudioService
```

Service 不应该承载完整业务流程。

例如：

错误：

```text
GrowthService.recordHabitAndCalculateRewardAndSync()
```

更合理：

```text
HabitRepository.record()
```

Service 负责“能力”。

Repository 负责“数据”。

ViewModel 负责“页面交互与状态”。

Domain / UseCase 负责“复杂业务规则”。

---

# 11. Domain / UseCase 使用原则

只有满足以下情况之一，才考虑 Domain / UseCase：

### 11.1 业务规则复杂

例如：

```text
习惯完成
    ↓
连续天数计算
    ↓
成长积分
    ↓
奖励规则
    ↓
成长等级
```

### 11.2 一个业务操作需要多个 Repository

例如：

```text
完成习惯
    ↓
HabitRepository
    ↓
GrowthRecordRepository
    ↓
RewardRepository
    ↓
NotificationRepository
```

### 11.3 业务逻辑需要独立测试

如果业务规则脱离 UI 后仍然具有明显业务价值，可以进入 Domain。

### 11.4 多个页面共享复杂业务规则

此时可以考虑：

```text
Domain Service
UseCase
Policy
Rule
```

但不要为了“架构标准”强行创建 UseCase。

---

# 12. Feature First

应用采用 Feature First 组织方式。

推荐：

```text
lib/
├── app/
├── core/
├── shared/
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── child/
│   ├── habit/
│   ├── growth/
│   ├── family/
│   ├── record/
│   └── settings/
└── main.dart
```

每个 Feature 尽量自包含：

```text
feature/
├── presentation/
├── application/
├── domain/
└── data/
```

但不要求所有 Feature 都必须拥有全部目录。

例如简单功能可以只有：

```text
feature/
├── presentation/
└── data/
```

复杂功能再逐步增加：

```text
feature/
├── presentation/
├── application/
├── domain/
└── data/
```

---

# 13. Feature 边界

Feature 应按照产品能力划分，而不是按照技术类型划分。

推荐：

```text
features/
├── habit/
├── child/
├── family/
├── growth/
```

不推荐：

```text
screens/
widgets/
services/
models/
controllers/
```

后者容易形成大型技术垃圾场。

---

# 14. Feature 内部依赖原则

推荐：

```text
presentation
    ↓
application
    ↓
domain
    ↓
data
```

实际项目中可以适当简化。

禁止：

```text
Widget → API
Widget → Database
Feature A → Feature B 的内部实现
```

如果 Feature A 需要 Feature B 的能力：

优先考虑：

```text
Shared Contract
Application Service
Domain Service
Shared Package
```

而不是直接引用 Feature B 的内部文件。

---

# 15. 跨 Feature 依赖

Feature 默认拥有自己的业务边界。

例如：

```text
habit
child
growth
family
```

不能形成：

```text
habit → child
child → growth
growth → family
family → habit
```

形成循环后，应重新审视领域边界。

跨 Feature 的依赖应该通过：

* 明确的接口
* Application 层
* Domain 能力
* Shared capability

进行协调。

---

# 16. Shared 与 Core

`core/` 用于真正属于应用基础能力的内容。

例如：

```text
core/
├── routing/
├── network/
├── storage/
├── logging/
├── error/
├── configuration/
└── platform/
```

`shared/` 用于应用内部多个 Feature 确实共享的能力。

例如：

```text
shared/
├── widgets/
├── design_system/
├── formatters/
└── components/
```

禁止把所有暂时不知道放哪里的代码都放进：

```text
shared/
utils/
helpers/
common/
```

---

# 17. Shared 晋升原则

一个 Feature 中的代码只有在出现真实复用需求后，才考虑晋升到 Shared。

判断标准：

```text
真实复用
+
稳定语义
+
明确边界
+
多个调用方
```

而不是：

> “以后可能会用到。”

共享代码必须是：

> 能力共享，而不是业务所有权共享。

---

# 18. Design System

本项目不把 Material 3 默认样式直接当作最终产品设计。

Material 3 可以作为：

* 基础组件
* Accessibility 基础
* Theme 基础
* Platform 适配基础

但产品必须逐步建立自己的 Design System。

至少包括：

```text
Color
Typography
Spacing
Radius
Elevation
Icon
Button
Input
Card
Dialog
BottomSheet
Navigation
Feedback
Empty State
Loading
```

最终目标：

```text
Product Design Language
        ↓
Design Tokens
        ↓
Reusable Components
        ↓
Feature UI
```

---

# 19. Design Token

禁止在业务 Widget 中大量出现：

```dart
Color(...)
EdgeInsets(...)
BorderRadius(...)
TextStyle(...)
```

尤其是重复出现相同设计参数时。

应逐步沉淀：

```text
AppColors
AppTypography
AppSpacing
AppRadius
AppElevation
```

设计参数应具有语义。

例如：

```text
spacingSmall
spacingMedium
spacingLarge
```

而不是大量：

```text
8
12
16
24
32
```

> 🟢 **avmc 对齐**：本仓库的 Design Token 由 Monorepo 共享 SSOT 驱动：
>
> - **SSOT**：`mobile-desktop-service/packages/design-tokens/tokens.json`
> - **同步脚本**：`bash mobile-desktop-service/tool/sync_design_tokens.sh`
> - **Dart 产物**：`packages/design-tokens/lib/theme.dart` → `class AppTheme`（含 color/spacing/radius/elevation/typography 全部 token）
> - **验证脚本**：`bash tool/sync_design_tokens.sh --check`（CI 用）
>
> **本应用规则**：
>
> 1. **禁止在本应用内重新定义 token**（不创建 `AppColors` / `AppSpacing` 等本地类）
> 2. **新增 token**：修改 `tokens.json` → 跑 `sync_design_tokens.sh` → 引用 `AppTheme.xxx`
> 3. **设计变更走 ADR**：与 design / brand 相关的 token 增减需先写 ADR（与设计师对齐）

---

# 20. UI 质量要求

本项目以真实移动应用的体验作为目标。

禁止简单复制 Web 页面思维：

```text
页面
↓
请求接口
↓
显示列表
```

移动 App 必须关注：

* 手势
* 点击反馈
* 滑动
* 拖拽
* Bottom Sheet
* Dialog
* Page Transition
* Loading
* Skeleton
* Empty State
* Error Recovery
* Pull to Refresh
* Optimistic UI
* Animation
* Keyboard
* Safe Area
* 系统返回
* 前后台切换
* 网络变化

---

# 21. 页面状态设计

每个重要页面必须考虑：

```text
首次进入
加载中
加载成功
无数据
加载失败
下拉刷新
提交中
提交成功
提交失败
网络断开
恢复网络
后台恢复
```

不能只设计：

```text
成功页面
```

然后由 AI Coding Agent 自动补齐异常状态。

---

# 22. Optimistic UI

对于用户高频操作，应优先考虑乐观更新。

例如：

```text
用户完成习惯
    ↓
立即更新 UI
    ↓
后台同步服务器
```

而不是：

```text
点击完成
    ↓
等待 API
    ↓
API 成功
    ↓
刷新页面
```

如果采用 Optimistic UI，必须处理：

```text
Success
Failure
Rollback
Retry
Sync
```

不能为了“看起来快”而忽略数据一致性。

---

# 23. Local First / Offline Aware

儿童成长、习惯记录等场景具有明显的：

* 高频操作
* 移动网络不稳定
* 家庭环境
* 弱网
* 短时离线

特征。

因此架构必须允许逐步演进到：

```text
UI
 ↓
Local State / Local DB
 ↓
Sync Engine
 ↓
Remote API
```

当前如果没有复杂离线需求，可以先采用：

```text
Memory Cache
+
Local Storage
+
Remote API
```

但禁止把整个应用设计成完全依赖网络请求才能正常交互。

---

# 24. 数据同步

当引入本地数据后，必须明确：

```text
Local Source
Remote Source
Sync State
Conflict Strategy
Retry Strategy
```

例如：

```text
pending
syncing
synced
failed
conflict
```

不要简单使用：

```text
isSynced = true / false
```

来覆盖复杂同步状态。

---

# 25. API 边界

所有 API 访问必须经过统一网络层。

禁止 Feature 自己创建：

```dart
Dio()
http.Client()
```

禁止 Widget 直接访问 HTTP。

推荐：

```text
API Client
    ↓
Remote Data Source
    ↓
Repository
    ↓
ViewModel
```

API DTO 与业务模型必要时应进行隔离。

---

# 26. 错误处理

错误必须具有明确语义。

至少区分：

```text
NetworkError
AuthenticationError
AuthorizationError
ValidationError
BusinessError
ServerError
TimeoutError
UnknownError
```

UI 层不应该直接处理底层：

```text
SocketException
DioException
FormatException
```

这些应该在边界层转换成应用可理解的错误模型。

---

# 27. 日志

日志用于：

* 问题定位
* API 调试
* 状态流转分析
* 同步问题分析
* 性能问题分析

禁止：

```text
print()
```

作为正式生产日志方案。

日志不得输出：

* Token
* 密码
* 私密数据
* 儿童敏感信息
* 用户隐私数据

---

# 28. 儿童数据与隐私

本产品涉及儿童成长数据，因此开发时必须默认采用隐私保护原则。

禁止在日志、异常信息、调试接口中随意输出：

* 儿童姓名
* 联系方式
* 家庭信息
* 身份信息
* 详细行为记录
* 其他敏感数据

调试数据必须最小化。

数据采集遵循：

> 必要、明确、最小化。

---

# 29. 路由

统一使用：

```text
go_router
```

路由应承担：

* 页面导航
* 参数传递
* 深链接
* 登录状态控制
* 路由守卫
* 页面生命周期入口

禁止在 Widget 内部散落复杂路由判断。

> 🟢 **avmc 对齐**：`go_router` 是 avmc 跨端应用（含本应用）默认路由方案。
>
> **本应用规则**：
>
> 1. 路由集中定义在 `lib/app/routing/app_router.dart`
> 2. **禁止直接使用** `Navigator.push/pop`（必须走 `context.go()` / `context.push()`）
> 3. **路由参数**：用 `GoRouterState` 的 `extra` / `pathParameters` / `queryParameters`，**禁止**用全局单例传递
> 4. **深链接**：通过 `go_router` 的 `redirect` 处理；如需全平台统一深链接格式，写 ADR
> 5. **`auto_route`（注解式路由）**：本项目**默认不启用**。如需启用：
>    - 手动加 `auto_route` + `auto_route_generator` + `build_runner` 依赖
>    - 写 ADR-008 Auto Route Migration
>    - 跑 `dart run build_runner build` 生成路由表

---

# 30. Platform Adaptation

本项目目标平台包括移动设备，并允许未来扩展桌面端。

因此禁止假设：

```text
所有设备屏幕一样
所有输入方式一样
所有平台导航一样
```

必须考虑：

### iOS

* Safe Area
* Cupertino interaction
* 手势返回
* 键盘
* 状态栏
* 页面转场

### Android

* 系统返回
* Material interaction
* Back gesture
* 状态栏
* 导航栏

### Desktop（未来）

* Mouse
* Keyboard
* Hover
* Window size
* Multi-column layout
* Shortcut

---

# 31. Responsive UI

禁止：

```dart
width: 375
height: 812
```

作为核心布局逻辑。

应基于：

```text
constraints
MediaQuery
LayoutBuilder
Adaptive Layout
```

设计布局。

---

# 32. Animation

动画不是装饰，而是交互反馈。

优先用于：

* 页面转场
* 状态变化
* 操作反馈
* 列表变化
* 元素出现/消失
* 成长反馈
* 任务完成
* 数据同步

动画必须：

* 有目的
* 时间适当
* 可中断
* 不阻塞操作
* 不影响性能

禁止为了“看起来高级”增加大量动画。

---

# 33. Accessibility

所有重要 UI 必须考虑：

* Semantics
* Touch target
* Text scaling
* Contrast
* Screen reader
* Keyboard navigation（桌面）
* Reduced motion（必要时）

默认点击区域应满足合理的移动端可操作尺寸。

---

# 34. Performance

重点关注：

```text
Build 次数
Widget Tree
List Rendering
Image Loading
Animation
Memory
Network
Local DB
```

禁止在 `build()` 中进行：

* 网络请求
* 数据库查询
* 大量计算
* 不必要对象创建

长列表优先采用：

```text
ListView.builder
SliverList
```

等懒加载方式。

---

# 35. 图片与媒体

儿童成长场景可能涉及：

* 图片
* 视频
* 音频
* 语音

媒体处理必须考虑：

```text
压缩
缓存
上传状态
失败重试
取消上传
断点续传（必要时）
本地预览
远程同步
```

不能把媒体文件生命周期简单等同于 API 请求生命周期。

---

# 36. 测试策略

测试不是最后补充，而是架构设计的一部分。

至少覆盖：

### Unit Test

测试：

* Domain
* UseCase
* Formatter
* Parser
* Policy
* 状态转换

### Repository Test

测试：

* Remote
* Local
* Cache
* Sync
* Error

### ViewModel Test

测试：

```text
Action
→ State
```

### Widget Test

测试：

* UI 状态
* 用户交互
* Widget 行为

### Integration Test

测试：

```text
登录
→ 创建孩子
→ 创建习惯
→ 完成习惯
→ 查看成长记录
```

等关键用户路径。

> 🟢 **avmc 对齐**：测试强度遵循 avmc 平台分层（`ADR-005 测试基线策略`）：
>
> | 测试层 | 覆盖目标 | 强度 |
> |--------|---------|------|
> | **核心业务规则** | Domain / UseCase | 100% 行覆盖 |
> | **状态转换** | Cubit / Notifier | 覆盖所有 action → state 路径（`bloc_test` / `riverpod_test`）|
> | **数据访问** | Repository | 覆盖 Local + Remote + Error 三条路径 |
> | **关键 UI** | Page / Widget | 覆盖 Initial/Loading/Loaded/Error 四态 |
> | **集成** | Critical Path | 端到端验证关键用户路径 |
>
> **本项目规则**：
>
> 1. **本应用默认不接 `integration_test` 包**（受移动自动化测试成本约束）
> 2. **覆盖率门禁**：`tool/check_architecture.sh` + `flutter test --coverage`；CI 验证但不阻断
> 3. **测试基线**如需调整：写 ADR + 与架构师对齐
>
> 详细见 `avmc/.agents/REVIEW.md` T01-T05。

---

# 37. 测试优先级

不是所有代码都需要相同测试强度。

优先级：

```text
核心业务规则
    ↓
数据同步
    ↓
关键用户流程
    ↓
ViewModel
    ↓
Repository
    ↓
复杂 Widget
    ↓
普通 UI
```

核心业务逻辑必须具有稳定自动化测试。

---

# 38. Mock / Fake

优先使用：

```text
Fake
Stub
Test Repository
```

而不是对所有代码进行大量 Mock。

测试应该尽量验证真实行为，而不是验证内部实现细节。

---

# 39. AI Coding Agent 工作方式

AI Coding Agent 必须遵循：

```text
Understand
    ↓
Inspect
    ↓
Analyze
    ↓
Plan
    ↓
Implement
    ↓
Validate
    ↓
Review
    ↓
Report
```

禁止：

```text
收到需求
↓
直接生成代码
```

---

# 40. AI Agent 开始任务前必须检查

至少检查：

```text
当前目录
AGENTS.md
pubspec.yaml
现有 Feature
现有 Design System
现有 State
现有 Repository
现有测试
相关依赖
相关路由
```

如果任务涉及跨 Feature：

必须进一步检查相关 Feature 的边界。

---

# 41. AI Agent 必须先理解现有代码

新增代码之前：

> 优先复用现有能力，而不是立即创建新能力。

例如：

```text
已有 Button
已有 Card
已有 AppTheme
已有 ApiClient
已有 Repository
已有 Error Model
```

不得重新实现。

---

# 42. AI Agent 禁止行为

禁止：

### 42.1 无理由引入依赖

不得因为“这个库比较好”就增加依赖。

必须说明：

```text
为什么需要
解决什么问题
现有方案为什么不足
长期维护成本
```

### 42.2 过度抽象

禁止：

```text
未来可能复用
```

作为抽象理由。

### 42.3 大规模重构

用户只要求：

```text
增加功能 A
```

不得顺便重构：

```text
A + B + C + D
```

### 42.4 修改无关 Feature

禁止扩大变更范围。

### 42.5 修改 Shared Package

如果需要修改上级 Shared Package：

必须明确说明：

```text
为什么需要修改
影响哪些 Feature
是否应该晋升为共享能力
```

---

# 43. AI Agent 变更范围

默认原则：

> 最小必要变更。

例如需求是：

```text
增加习惯完成动画
```

默认只能修改：

```text
habit/
```

及必要的：

```text
shared/design_system/
```

不能顺便修改：

```text
child/
family/
growth/
```

除非存在真实依赖。

---

# 44. AI Agent 的架构升级

当 AI Agent 发现当前架构无法支持需求时，不应直接进行大规模重构。

必须先：

```text
发现问题
↓
描述问题
↓
提出方案
↓
评估影响
↓
确定方案
↓
再实施
```

如果涉及重大架构变化，应形成 ADR。

---

# 45. ADR

重要架构决策必须记录。

例如：

```text
docs/adr/
```

记录：

```text
背景
问题
候选方案
决策
原因
影响
替代方案
未来演进
```

典型 ADR：

```text
ADR-001 State Management
ADR-002 Local Storage
ADR-003 Offline Sync
ADR-004 Design System
ADR-005 Navigation
ADR-006 Authentication
```

> 🟢 **avmc 对齐**：ADR 存放位置遵循「双轨」原则：
>
> | 决策范围 | 存放位置 | 命名 |
> |---------|---------|------|
> | **应用内**（仅 growth_companion 内部） | `apps/growth_companion/docs/adr/0001-...md` | 独立文件 |
> | **跨应用 / 跨端 / 公共契约** | `avmc/docs/architecture/4-2-治理-架构决策记录索引.md` | 作为 ADR-011+ 内嵌条 |
> | **仓库级**（影响 monorepo） | `mobile-desktop-service/docs/adr/0001-...md` | 独立文件 |
>
> **本项目规则**：
>
> 1. **本地 ADR 编号从 0001 开始**（0001-monorepo-structure 已被 monorepo 占用）
> 2. **跨应用影响**：同步登记到根仓库 `4-2-治理-架构决策记录索引.md`
> 3. **避免文档孤岛**：本地 ADR 应在文件中说明与上游规则的关联
> 4. **新功能起 ADR**：状态管理迁移、存储选型、离线同步、认证接入、第三方 SDK 接入等
>
> **新增**：`docs/adr/` 目录尚未创建（待首个 ADR 触发时建立）。

---

# 46. Feature 开发流程

一个完整 Feature 推荐按照：

```text
1. 产品需求
2. 用户场景
3. 用户流程
4. 状态模型
5. 数据模型
6. UI 结构
7. Repository
8. ViewModel
9. Widget
10. Error / Empty / Loading
11. Animation
12. Test
13. Review
```

而不是：

```text
先写页面
再补 API
最后补逻辑
```

---

# 47. 用户流程优先

开发前必须回答：

```text
用户是谁？
用户为什么进入？
用户进入后想完成什么？
第一步是什么？
下一步是什么？
成功是什么？
失败是什么？
没有数据怎么办？
网络断开怎么办？
用户返回怎么办？
用户中途退出怎么办？
```

如果这些问题没有答案，不应该直接开始 UI Coding。

---

# 48. 产品体验优先级

任何 Feature 的设计优先考虑：

```text
是否容易理解
↓
是否容易开始
↓
是否容易完成
↓
是否有明确反馈
↓
是否愿意再次使用
```

而不是：

```text
功能数量
页面数量
代码数量
```

---

# 49. 儿童成长场景特殊要求

儿童成长产品的核心不是“记录数据”，而是：

```text
目标
↓
行动
↓
坚持
↓
反馈
↓
成长
```

因此产品中的数据应该围绕用户行为服务。

例如：

```text
习惯
目标
行动
记录
连续性
反馈
成长
```

不要单纯构建：

```text
CRUD 页面
```

---

# 50. 用户角色

系统未来可能涉及：

```text
家长
儿童
家庭成员
老师
机构
管理员
```

但 Feature 不应因为未来角色而提前复杂化。

只在真实需求出现时引入：

```text
Role
Permission
Visibility
Interaction Mode
```

---

# 51. 数据模型演进

数据模型必须允许产品演进。

不要轻易把业务含义写死在：

```text
enum
String
Boolean
```

例如：

```text
habitType
growthType
rewardType
```

如果业务未来可能扩展，应保留合理演进空间。

但：

> 不允许为了“未来可能有 100 种类型”而过度设计。

---

# 52. API 与客户端模型

客户端模型不应该机械复制后端数据库模型。

后端：

```text
Database Model
```

不等于：

```text
Flutter UI Model
```

必要时使用：

```text
DTO
Mapper
Domain Model
View State
```

避免后端数据库结构直接泄漏到 UI。

> 🟢 **avmc 对齐**：本应用的 API 客户端由 `backend-service/proto` SSOT 驱动：
>
> | 环节 | 工具 / 位置 |
> |------|------------|
> | Proto 源 | `backend-service/proto/<service>/v1/*.proto` |
> | 跨端生成脚本 | `bash mobile-desktop-service/tool/gen_clients.sh --scope dart` |
> | 生成产物 | `mobile-desktop-service/packages/api-client/lib/`（177+ 文件）|
> | 引用方式 | `import 'package:growth_companion/...mobile-desktop-service/packages/api-client/lib/...'` |
> | 不进入版本控制 | `.gitignore` 排除（`packages/api-client/lib/`） |
>
> **本项目规则**：
>
> 1. **禁止手写** Dart message / enum / gRPC stub——这些由 `gen_clients.sh` 生成
> 2. **新增 API**：在 `backend-service/proto/` 加 proto → 跑 `gen_clients.sh` → 使用生成的类
> 3. **模型分层**（可叠加在 proto 之上）：
>    - **proto message**（远端 / 跨端传输）
>    - **Domain Entity**（业务核心，不可变，无 JSON 序列化）
>    - **Data Model**（持久化 / 缓存，可 `fromJson`/`toJson`）
>    - **View State**（UI 状态，可能含 `isLoading` / `error` 等 UI 字段）
> 4. **Mapper**：跨层转换用显式 mapper（`xxx_mapper.dart`），不污染 entity
> 5. **DTO 与 Domain 分离**：`packages/api-client/lib/` 是 DTO；`lib/features/<x>/domain/entities/` 是 Domain

---

# 53. 配置与环境

环境相关信息不得硬编码。

例如：

```text
API URL
Environment
Feature Flag
Debug Mode
Analytics
```

应该通过统一配置管理。

推荐：

```text
development
staging
production
```

至少保证：

```text
开发环境
测试环境
生产环境
```

可以独立运行。

---

# 54. Feature Flag

对于正在演进中的产品能力，可以使用 Feature Flag。

适用于：

```text
实验功能
灰度功能
新 UI
新同步策略
AI 功能
```

Feature Flag 不应该成为永久架构。

如果一个 Flag 长期存在，应重新评估并清理。

---

# 55. AI 功能

如果未来加入 AI 能力，例如：

```text
AI 成长助手
AI 成长总结
AI 习惯建议
AI 家庭报告
AI 语音交互
```

必须将 AI 能力与核心业务逻辑适当隔离。

推荐：

```text
Feature
    ↓
AI Application Service
    ↓
AI Client / AI Service
```

而不是：

```text
Widget
    ↓
LLM API
```

AI 不应该直接决定核心业务数据的最终状态。

例如：

```text
AI 建议
```

与：

```text
系统事实
```

必须区分。

---

# 56. AI 输出可信边界

AI 产生的：

```text
建议
总结
分类
预测
内容
```

属于 AI Output。

系统中的：

```text
习惯完成
成长记录
用户设置
家庭成员
订单
权限
```

属于系统事实。

禁止 AI 直接覆盖系统事实，除非存在明确业务流程和用户确认机制。

---

# 57. AI Coding 与产品决策

AI Coding Agent 可以：

* 分析
* 设计
* 编码
* 测试
* 重构
* 检查
* 提出方案

但不能自行决定：

* 产品方向
* 核心业务规则
* 商业模式
* 用户权益
* 数据政策
* 核心交互原则

遇到不明确的产品决策时：

> 暂停实现，明确提出决策点。

---

# 58. Definition of Done

一个 Feature 只有满足以下条件，才认为完成：

### 产品

* [ ] 用户流程明确
* [ ] 正常流程完成
* [ ] 空状态完成
* [ ] Loading 完成
* [ ] Error 完成
* [ ] 弱网场景考虑
* [ ] 用户反馈明确

### 架构

* [ ] Feature 边界清晰
* [ ] Widget 没有业务逻辑污染
* [ ] Repository 边界清晰
* [ ] State 明确
* [ ] 没有不必要抽象
* [ ] 没有循环依赖

### UI

* [ ] Design System 已使用
* [ ] iOS / Android 行为合理
* [ ] 响应式布局
* [ ] 手势合理
* [ ] 动画合理
* [ ] Accessibility 基础要求满足

### 工程

* [ ] `dart format`
* [ ] `flutter analyze`
* [ ] 测试通过
* [ ] 新增核心逻辑有测试
* [ ] 没有 debug 代码
* [ ] 没有敏感日志

### AI Coding

* [ ] 变更范围符合需求
* [ ] 没有无关重构
* [ ] 没有无理由增加依赖
* [ ] 没有重复实现已有能力
* [ ] 必要的架构决策已经记录

> 🟢 **avmc 对齐**：DoD 的「AI Coding」部分应额外检查：
>
> - [ ] 修改是否在 `autonomous` 档位范围（最小必要变更）
> - [ ] 是否触发 `requires-confirmation` 档位（如有，需取得用户/架构师确认）
> - [ ] 是否触发 `forbidden` 档位（如有，必须停止并上报）
> - [ ] 修改后阅读：`avmc/.agents/AGENTS.md` §Agent 决策权限分级
> - [ ] 跨应用改动：执行 `avmc-cross-repo-review` skill
>
> 详细判定规则见 `avmc/.agents/skills/agent-decision-boundary/SKILL.md`。

---

# 59. 提交前验证

AI Agent 在结束任务前必须至少执行：

```bash
dart format .
flutter analyze
flutter test
```

如果项目配置了：

```text
integration_test
build_runner
code generation
lint
coverage
```

也必须根据实际修改范围执行。

不能只说：

> “代码应该没问题。”

必须提供实际验证结果。

---

# 60. AI Agent 最终报告

完成任务后必须说明：

```text
## 完成内容

- xxx
- xxx

## 修改范围

- xxx
- xxx

## 架构影响

- 无
```

如果存在架构影响：

```text
## 架构影响

- 新增 xxx
- 修改 xxx
- 原因 xxx

## 验证

- flutter analyze: PASS
- flutter test: PASS

## 风险

- xxx
```

> 🟢 **avmc 对齐**：跨子仓库 / 跨端 / 公共能力改动应在原报告基础上**补充**：
>
> - **受影响的 consumers**（谁依赖本次改动）：
>   - apps/growth_companion（自身）
>   - apps/evie-mobile / evie-desktop（如有）
>   - mobile-desktop-service 仓库级（packages/、tooling/）
>   - avmc 根仓库（文档 / .agents/）
> - **兼容性影响**：breaking / additive / patch
> - **迁移要求**（如 breaking）：受影响方需要做什么
> - **指针更新**：子仓库 commit 后，根仓库 `.gitmodules` gitlink 是否需要更新
>
> 详细报告模板见 `avmc/.agents/skills/avmc-cross-repo-review/SKILL.md`。
>
> **本项目规则**：
>
> 1. **应用内改动**（仅 `apps/growth_companion/`）：使用原 chatgpt §60 模板
> 2. **跨子仓库改动**（影响 mobile-desktop-service 仓库级）：补充上面 4 节
> 3. **跨 avmc 仓库改动**（影响 frontend-service / backend-service / 根仓库）：执行 `avmc-cross-repo-review` skill

---

# 61. 依赖管理

引入第三方依赖前必须回答：

```text
为什么需要？
Flutter 官方能力是否足够？
现有依赖是否能够解决？
维护状态如何？
是否会增加架构耦合？
是否影响未来开源？
```

优先：

```text
Flutter SDK
Dart 官方能力
成熟稳定的社区库
```

而不是：

```text
每个问题安装一个 package
```

---

# 62. 代码生成

如果使用：

```text
Freezed
json_serializable
Riverpod Generator
build_runner
```

必须保持生成机制统一。

禁止手工修改生成文件。

生成文件：

```text
*.g.dart
*.freezed.dart
```

不应直接编辑。

> 🟢 **avmc 对齐**：本项目当前**不依赖** `build_runner` / `freezed` / `riverpod_generator` / `json_serializable`：
>
> **当前模式（bloc 默认）**：
>
> - Entity / Model：手动定义 `const class`（带 `fromJson` / `toJson` 静态方法）
> - State：sealed class + final class 层级（无需 Equatable / freezed）
> - Cubit：直接 `extends Cubit<State>`，`super(const Initial())` 初始化
> - 无 `build_runner` 依赖，因此无生成文件
>
> **可选模式（如需切换）**：
>
> | 切换目标 | 依赖 | 触发器 |
> |---------|------|-------|
> | 切到 freezed（与 bloc 配合） | `freezed_annotation` + `build_runner` + `freezed` | 写 ADR-009 Freezed Adoption |
> | 切到 Riverpod（带 generator） | `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` | 写 ADR-007 State Migration（与 §6 联动）|
>
> **如启用代码生成，必须遵守**：
>
> 1. `build_runner` 单一来源（不混用本地与全局安装）
> 2. 生成文件 `*.g.dart` / `*.freezed.dart` 不入版本控制
> 3. CI 必须验证 `build_runner build` 可重新生成（确定性）
>
> **proto 跨端生成例外**：本应用的 `packages/api-client/lib/` 由 `mobile-desktop-service/tool/gen_clients.sh` 生成，不走 `build_runner`（用 `protoc-gen-dart` 本地插件）。

---

# 63. 开源准备

如果未来该项目进入 GitHub 开源，需要保证：

* README 完整
* LICENSE 明确
* CONTRIBUTING 明确
* CHANGELOG 明确
* 环境配置不包含敏感信息
* API Key 不进入仓库
* 私有业务信息不进入公共代码
* 架构文档可理解
* 开发环境可复现

因此从现在开始就禁止：

```text
硬编码 Token
硬编码密码
硬编码生产 API
提交 .env
提交私有证书
```

---

# 64. 文档结构

应用级文档推荐：

```text
docs/
├── architecture/
├── adr/
├── product/
├── design/
├── development/
└── api/
```

其中：

```text
architecture/
```

记录架构。

```text
adr/
```

记录关键决策。

```text
product/
```

记录产品规则。

```text
design/
```

记录设计系统。

```text
development/
```

记录开发规范。

---

# 65. 代码注释

代码注释应该解释：

```text
为什么
```

而不是：

```text
做什么
```

不推荐：

```dart
// 设置 loading 为 true
isLoading = true;
```

推荐：

```dart
// 提交过程中保持当前页面状态，避免重复创建成长记录。
```

复杂业务规则必须解释其业务原因。

---

# 66. 技术债务

发现技术债务时，不允许：

```text
先不管
```

也不要求：

```text
发现问题立即全部重构
```

应该：

```text
识别
↓
记录
↓
判断影响
↓
确定优先级
↓
在合适的 Feature 演进中解决
```

技术债务必须服务于产品演进，而不是成为持续重构的理由。

---

# 67. 架构演进原则

本项目采用：

> 渐进式架构演进。

允许：

```text
简单
↓
复杂
↓
抽象
↓
复用
```

不鼓励：

```text
复杂
↓
预留
↓
抽象
↓
为了未来设计
```

架构应该由真实业务压力推动。

---

# 68. 不追求一次性完美

新 Feature 第一版允许简单。

但必须保证：

```text
边界正确
状态正确
数据正确
用户流程正确
```

不要为了追求所谓“终极架构”而延迟产品验证。

---

# 69. 产品与技术的关系

技术架构的目的不是展示技术能力。

真正目标：

```text
让产品更容易被验证
让产品更容易演进
让用户体验更稳定
让团队更容易协作
让 AI Agent 更容易理解和修改
```

因此：

> 最好的架构不是最复杂的架构，而是能够以最低认知成本持续演进的架构。

---

# 70. AI Agent 的最终原则

当需求明确时：

```text
快速实现
```

当需求不明确时：

```text
先澄清
```

当架构存在问题时：

```text
先分析
```

当存在多个方案时：

```text
比较方案
```

当涉及重大架构变化时：

```text
提出决策
```

当发现已有能力时：

```text
复用
```

当不存在真实复用时：

```text
不要抽象
```

当任务完成时：

```text
验证
```

当验证完成时：

```text
报告
```

---

# 71. 最终工程原则

Growth Companion 的工程原则归纳为：

```text
产品驱动
    ↓
用户场景驱动
    ↓
Feature 驱动
    ↓
状态驱动
    ↓
数据边界清晰
    ↓
组件复用
    ↓
渐进抽象
    ↓
自动化验证
    ↓
持续演进
```

最终目标不是：

> 写出最多代码。

也不是：

> 建立最复杂的架构。

而是：

> 用清晰、稳定、可演进的 Flutter 工程体系，持续构建一个真正优秀的儿童成长产品。

AI Coding Agent 是开发效率工具。

架构负责长期稳定性。

产品负责价值方向。

用户体验负责最终结果。

---

# 72. 本文件的继承关系

本项目规则体系（**5 层**，含 avmc 平台总纲）：

```text
avmc/（avmc 平台根仓库）
├── .agents/
│   ├── AGENTS.md           # 平台总纲 + Agent 决策权限
│   ├── RULES.md            # 平台规则
│   ├── REVIEW.md           # Code Review 阻断项
│   └── skills/             # 技能集（含 avmc-flutter-app / avmc-contract-first-backend 等）
├── docs/
│   ├── architecture/       # 架构总纲 + 平台分层设计
│   │   ├── 0-X-架构总览-*  # 顶层架构文档
│   │   ├── 1-X-技术中台-*  # 中台能力
│   │   ├── 2-X-业务中台-*  # 业务中台
│   │   ├── 3-X-跨领域-*    # API 契约、错误处理
│   │   └── 4-X-治理-*      # ADR / 测试策略 / 能力路线图
│   └── services/
│       └── mobile-desktop/  # mobile-desktop-service 服务资料
│
└── mobile-desktop-service/（子仓库，git submodule）
    ├── AGENTS.md           # Monorepo 通用规则（仓库级）
    ├── ARCHITECTURE.md     # 仓库级架构
    ├── apps/
    │   └── growth_companion/
    │       ├── AGENTS.md   # ← 本文件（Flutter 应用规则）
    │       ├── docs/adr/   # 应用级 ADR
    │       ├── ARCHITECTURE.md  # 应用架构（待创建）
    │       └── lib/
    │           ├── app/
    │           ├── core/
    │           ├── shared/
    │           └── features/
    └── packages/            # 跨应用共享（design-tokens / api-client）
```

当规则发生冲突时：

```text
avmc 平台总纲 (avmc/.agents/AGENTS.md)
    ↓
avmc ADR 索引 (avmc/docs/architecture/4-2)
    ↓
mobile-desktop-service AGENTS.md（仓库级）
    ↓
当前 AGENTS.md（本文件）
    ↓
Feature 局部规则
    ↓
任务级要求
```

但更具体的规则可以在不违反上级约束的前提下，对当前应用进行细化。

> 🟢 **avmc 对齐**：本应用规则体系的 5 层继承与 avmc 平台完全一致：
>
> 1. **平台总纲**：avmc/.agents/AGENTS.md（决策权限、协作模式）
> 2. **平台规则**：avmc/.agents/RULES.md / REVIEW.md（强制规则 + Review 阻断项）
> 3. **平台架构**：avmc/docs/architecture/（含 ADR 索引）
> 4. **仓库级**：mobile-desktop-service/AGENTS.md（Monorepo 通用）
> 5. **应用级**：本文件（Flutter 专属）
>
> **变更触发点**：
>
> - 修改 avmc 总纲 → 需架构师/平台负责人决定（`forbidden` 档位）
> - 修改仓库级 → 需平台 owner 确认（`requires-confirmation` 档位）
> - 修改应用级（本文件）→ 应用 owner 自主决定（`autonomous` 档位）
> - 修改 Feature 局部 → Feature owner 自主决定（`autonomous` 档位）

---

# 73. 最终原则

> **Growth Companion 是一个产品，不是一个 Demo。**
>
> **Flutter 是实现技术，不是产品本身。**
>
> **架构是为了让产品持续演进，而不是为了证明架构正确。**
>
> **AI Agent 是工程协作者，而不是产品决策者。**
>
> **任何代码都必须服务于真实用户、真实场景和真实业务。**

最终判断标准只有三个：

```text
用户是否更容易完成目标？
产品是否更容易持续演进？
工程是否更容易被人和 AI 理解？
```

如果答案是否定的，应重新审视实现方案。

---

# 74. CI 触发规则（avmc 平台对齐）

本应用的 CI 验证由 `mobile-desktop-service` 仓库级 GitHub Actions 驱动，不在本应用内维护。

## 74.1 触发条件（`dorny/paths-filter`）

CI 检测到以下文件改动时，触发本应用的 `_flutter-ci.yml` 可重用工作流：

```text
apps/growth_companion/**       # 本应用任意文件
packages/*-flutter/**         # Flutter 共享包
melos.yaml                    # Flutter Monorepo 配置
```

其他栈的改动不触发本应用 CI（变更驱动）：

| 栈 | 触发器 | 工作流 |
|----|--------|--------|
| React Native | `apps/workbench-*/**` / `package.json` | `_react-native-ci.yml` |
| uni-app | `apps/geo-*/**` | `_uniapp-ci.yml` |
| 设计令牌 | `packages/design-tokens/tokens.json` | 调 `sync_design_tokens.sh --check` |
| Proto 客户端 | `packages/api-client/**` / `tooling/codegen/**` | 调 `gen_clients.sh` 验证生成 |

## 74.2 本应用 CI 验证项

`_flutter-ci.yml` 包含以下验证：

```text
1. flutter pub get
2. flutter analyze --no-fatal-warnings --no-fatal-infos
3. flutter test  (覆盖 counter + features/growth_dashboard)
4. (未来) flutter build apk / ios / macos
```

## 74.3 本地验证等价命令

提交前在本地跑：

```bash
cd mobile-desktop-service/apps/growth_companion
flutter pub get
flutter analyze
flutter test
bash tool/check_architecture.sh   # 仓库结构检查
bash tool/create_feature.sh --help  # 验证脚本可运行
```

## 74.4 触发范围

```yaml
# 仓库级 mobile-desktop-ci.yml 已设置
on:
  push:
    branches: [coding/ai]   # 仅推送到 coding/ai 才触发
  pull_request:
    branches: [coding/ai]
```

PR 合并到 `coding/ai` 后自动跑 CI；PR 目标分支不是 `coding/ai` 时不触发。

> 🟢 **avmc 对齐**：CI 体系遵循 avmc 「变更驱动」原则——只对受影响的栈触发对应工作流，避免冗余。
>
> **本项目规则**：
>
> 1. **PR 必须基于 `coding/ai` 分支**（全仓库默认分支）
> 2. **CI 失败不得合入**——必须本地复现 + 修复 + 重新提交
> 3. **跨端改动**（修改 `packages/` / `tooling/` / `tokens.json`）：同时触发 monorepo 级 CI 与本应用 CI
> 4. **手动触发**：`gh workflow run _flutter-ci.yml -f app=growth_companion`

详细配置：`mobile-desktop-service/.github/workflows/mobile-desktop-ci.yml` + `_flutter-ci.yml`
