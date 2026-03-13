# Skill 编写指南

这份文档回答的是：**什么样的 Skill 才算写得好。**

它不是创建流程本身，而是 `skill-creator` 的设计规范补充。  
创建新 Skill 时，先按主流程执行；设计 `SKILL.md` 的结构、边界和质量标准时，再读取本指南。

## 一、Skill 的本质

Skill 不是一段 Prompt，而是一个文件夹。

官方定义：

> Agent Skills are folders of instructions, scripts, and resources.

最小结构：

```text
skill-name/
└── SKILL.md
```

完整结构：

```text
skill-name/
├── SKILL.md
├── references/
├── scripts/
├── examples/
└── assets/
```

## 二、SKILL.md 标准格式

### 2.1 YAML Frontmatter

```yaml
---
name: skill-name
description: >
  This skill should be used when [具体场景].
  TRIGGER when: [触发条件].
  DO NOT TRIGGER when: [排除条件].
allowed-tools:
  - Bash
  - Read
  - Write
---
```

关键点：

- `name` 必须和目录名一致，使用小写加连字符
- `description` 最关键，它决定 Skill 何时触发
- 用第三人称写法：
  - 推荐：`This skill should be used when...`
  - 不推荐：`Use this skill when...`
- 同时写清“做什么”和“什么时候用”
- 最好明确排除条件：`DO NOT TRIGGER when`

### 2.2 Markdown Body

主体没有硬性模板，但优秀 Skill 通常遵循一套稳定骨架。

## 三、优秀 SKILL.md 的六大组成部分

### 1. Overview

用 1 到 3 句话说清楚：

- 这个 Skill 解决什么问题
- 核心做法是什么

示例：

```markdown
## Overview

[这个 Skill 解决什么问题，核心做法是什么，1-3 句话]
```

### 2. Core Rules

写出不可违反的铁律。

示例：

```markdown
## Core Rules

- ALWAYS read the full diff before making any judgment
- NEVER approve changes you haven't fully understood
- NEVER skip verification to save time
```

建议：

- 用 `ALWAYS / NEVER` 明确边界
- 先写最容易被偷懒跳过的关键动作

### 3. When to Use / When NOT to Use

定义适用边界，防止误触发。

示例：

```markdown
## When to Use

- 收到 MR/PR Review 请求
- 用户要求检查代码质量

## When NOT to Use

- 正在编写新功能
- 调试问题
```

### 4. 执行流程

常见有三种写法：

#### 模式 A：阶段驱动型

适合复杂分析任务。

```markdown
## Phase 1: Reproduce & Observe
- [具体步骤]

## Phase 2: Hypothesize
- [具体步骤]

## Phase 3: Test & Verify
- [具体步骤]
```

#### 模式 B：步骤驱动型

适合操作流程。

```markdown
## Step 1: Pre-check
- [检查什么]

## Step 2: Execute
- [做什么]

## Step 3: Verify
- [验证什么]
```

#### 模式 C：输入-处理-输出型

适合文档生成类 Skill。

```markdown
## Input
- [需要读取什么]

## Process
- [按什么逻辑处理]

## Output
- [输出什么格式到哪里]
```

### 5. 防御性设计

这是区分“普通 Skill”和“优秀 Skill”的关键。

#### Red Flags

```markdown
## Red Flags

- 改动涉及 10+ 文件但没有明确原因，先确认再继续
- 没有测试的新逻辑，标记为阻塞问题
```

#### Common Mistakes

```markdown
## Common Mistakes

| 错误 | 正确做法 |
|------|---------|
| 只看 diff 不看上下文 | 必须理解改动所在函数的完整逻辑 |
| 跳过测试验证 | 每个修复都要验证 |
```

#### Common Rationalizations

这一类表格非常适合约束模型偷懒。

```markdown
## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "I'm pretty sure it's X" | Pretty sure != verified. Test it. |
| "The fix is obvious" | Obvious fixes often mask deeper issues |
| "It worked before" | Past success doesn't guarantee current correctness |
```

### 6. Integration

说明它和其他 Skill、知识库或后续步骤的关系。

```markdown
## Integration

- **Requires**: 某前置 Skill
- **Pairs with**: 某知识库或某 Skill
- **Next step**: 完成后建议做什么
```

## 四、三层信息披露

这是最重要的架构决策之一。

| 层级 | 位置 | 加载时机 | 建议 |
|------|------|----------|------|
| 第一层 | frontmatter | 始终在上下文中 | < 100 词 |
| 第二层 | SKILL.md body | Skill 触发时加载 | < 5000 词 |
| 第三层 | references / scripts / assets | 按需读取 | 尽量外置详细内容 |

核心原则：

- `SKILL.md` 只放流程指令
- 详细资料放 `references/`
- 模板和示例不要堆进主文件

错误做法：

```text
req-analyze.md
```

一个大文件同时塞流程、模板、示例、技巧、检查清单。

正确做法：

```text
req-analyze/
├── SKILL.md
├── references/
│   ├── output-template.md
│   ├── exploration-tips.md
│   └── quality-checklist.md
└── examples/
    └── sample-analysis.md
```

## 五、Skill 编写检查清单

### Frontmatter

- `name` 是小写加连字符，和目录名一致
- `description` 同时说清“做什么”和“何时触发”
- `description` 包含 `DO NOT TRIGGER` 排除条件

### Body 结构

- 有 `Overview`
- 有 `Core Rules`
- 有 `When to Use / When NOT to Use`
- 有明确执行流程
- 有防御性设计内容
- 有 `Integration`

### 架构

- `SKILL.md` 不宜过长，理想控制在 300 行左右
- 详细规范拆到 `references/`
- 不要在 `SKILL.md` 和 `references/` 重复同一信息

### 质量

- 最好有变更记录
- 至少在真实任务中试用过一次
- 根据试用反馈做过迭代

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
- ALWAYS check against team coding standards
- NEVER approve changes you haven't fully understood
- Focus on correctness and maintainability, not style preferences

## When to Use

- 收到 MR/PR Review 请求
- 用户要求检查代码质量
- 代码提交前的自检

## When NOT to Use

- 正在编写新功能
- 调试问题

## Process

### Step 1: Context Gathering
- Read the MR description and commit messages
- Read `references/review-checklist.md`
- Understand the scope of changes

### Step 2: Structural Review
- Check file organization and naming
- Check for unintended changes
- Verify test coverage for new logic

### Step 3: Logic Review
- Trace the execution path through changed code
- Identify edge cases and error handling gaps
- Check for performance implications

### Step 4: Output
- Generate review report using `references/review-template.md`
- Output to `engineering/review-reports/YYYY-MM-DD-[title].md`

## Red Flags

- Changes touching 10+ files without clear reason
- No tests for new logic
- Changes to shared utilities without checking downstream consumers
- Sensitive data in diff

## Common Mistakes

| Mistake | Correct Approach |
|---------|------------------|
| Only reading the diff without context | Read the full function/class the change lives in |
| Nitpicking style over substance | Focus on bugs, edge cases, and maintainability |
| Approving because the author is senior | Every change gets the same level of review |

## Integration

- **Pairs with**: coding-standards knowledge base
- **Next step**: approve/request changes, then suggest `git commit`
```

## 七、实战建议

- 先让 AI 起草 Skill，不必从空白开始
- 先保证结构正确，再追求表达精炼
- 先跑真实任务，再根据使用反馈迭代
- 对高频失误场景，优先补 `Red Flags` 和 `Common Rationalizations`
