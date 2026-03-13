# 如何写一个优秀的 Skill

> 基于官方 Agent Skills 规范、社区优秀实例和实战经验，整理的 Skill 编写指南。

---

## 一、Skill 的本质

Skill 不是一段 Prompt，而是一个**文件夹**。

官方定义：**"Agent Skills are folders of instructions, scripts, and resources."**

```
最小结构：                     完整结构：

skill-name/                    skill-name/
└── SKILL.md  (唯一必需文件)    ├── SKILL.md       (核心指令)
                               ├── references/    (参考资料，按需加载)
                               ├── scripts/       (确定性脚本)
                               ├── examples/      (few-shot 示例)
                               └── assets/        (模板、图片等)
```

---

## 二、SKILL.md 标准格式

### 2.1 YAML Frontmatter（必需）

```yaml
---
name: skill-name          # 必填，小写+连字符，和目录名一致
description: >            # 必填，决定 Skill 何时被触发
  This skill should be used when [具体场景].
  TRIGGER when: [触发条件].
  DO NOT TRIGGER when: [排除条件].
allowed-tools:            # 可选，预授权工具列表
  - Bash
  - Read
  - Write
---
```

**`description` 是最关键的字段** — 它决定了 AI 何时加载这个 Skill。

写法要点：
- 用第三人称："This skill should be used when..." 而非 "Use this skill when..."
- 同时说清**做什么**和**何时用**
- 明确标注排除条件（DO NOT TRIGGER when）

优秀 description 示例（来自社区）：

| Skill | description |
|-------|------------|
| systematic-debugging | "Use when encountering any bug or test failure, **before** proposing fixes" |
| verification-before-completion | "Use when about to claim work is complete, **before** committing" |
| dispatching-parallel-agents | "Use when facing 3+ independent failures without shared state" |

共同特征：用 **before** 标明前置关系，用具体条件而非抽象概念。

### 2.2 Markdown Body

主体没有强制格式，但优秀 Skill 都遵循一套共同骨架（见下一章）。

---

## 三、优秀 SKILL.md 的六大组成部分

### 1. Overview — 一段话说清核心

```markdown
## Overview

[这个 Skill 解决什么问题，核心做法是什么，1-3 句话]
```

### 2. Core Rules — 不可违反的铁律

```markdown
## Core Rules

- ALWAYS read the full diff before making any judgment
- NEVER approve changes you haven't fully understood
- NEVER skip verification to save time
```

用正反对比划清边界。`ALWAYS` / `NEVER` 是最有效的约束词。

### 3. When to Use / When NOT to Use — 适用边界

```markdown
## When to Use
- 收到 MR/PR Review 请求
- 用户要求检查代码质量

## When NOT to Use
- 正在编写新功能（用 code-by-plan）
- 调试问题（用 systematic-debugging）
```

防止 Skill 被错误触发，也防止 AI 在不合适的场景下强行套用。

### 4. 执行流程 — 三种常见模式

**模式 A：阶段驱动型**（适合复杂分析任务）

```markdown
## Phase 1: Reproduce & Observe
- [具体步骤]

## Phase 2: Hypothesize
- [具体步骤]

## Phase 3: Test & Verify
- [具体步骤]
```

**模式 B：步骤驱动型**（适合操作流程）

```markdown
## Step 1: Pre-check
- [检查什么]

## Step 2: Execute
- [做什么]

## Step 3: Verify
- [验证什么]
```

**模式 C：输入-处理-输出型**（适合文档生成）

```markdown
## Input
- [需要读取什么]

## Process
- [按什么逻辑处理]

## Output
- [输出什么格式到哪里]
```

### 5. 防御性设计 — 区分普通和优秀的关键

```markdown
## Red Flags
- 改动涉及 10+ 文件但没有明确原因 — 先确认再继续
- 没有测试的新逻辑 — 标记为阻塞问题

## Common Mistakes
| 错误 | 正确做法 |
|------|---------|
| 只看 diff 不看上下文 | 必须理解改动所在函数的完整逻辑 |
| 跳过测试验证 | 每个修复都要验证 |
```

**最精彩的设计：Common Rationalizations 表格**

```markdown
## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "I'm pretty sure it's X" | Pretty sure != verified. Test it. |
| "The fix is obvious" | Obvious fixes often mask deeper issues |
| "It worked before" | Past success doesn't guarantee current correctness |
```

这种写法极其有效地防止 AI 走捷径跳过关键步骤。

### 6. Integration — 与其他 Skill 的关系

```markdown
## Integration

- **Requires**: systematic-debugging（前置依赖）
- **Pairs with**: coding-standards（配合使用）
- **Next step**: 完成后建议 git commit
```

---

## 四、三层信息披露 — 最重要的架构决策

| 层级 | 位置 | 加载时机 | 大小建议 |
|------|------|---------|---------|
| 第一层 | frontmatter (name + description) | 始终在上下文中 | < 100 词 |
| 第二层 | SKILL.md body | Skill 触发时加载 | < 5000 词 |
| 第三层 | references/ scripts/ assets/ | AI 按需读取 | 无限制 |

**核心原则：SKILL.md 只放流程指令，详细资料放 references/**

错误做法 — 把所有内容塞进一个文件（800+ 行）：

```
req-analyze.md        ← 850 行，包含模板、示例、技巧
```

正确做法 — 拆分为三层：

```
req-analyze/
├── SKILL.md                  ← 核心流程 200-300 行
├── references/
│   ├── output-template.md    ← 输出文档模板
│   ├── exploration-tips.md   ← 探索技巧
│   └── quality-checklist.md  ← 质量检查清单
└── examples/
    └── sample-analysis.md    ← 示例分析报告
```

为什么重要：
- SKILL.md 过长会稀释关键指令的权重
- references/ 只在 AI 需要时才读取，不浪费上下文窗口
- 模板和示例更新时不需要改动核心流程

---

## 五、Skill 编写检查清单

### Frontmatter

- [ ] name 是小写+连字符，和目录名一致
- [ ] description 同时说清"做什么"和"何时触发"
- [ ] description 包含 DO NOT TRIGGER 排除条件

### Body 结构

- [ ] 有 Overview（1-3 句话）
- [ ] 有 Core Rules（ALWAYS / NEVER 铁律）
- [ ] 有 When to Use / When NOT to Use
- [ ] 执行流程清晰（阶段/步骤/输入输出 三选一）
- [ ] 有防御性设计（Red Flags / Common Mistakes）
- [ ] 有 Integration（与其他 Skill 的关系）

### 架构

- [ ] SKILL.md body < 300 行（理想值），不超过 5000 词
- [ ] 模板、示例、详细规范拆到 references/
- [ ] 不在 SKILL.md 和 references 中重复信息

### 质量

- [ ] 有变更记录表（日期 + 变更 + 作者）
- [ ] 在真实任务中试用过至少一次
- [ ] 根据试用反馈迭代过

---

## 六、完整示例

```markdown
---
name: mr-review
description: >
  Code review skill for merge requests. This skill should be used when
  reviewing code changes, MR/PR submissions, or when asked to check code quality.
  TRIGGER when: user mentions "review", "MR", "PR", or code quality checks.
  DO NOT TRIGGER when: user is writing new code or debugging.
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
---

# MR Review

> 对代码变更进行结构化审查，输出标准化 Review 报告。

## Core Rules

- ALWAYS read the full diff before making any judgment
- ALWAYS check against team coding standards (see references/)
- NEVER approve changes you haven't fully understood
- Focus on correctness and maintainability, not style preferences

## When to Use

- 收到 MR/PR Review 请求
- 用户要求检查代码质量
- 代码提交前的自检

## When NOT to Use

- 正在编写新功能（用 code-by-plan）
- 调试问题（用 systematic-debugging）

## Process

### Step 1: Context Gathering
- Read the MR description and commit messages
- Read `references/review-checklist.md` for team standards
- Understand the scope of changes

### Step 2: Structural Review
- Check file organization and naming
- Check for unintended changes (debug code, unrelated files)
- Verify test coverage for new logic

### Step 3: Logic Review
- Trace the execution path through changed code
- Identify edge cases and error handling gaps
- Check for performance implications

### Step 4: Output
- Generate review report using `references/review-template.md`
- Output to `engineering/review-reports/YYYY-MM-DD-[title].md`
- Summarize: findings count, severity, recommendation (approve/request changes)

## Red Flags

- Changes touching 10+ files without clear reason -- ask for context first
- No tests for new logic -- flag as blocking issue
- Changes to shared utilities without checking downstream consumers
- Sensitive data (keys, tokens) in diff -- immediately flag

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Only reading the diff without context | Read the full function/class the change lives in |
| Nitpicking style over substance | Focus on bugs, edge cases, and maintainability |
| Approving because the author is senior | Every change gets the same level of review |

## Integration

- **Pairs with**: coding-standards knowledge base
- **Next step**: approve/request changes, then suggest `git commit`

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-03-10 | Initial version | team |
```

---

## 七、从现有命令迁移为 Skill 的要点

| 改进点 | 常见现状 | 目标 |
|--------|---------|------|
| 长度 | 单文件 500-800 行 | SKILL.md < 300 行，其余拆 references/ |
| 元数据 | 无 frontmatter | 加 name + description |
| 模板 | 内嵌在文件中 | 拆到 references/output-template.md |
| 重复内容 | 多个命令重复同样的前置步骤 | 抽取为共享 references 或前置 Skill |
| 防御设计 | 有的有、有的没有 | 统一加 Red Flags + Common Mistakes |
| 版本管理 | 无变更记录 | 末尾加 Changelog 表 |
