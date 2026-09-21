
# AGENTS.md

# Flutter AI Coding Engineering Constitution

> This document defines the engineering principles, architectural boundaries, coding conventions, testing requirements, and AI Coding Agent workflow for this project.
>
> All AI Coding Agents and human contributors must follow these rules unless a documented architectural decision explicitly overrides them.

## 0. Document Hierarchy

> 🟢 **avmc 对齐**：本文档是应用级（Flutter 专用）工程宪法。规则解析顺序为：
>
> 1. **根仓库**（最高）：`avmc/AGENTS.md`、`avmc/REVIEW.md`、`avmc/RULES.md`
> 2. **仓库级**：`mobile-desktop-service/AGENTS.md`（多端 monorepo 通用规则）
> 3. **应用级**（本文件）：Flutter 特定规则
> 4. **ADR**（决策记录）：`mobile-desktop-service/docs/adr/`
>
> 低层级规则可**细化**高层级规则，但**不得违反**。本文件是 chatgpt 生成的 Flutter AI 编码工程宪法，与 avmc 平台的对齐差异在各章中以「🟢 avmc 对齐」注脚标出。

---

# 1. Project Mission

This project is a high-quality Flutter mobile application for recording children's growth and guiding positive behavioral habits.

The project is designed to:

* Provide a high-quality mobile experience.
* Support long-term product evolution.
* Maintain a clean and understandable architecture.
* Enable multiple developers and AI Coding Agents to work safely.
* Minimize architectural drift and technical debt.
* Remain testable and maintainable as the product grows.
* Eventually serve as an open-source reference project.

The project must optimize for:

> Product quality + engineering quality + maintainability + evolvability.

Do not optimize only for short-term development speed.

> 🟢 **avmc 对齐**：本项目是 `mobile-desktop-service` monorepo 下的首批落地应用。monorepo 定位、三栈共存策略、子仓库提交流程见 `../../../AGENTS.md`（仓库级）和 `../../../../docs/services/mobile-desktop/{README,SERVICE}.md`（服务资料）。

---

# 2. Core Engineering Philosophy

## 2.1 Product First, Architecture Second, Implementation Third

Every implementation must follow:

```text
Product Intent
    ↓
User Scenario
    ↓
Behavior / State Model
    ↓
Architecture
    ↓
Implementation
    ↓
Validation
```

Do not begin with code when the product behavior is not understood.

The agent must understand:

1. Who is the user?
2. What problem is being solved?
3. What user behavior is expected?
4. What state changes occur?
5. What should the user see?
6. What happens when the operation fails?
7. What happens when the device is offline?
8. How will the feature evolve later?

---

# 3. Architectural Foundation

This project follows the architectural principles recommended by the Flutter team.

The primary principles are:

* Separation of concerns.
* UI layer and Data layer separation.
* MVVM.
* Repository pattern.
* Service abstraction.
* Unidirectional data flow.
* Immutable application state.
* Dependency injection.
* Explicit interfaces.
* Testability.
* Feature-oriented organization.

The architecture is inspired by the official Flutter application architecture guidance.

Architecture is a means, not the goal.

Do not introduce architectural complexity without a concrete problem it solves.

---

# 4. Architectural Layers

The default architecture is:

```text
┌─────────────────────────────────────────────┐
│                Presentation                 │
│                                             │
│ View / Screen                               │
│ ViewModel                                   │
│ UI State                                    │
│ UI Components                               │
└──────────────────────┬──────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────┐
│                  Domain                     │
│                                             │
│ Domain Models                               │
│ Business Rules                              │
│ Use Cases / Interactors                     │
│                                             │
│ Optional - only when complexity requires    │
└──────────────────────┬──────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────┐
│                    Data                     │
│                                             │
│ Repository                                  │
│ Remote Data Source                          │
│ Local Data Source                            │
│ API / Platform Services                     │
└─────────────────────────────────────────────┘
```

The Domain layer is optional.

Do NOT create UseCase classes simply to satisfy a theoretical Clean Architecture structure.

Introduce a Domain layer when:

* ViewModels become excessively complex.
* Business rules are reused across multiple features.
* Business logic requires orchestration across multiple repositories.
* Business rules need independent testing.
* The business concept has meaningful domain behavior.

---

# 5. Feature-First Organization

The primary code organization strategy is Feature-first.

Prefer:

```text
features/
├── auth/
├── family/
├── child/
├── growth/
├── habit/
├── record/
├── plan/
├── reward/
└── profile/
```

over global technical folders such as:

```text
screens/
widgets/
models/
services/
repositories/
providers/
```

A feature should contain the code that changes together.

Example:

```text
features/habit/
├── presentation/
│   ├── habit_screen.dart
│   ├── habit_view_model.dart
│   ├── habit_state.dart
│   └── widgets/
│
├── domain/
│   ├── habit.dart
│   ├── habit_record.dart
│   └── habit_rules.dart
│
└── data/
    ├── habit_repository.dart
    ├── habit_repository_impl.dart
    ├── habit_api_service.dart
    └── habit_local_service.dart
```

Not every feature must contain all three layers.

Use only what is necessary.

---

# 6. Dependency Direction

Dependencies must point toward stable abstractions.

Preferred:

```text
View
 ↓
ViewModel
 ↓
Repository
 ↓
Service
```

When a Domain layer exists:

```text
View
 ↓
ViewModel
 ↓
UseCase
 ↓
Repository
 ↓
Service
```

Forbidden:

```text
View → API Service
View → Database
View → Repository Implementation
View → HTTP Client
View → Platform Plugin
```

Forbidden:

```text
Repository A → Repository B
```

Repositories should remain independent.

If multiple repositories must be coordinated:

* Coordinate in the ViewModel for simple presentation-oriented logic.
* Introduce a Domain UseCase for complex business orchestration.

---

# 7. UI Layer Rules

Views must be declarative.

A View describes:

> What should the UI look like for the current state?

A View must NOT become the place where business logic lives.

Allowed in Views:

* Rendering UI.
* Simple conditional rendering.
* Layout logic.
* Animation logic that requires Widget context.
* Simple navigation.
* Binding gestures to ViewModel commands.

Not allowed in Views:

* API calls.
* Database operations.
* Business calculations.
* Authentication logic.
* Complex state transitions.
* Retry strategies.
* Cache management.
* Data transformation that belongs to the ViewModel or Domain layer.

Bad:

```dart
onPressed: () async {
  final result = await api.updateHabit(...);
  ...
}
```

Preferred:

```dart
onPressed: viewModel.completeHabit
```

---

# 8. ViewModel Rules

ViewModels own presentation logic and UI state.

Responsibilities include:

* Loading data.
* Transforming repository data into UI state.
* Handling user commands.
* Managing transient UI state.
* Managing loading state.
* Managing error state.
* Managing optimistic state when appropriate.
* Coordinating presentation-level interactions.

A ViewModel should expose:

```text
State
Commands
```

Example:

```text
HabitViewModel
├── state
├── load()
├── refresh()
├── completeHabit()
├── undoCompletion()
└── retry()
```

Avoid exposing internal implementation details to Views.

---

# 9. State Management

The project uses Riverpod as the primary state management and dependency injection mechanism unless an explicit ADR states otherwise.

State should be:

* Explicit.
* Immutable.
* Observable.
* Testable.
* Serializable where persistence is required.

Prefer:

```text
UI = f(State)
```

The UI should react to state.

Do not make Widgets the source of truth.

> 🟢 **avmc 对齐**：本项目的 `avmc-flutter-app` skill（位于 `mobile-desktop-service/.agents/skills/avmc-flutter-app/`）提供脚本与模式选择：
>
> - **默认**：bloc + cubit（兼容 `very_good_cli` 生成器，零额外依赖）
> - **可选**：Riverpod 2.x + freezed + riverpod_generator（需手动加依赖）
>
> **当前实现差异**：`growth_companion` 脚手架由 `very_good_cli` 生成，使用 **bloc**（cubit 模式）。如需迁移到 Riverpod，请创建 ADR 记录原因与计划。创建 feature 脚本：`bash tool/create_feature.sh <name> --state-management bloc|riverpod`。

---

# 10. Single Source of Truth

Every important piece of application data must have a clear source of truth.

Examples:

```text
Authentication session
→ Session Repository

Child profile
→ Child Repository

Habit
→ Habit Repository

Growth record
→ Growth Record Repository
```

Avoid maintaining multiple competing copies of the same business state.

If temporary UI state is required, clearly distinguish:

```text
Domain State
Application State
UI State
Transient Interaction State
```

---

# 11. Repository Rules

Repositories are the source of truth for application data.

Repositories are responsible for:

* Data retrieval.
* Data persistence.
* Cache policy.
* Synchronization.
* Retry behavior.
* Error translation.
* Combining local and remote data.
* Refreshing data.
* Exposing domain/application models.

Repositories hide infrastructure details from the UI layer.

The UI must not know whether data came from:

* REST API.
* GraphQL.
* SQLite.
* Local file.
* Memory cache.
* Device platform API.

Repositories should expose stable interfaces.

Prefer:

```dart
abstract interface class HabitRepository {
  Future<Habit> getHabit(String id);

  Future<List<Habit>> getHabits();

  Future<void> completeHabit(String id);
}
```

Concrete implementations belong to the Data layer.

---

# 12. Service Rules

Services are adapters to external systems.

Examples:

```text
ApiService
AuthService
NotificationService
FileService
PlatformService
AnalyticsService
```

Services should:

* Encapsulate external APIs.
* Contain minimal state.
* Return explicit results.
* Avoid business rules.
* Be independently testable.

Services must not become a second Repository layer.

---

# 13. API Boundary

The Flutter application must not spread HTTP implementation details throughout the codebase.

Forbidden:

```dart
Dio().get(...)
```

inside arbitrary ViewModels or Widgets.

Preferred:

```text
View
 ↓
ViewModel
 ↓
Repository
 ↓
ApiService
 ↓
HTTP Client
```

API response models should not automatically become UI state.

Transform external representations at the Data/Repository boundary.

---

# 14. Local Data and Offline Awareness

This application is user-interaction intensive and should be designed to tolerate intermittent connectivity.

The application should distinguish:

```text
Local State
Remote State
Sync State
```

Important user actions should not unnecessarily block on network latency.

Where appropriate:

```text
User Action
   ↓
Immediate Local State Change
   ↓
Immediate UI Feedback
   ↓
Background Synchronization
   ↓
Sync Success / Failure
```

Use optimistic updates only when:

* The action is reversible or recoverable.
* Failure can be represented clearly.
* The local state can be reconciled safely.

Never use optimistic updates when failure could cause silent data corruption.

---

# 15. Loading / Error / Empty / Offline States

Every asynchronous feature must explicitly consider:

```text
Initial
Loading
Success
Empty
Refreshing
Submitting
Error
Offline
Syncing
Sync Failed
Retrying
```

Do not assume:

```text
loading == false && data == null
```

is sufficient application state.

The user must always understand:

* What is happening.
* Whether their action succeeded.
* Whether their data is saved.
* Whether they can retry.
* Whether the device is offline.

---

# 16. Optimistic UI

For high-frequency interactions such as:

* Habit completion.
* Like/favorite.
* Check-in.
* Reward claim.
* Record creation.

Prefer immediate visual feedback when technically safe.

Example:

```text
Tap
 ↓
UI immediately reflects expected state
 ↓
Sync in background
 ↓
Success → remain
Failure → reconcile + explain
```

The user should not experience unnecessary network-induced latency for simple interactions.

---

# 17. Navigation

Use `go_router` as the default navigation framework.

Navigation must be centralized and declarative.

Avoid scattering navigation decisions across arbitrary Widgets.

Routes should represent product-level destinations.

Example:

```text
/
├── home
├── growth
│   ├── records
│   └── detail/:id
├── habits
│   ├── list
│   ├── detail/:id
│   └── create
└── profile
```

Deep links must be considered when introducing important routes.

---

# 18. Design System

The application must maintain its own Design System.

Flutter Material 3 and Cupertino are platform foundations, not the complete product design language.

Create centralized design tokens for:

```text
Color
Typography
Spacing
Radius
Elevation
Iconography
Motion
Duration
Interaction
Component variants
```

Do not scatter arbitrary values throughout Widgets.

Avoid:

```dart
padding: EdgeInsets.all(17)
```

when the value represents a design-system concept.

Prefer semantic tokens:

```dart
padding: AppSpacing.md
```

The Design System should support:

* Brand identity.
* Accessibility.
* Dark mode if required.
* Platform adaptation.
* Consistent interaction behavior.

---

# 19. Platform Adaptation

The application must feel native on both iOS and Android.

Do not assume that identical UI behavior is always desirable.

Consider platform differences in:

* Navigation.
* Back behavior.
* Modal presentation.
* Scrolling.
* Text input.
* Keyboard.
* Permissions.
* Notifications.
* Safe areas.
* System gestures.
* Haptic feedback.

Share product design language while respecting platform conventions.

---

# 20. Animation and Motion

Animation is part of product behavior, not decoration.

Animations should:

* Communicate state changes.
* Establish spatial relationships.
* Provide feedback.
* Reduce perceived latency.
* Support user understanding.

Avoid:

* Decorative animation without purpose.
* Excessive animation.
* Long blocking transitions.
* Animation that delays important actions.

All reusable motion should be defined through Design System tokens.

---

# 21. Accessibility

Accessibility is part of product quality.

Consider:

* Semantic labels.
* Screen readers.
* Text scaling.
* Contrast.
* Touch target sizes.
* Focus behavior.
* Motion sensitivity.
* Color-independent information.
* Keyboard/accessibility navigation where applicable.

Do not use color alone to communicate important state.

---

# 22. Data Models

Prefer immutable models.

Use `freezed` or an equivalent approach when justified.

Models should have clear responsibility.

Distinguish between:

```text
API Model
Domain Model
UI State
```

Do not automatically use one model for all three layers in complex features.

For simple features, sharing a model may be acceptable when it does not create coupling.

---

# 23. Error Handling

Errors must be meaningful at the correct architectural layer.

External errors:

```text
HTTP 401
HTTP 404
Timeout
Network unavailable
Server error
```

must be translated into application-level errors before reaching the UI.

The UI should not contain:

```dart
if (statusCode == 401) ...
```

Prefer semantic errors:

```text
AuthenticationRequired
ResourceNotFound
NetworkUnavailable
PermissionDenied
OperationFailed
```

Never silently swallow exceptions.

---

# 24. Logging

Logs must be:

* Structured.
* Meaningful.
* Safe.
* Environment-aware.

Never log:

* Passwords.
* Access tokens.
* Refresh tokens.
* Personal sensitive information.
* Child-sensitive information.
* Full API credentials.

Production logging must be intentionally controlled.

---

# 25. Testing Strategy

Testing is part of implementation, not a final phase.

Required testing layers:

```text
Service
   ↓ Unit Test

Repository
   ↓ Unit Test

ViewModel
   ↓ Unit Test

View
   ↓ Widget Test

Navigation / DI
   ↓ Integration Test

Critical User Journey
   ↓ Integration Test
```

Flutter's recommended architecture explicitly advocates independently testing Services, Repositories and ViewModels, Widget Tests for Views, and using Fakes to keep boundaries clear.

---

# 26. Testability Rule

Every architectural component should have explicit inputs and outputs.

Prefer:

```text
Constructor Injection
```

over:

```text
Global Singleton
```

Do not make code difficult to test because of convenience.

A component that cannot be reasonably tested should trigger architectural review.

---

# 27. Fake Before Mock

Prefer lightweight Fakes where practical.

Example:

```text
FakeHabitRepository
FakeUserRepository
FakeApiService
```

Use mocks when interaction verification is specifically useful.

Do not overuse mocking.

Tests should primarily verify observable behavior rather than implementation details.

---

# 28. Definition of Done

A feature is NOT complete merely because it compiles.

A feature is complete when:

* Product acceptance criteria are satisfied.
* Architecture boundaries are respected.
* Relevant tests are implemented.
* Relevant tests pass.
* Static analysis passes.
* Formatting passes.
* No unnecessary dependencies were introduced.
* Error states are handled.
* Loading states are handled.
* Empty states are handled.
* Offline behavior is considered.
* Accessibility is considered.
* Documentation is updated when necessary.
* No unrelated code was modified.

---

# 29. AI Coding Agent Workflow

AI Agents must follow this workflow.

## Step 1 — Understand

Inspect:

* Product documentation.
* Architecture documentation.
* Existing feature structure.
* Related implementation.
* Related tests.
* ADRs.

Do not immediately modify code.

> 🟢 **avmc 对齐**：在检查「架构文档」时，按顺序读取：
>
> 1. 根仓库 `avmc/AGENTS.md`、`avmc/RULES.md`、`avmc/REVIEW.md`（平台总规则）
> 2. 仓库级 `../../../AGENTS.md`（monorepo 通用规则）
> 3. 本文件（应用级 Flutter 规则）
> 4. 仓库级与根仓库的 `docs/architecture/`（架构总纲 + ADR）
> 5. 仓库级 `.agents/skills/avmc-flutter-app/`（Flutter 专用 skill）

## Step 2 — Analyze

Identify:

* Existing abstractions.
* Dependencies.
* Reusable components.
* Architectural constraints.
* Potential side effects.
* Testing requirements.

## Step 3 — Plan

Before substantial implementation, describe:

```text
Goal
Affected Features
Architecture Changes
Files to Change
New Files
State Changes
Data Changes
Testing Strategy
Potential Risks
```

## Step 4 — Implement

Implement the smallest coherent change.

Prefer:

```text
Small
Focused
Testable
Reversible
```

changes.

## Step 5 — Validate

Run appropriate:

```text
dart format
flutter analyze
flutter test
integration tests when required
```

Do not claim completion without validation.

## Step 6 — Review

After implementation, inspect:

* Architecture.
* Dependency direction.
* Unnecessary duplication.
* State ownership.
* Error handling.
* Test coverage.
* UI behavior.
* Accessibility.

## Step 7 — Report

Final response must include:

```text
Implemented
Changed
Tests
Validation
Known Limitations
Follow-up
```

---

# 30. AI Agent Must Not

The agent must NOT:

* Rewrite unrelated code.
* Introduce frameworks without justification.
* Replace existing architecture without approval.
* Create abstractions for hypothetical requirements.
* Add UseCases merely for architectural appearance.
* Put business logic into Widgets.
* Put API calls into Widgets.
* Introduce global mutable state.
* Introduce arbitrary singletons.
* Duplicate existing functionality.
* Ignore failing tests.
* Disable lint rules to make code pass.
* Suppress errors without justification.
* Modify generated files manually.
* Add dependencies without explaining why.
* Perform broad refactoring during a feature task.

---

# 31. Dependency Rules

Every dependency must have a reason.

Before adding a package, evaluate:

```text
Problem
Alternatives
Maintenance
Popularity / Ecosystem
License
Performance
Bundle Impact
Platform Compatibility
Testing
Long-term Risk
```

Prefer Flutter/Dart standard capabilities when sufficient.

Prefer fewer dependencies over more dependencies.

Do not introduce a package simply because it saves a few lines of code.

---

# 32. Architecture Change Rules

A change is considered architectural when it affects:

* Layer boundaries.
* Feature boundaries.
* Dependency direction.
* State ownership.
* Navigation architecture.
* Persistence strategy.
* Networking architecture.
* Authentication.
* Design System.
* Core infrastructure.
* Public APIs.
* Major third-party dependencies.

Architectural changes require an ADR.

---

# 33. ADR Requirements

Store Architecture Decision Records under:

```text
docs/adr/
```

Naming:

```text
0001-decision-name.md
0002-decision-name.md
0003-decision-name.md
```

Each ADR should contain:

```text
# Decision

## Context

## Problem

## Options Considered

## Decision

## Consequences

## Revisit Conditions
```

Do not create ADRs for trivial implementation details.

---

# 34. Product Evolution

The architecture must support continuous product evolution.

When adding functionality, ask:

1. Is this a new concept?
2. Is this an extension of an existing concept?
3. Does it belong to an existing Feature?
4. Does it require a new Feature?
5. Does it introduce a new state?
6. Does it change an existing state machine?
7. Does it change the source of truth?
8. Does it require a new repository?
9. Does it require a domain layer?
10. Does it change the Design System?

Prefer extending stable concepts over duplicating concepts.

---

# 35. Avoid Premature Generalization

Do not create:

```text
BaseViewModel
BaseRepository
BaseService
BaseScreen
BaseWidget
BaseUseCase
```

unless there is a demonstrated shared behavior that justifies them.

Do not create generic abstractions merely because two things currently look similar.

Three similar implementations are sometimes better than one premature abstraction.

Abstractions should emerge from stable patterns.

---

# 36. Feature Boundaries

A Feature should have:

* A clear business purpose.
* A clear ownership boundary.
* Explicit dependencies.
* A small public surface.

Avoid direct access to another Feature's internal implementation.

Prefer:

```text
Feature A
   ↓
Public Contract
   ↓
Feature B
```

over:

```text
Feature A
   ↓
Feature B internal files
```

---

# 37. Shared Code

Shared code belongs in `core/` or `shared/` only when it is genuinely cross-feature.

Do not move code into shared merely to make a directory look organized.

A component becomes shared when:

* Multiple Features use it.
* Its behavior is stable.
* Its ownership is not specific to one Feature.

Avoid creating:

```text
shared/utils/
```

as a dumping ground.

Prefer semantic organization.

---

# 38. UI Component Rules

Components should be:

* Small.
* Focused.
* Reusable when appropriate.
* Visually consistent.
* Accessible.
* Testable.

Avoid giant Widgets containing:

* Data loading.
* Business logic.
* Navigation.
* API calls.
* Multiple unrelated UI responsibilities.

A screen should compose components rather than implement everything itself.

---

# 39. Performance

Performance must be measured, not guessed.

Pay attention to:

* Build cost.
* Widget rebuilds.
* Large lists.
* Image loading.
* Memory.
* Animation frame rate.
* Startup time.
* Network latency.
* Local database operations.

Do not prematurely optimize.

When performance becomes a problem:

1. Measure.
2. Identify the bottleneck.
3. Change the smallest necessary area.
4. Measure again.

Use Flutter DevTools when investigating performance issues.

---

# 40. High-Quality Mobile UX

A feature must not be considered complete solely because its functional path works.

Evaluate:

```text
First use
Loading
Success
Failure
Empty
Offline
Retry
Undo
Keyboard
Gesture
Animation
Accessibility
Platform behavior
```

The goal is:

> The application should feel like a coherent mobile product, not a web application placed inside a mobile shell.

---

# 41. Product Interaction Principle

The application should model:

```text
User Action
    ↓
Interaction Feedback
    ↓
State Transition
    ↓
Data Update
    ↓
Synchronization
    ↓
Next Available Action
```

Avoid:

```text
Tap
 ↓
Network Request
 ↓
Wait
 ↓
Refresh Entire Screen
```

when a more responsive interaction is safe.

---

# 42. AI Feature Rules

AI functionality must be isolated from core product logic.

Prefer:

```text
Feature
 ↓
ViewModel
 ↓
AI Repository
 ↓
AI Service / Backend Gateway
```

Do not couple Widgets directly to model providers.

The client should not hard-code provider-specific business behavior.

AI output must be treated as untrusted external data.

Validate:

* Schema.
* Required fields.
* Length.
* Enum values.
* Permissions.
* Safety constraints.

Do not assume an LLM response is correct merely because it is syntactically valid.

---

# 43. Security and Privacy

This product handles children's growth-related information.

Treat child-related information as sensitive product data.

Never expose sensitive data unnecessarily.

Never store credentials in source code.

Never commit:

```text
API keys
Secrets
Tokens
Private certificates
Production credentials
```

Use environment/configuration mechanisms appropriate to the deployment environment.

The application should follow least-privilege principles.

> 🟢 **avmc 对齐**：本项目的鉴权由后端统一管理（`backend-service/pkg/auth`：JWT/OIDC 本地认证 + Casbin 鉴权 + Redis 会话），客户端**不存储**凭证、不重复实现认证逻辑。详细使用见 `../../../../docs/services/mobile-desktop/SERVICE.md` §五「网络层」与 avmc 根仓库 `AGENTS.md` §「技术栈」。

---

# 44. Generated Code

Generated code must be clearly distinguished from manually maintained code.

Do not manually edit generated files unless the generator explicitly requires it.

After modifying source annotations/configuration:

```text
Run generator
 ↓
Format
 ↓
Analyze
 ↓
Test
```

---

# 45. Documentation as Architecture

Important knowledge must not exist only in:

* AI conversations.
* Developer memory.
* Pull request comments.
* Temporary prompts.

Important decisions must be persisted in:

```text
docs/
AGENTS.md
ARCHITECTURE.md
ADR
```

Documentation should explain:

> Why the system is designed this way.

not merely:

> What files exist.

---

# 46. Git and Commit Rules

Use small, coherent commits.

Prefer Conventional Commits:

```text
feat:
fix:
refactor:
test:
docs:
chore:
perf:
build:
ci:
```

A commit should ideally represent one coherent change.

Avoid mixing:

```text
Feature implementation
+
Large refactoring
+
Formatting entire project
```

in one commit.

---

# 47. Pull Request Principles

Every meaningful PR should explain:

```text
Problem
Solution
Architecture Impact
Testing
UX Impact
Known Limitations
```

Large architectural changes require explicit review.

---

# 48. Continuous Architecture Review

The project must periodically review:

* Dependency graph.
* Feature boundaries.
* State ownership.
* Repository responsibilities.
* Shared code.
* Design System consistency.
* Test health.
* Technical debt.
* Performance.
* AI Agent generated code quality.

Architecture should evolve based on real evidence.

Do not preserve an abstraction merely because it existed before.

Do not rewrite stable architecture merely because a newer pattern is fashionable.

---

# 49. Decision Hierarchy

When making engineering decisions, prioritize:

```text
1. User value
2. Product correctness
3. Data correctness
4. Security and privacy
5. Architectural integrity
6. Testability
7. Maintainability
8. Performance
9. Developer convenience
10. Implementation speed
```

Speed is important, but should not permanently damage the system.

---

# 50. Final Principle

The purpose of this architecture is not to produce more files.

The purpose is to create a system that can evolve safely.

The project should continuously move toward:

```text
Simple
     ↓
Understandable
     ↓
Testable
     ↓
Composable
     ↓
Extensible
     ↓
Evolvable
```

The Coding Agent is an engineering collaborator, not the owner of architectural decisions.

The human product and architecture owner remains responsible for:

* Product direction.
* Product boundaries.
* Architectural decisions.
* Trade-offs.
* Quality standards.

The Coding Agent is responsible for:

* Understanding the existing system.
* Following established rules.
* Implementing focused changes.
* Writing tests.
* Running validation.
* Identifying risks.
* Updating documentation when necessary.

The ultimate objective is:

> **Use AI to increase the speed and breadth of software development without sacrificing architectural clarity, product quality, or long-term evolvability.**
