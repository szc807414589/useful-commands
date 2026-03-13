# 团队级 Skill + 知识库管理方案

> 目标：建立一套团队共享的 Skill 能力资产和知识库体系，通过 Cursor 和 Claude Code 使用，可持续迭代。

---

## 一、核心思路

```
团队 Skill 仓库 (git)              团队知识库 (git)
  "它会怎么做"                        "它知道什么"
       │                                  │
       │  ┌───────────────────────────┐   │
       └──│  Skill 读取知识 → 执行      │───┘
          │  执行产出 → 写回知识库       │
          └───────────────────────────┘
                      │
            ┌─────────┴─────────┐
            ▼                   ▼
       ┌─────────┐        ┌─────────┐
       │ Cursor  │        │ Claude  │
       │ Plugin  │        │  Code   │
       └─────────┘        └─────────┘
```

**三个关键判断：**

1. **Skill 是能力资产** — 不是一次性 Prompt，而是可装载、可共享、可迭代的文件夹
2. **知识库是飞轮** — Skill 越用 → 知识越准 → Skill 越强 → 复利增长
3. **统一维护、两端分发** — 一个 git 仓库是事实来源，Cursor 和 Claude Code 各自加载

---

## 二、Skill 仓库结构

```
team-skills/
├── README.md                           ← 仓库说明 + 使用指南
├── CONTRIBUTING.md                     ← 如何新增/修改 Skill
│
├── plugins/                            ← 按业务域分 Plugin
│   │
│   ├── dev-workflow/                   ← 研发工作流
│   │   ├── .cursor-plugin/             ← Cursor 插件元数据
│   │   │   └── plugin.json
│   │   ├── .claude-plugin/             ← Claude Code 插件元数据
│   │   │   └── plugin.json
│   │   └── skills/
│   │       ├── req-analyze/
│   │       │   ├── SKILL.md            ← 核心：触发条件 + 执行流程 + 输出格式
│   │       │   ├── references/         ← 参考资料：规范、checklist
│   │       │   └── examples/           ← few-shot 示例
│   │       ├── create-plan/
│   │       │   ├── SKILL.md
│   │       │   └── references/
│   │       ├── code-by-plan/
│   │       │   ├── SKILL.md
│   │       │   └── references/
│   │       ├── mr-review/
│   │       │   ├── SKILL.md
│   │       │   └── references/
│   │       │       └── review-checklist.md
│   │       └── bug-fix/
│   │           └── SKILL.md
│   │
│   ├── product/                        ← 产品管理
│   │   ├── .cursor-plugin/
│   │   │   └── plugin.json
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       ├── brainstorm/
│   │       │   └── SKILL.md
│   │       ├── prd-writer/
│   │       │   ├── SKILL.md
│   │       │   └── references/
│   │       │       └── prd-template.md
│   │       ├── design/
│   │       │   └── SKILL.md
│   │       └── product-qa/             ← 产品问答（依赖知识库）
│   │           ├── SKILL.md
│   │           └── references/
│   │
│   └── team-common/                    ← 团队通用
│       ├── .cursor-plugin/
│       │   └── plugin.json
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           ├── weekly-report/
│           │   └── SKILL.md
│           ├── meeting-notes/
│           │   └── SKILL.md
│           ├── changelog/
│           │   └── SKILL.md
│           └── doc-writer/
│               ├── SKILL.md
│               └── references/
│
├── templates/                          ← 新建 Skill 用的模板
│   └── skill-template/
│       ├── SKILL.md
│       ├── references/
│       │   └── .gitkeep
│       └── examples/
│           └── .gitkeep
│
└── scripts/
    ├── setup.sh                        ← 一键安装：Cursor + Claude Code
    ├── create-skill.sh                 ← 快速创建新 Skill 脚手架
    └── validate.sh                     ← 校验 Skill 结构完整性
```

### Plugin 分类

| Plugin | Skill 列表 | 使用角色 |
|--------|-----------|---------|
| dev-workflow | req-analyze, create-plan, code-by-plan, mr-review, bug-fix | 研发 |
| product | brainstorm, prd-writer, design, product-qa | 产品 |
| team-common | weekly-report, meeting-notes, changelog, doc-writer | 全员 |

> 按需扩展。当某个领域的 Skill 积累到 3 个以上，就拆出一个新 Plugin。

---

## 三、知识库结构

```
team-knowledge/
├── README.md                           ← 总索引：各目录说明 + 维护规则
├── .obsidian/                          ← Obsidian 共享配置
│
├── product/                            ← 产品知识
│   ├── README.md                       ← 目录边界说明
│   ├── user-guides/                    ← 产品说明书（Skill 可自动生成）
│   ├── prd/                            ← PRD 归档
│   ├── design-specs/                   ← 设计规范
│   └── api-docs/                       ← API 文档
│
├── engineering/                        ← 研发知识
│   ├── README.md
│   ├── architecture/                   ← 架构决策记录 (ADR)
│   ├── coding-standards/               ← 编码规范
│   ├── troubleshooting/                ← 踩坑记录
│   ├── review-reports/                 ← Review 报告（Skill 生成）
│   └── changelogs/                     ← 变更记录（Skill 生成）
│
└── shared/                             ← 团队共享
    ├── README.md
    ├── meeting-notes/                  ← 会议纪要（Skill 生成）
    ├── retrospectives/                 ← 复盘
    ├── onboarding/                     ← 新人资料
    └── industry/                       ← 行业洞察
```

### 知识的三个来源

| 来源 | 写入方 | 例子 |
|------|-------|------|
| Skill 执行产出 | AI 自动落盘 | Review 报告、变更记录、会议纪要、说明书 |
| 人工编写 | 团队成员 | 架构决策、编码规范、踩坑记录、纠错补充 |
| 迭代文档就近维护 | 跟随项目仓库 | PRD、技术文档放在项目 `.ai-configs/` 中，软链到知识库 |

### 与项目仓库的关系

知识库不是要替代项目中的文档，而是做**聚合入口**：

```
项目仓库 A/.ai-configs/prd/     ──软链──→  team-knowledge/product/prd/project-a/
项目仓库 B/.ai-configs/prd/     ──软链──→  team-knowledge/product/prd/project-b/
项目仓库 A/docs/                ──软链──→  team-knowledge/engineering/project-a-docs/
```

文档留在原位维护，知识库负责统一索引和读取。

---

## 四、SKILL.md 标准模板

```markdown
# [Skill 名称]

> 一句话描述

## 触发条件

- 用户说 "xxx" 时触发
- 场景自动匹配条件

## 前置条件

- 需要的项目配置或文件
- 需要的知识库文档

## 执行流程

### Step 1: [步骤名]
- 做什么、读什么、判断什么

### Step 2: [步骤名]
...

## 输出

- 输出位置（文件路径规则）
- 输出格式
- 示例

## 知识库依赖

读取：
- `engineering/coding-standards/` -- 编码规范

写入：
- `engineering/review-reports/` -- Review 产出落盘

## 质量标准

- 产出判断标准
- 需要人工 review 的部分

## 变更记录

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-03-10 | 初始版本 | xx |
```

---

## 五、分发方案

### Cursor：Plugin 加载

Cursor 原生支持 Plugin 目录结构。每个 Plugin 目录包含 `.cursor-plugin/plugin.json`，Cursor 可以直接识别。

```bash
# 方式一：软链到 Cursor 插件目录
ln -s /path/to/team-skills/plugins/dev-workflow ~/.cursor/plugins/local/dev-workflow

# 方式二：在 Cursor 设置中指定 plugin 路径
```

### Claude Code：Skill 加载

Claude Code 加载 `~/.claude/skills/` 下的 SKILL.md。

```bash
# 软链每个 Skill 目录到 Claude Code skills 路径
ln -s /path/to/team-skills/plugins/dev-workflow/skills/req-analyze \
      ~/.claude/skills/team-req-analyze
```

### 一键安装脚本 setup.sh

```bash
#!/bin/bash
# 一键安装团队 Skill 到 Cursor + Claude Code
# 用法: ./scripts/setup.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_SKILLS="$HOME/.claude/skills"

echo "=== 安装团队 Skill ==="

for plugin_dir in "$REPO_ROOT/plugins"/*/; do
  plugin_name=$(basename "$plugin_dir")
  skills_dir="$plugin_dir/skills"

  [ ! -d "$skills_dir" ] && continue

  # Claude Code: 软链每个 Skill
  for skill_dir in "$skills_dir"/*/; do
    skill_name=$(basename "$skill_dir")
    target="$CLAUDE_SKILLS/team-${plugin_name}-${skill_name}"
    [ -L "$target" ] && rm "$target"
    ln -s "$skill_dir" "$target"
    echo "  [Claude] $plugin_name/$skill_name"
  done
done

echo ""
echo "=== Cursor ==="
echo "在 Cursor 中通过 --plugin-dir 加载，或手动软链到 ~/.cursor/plugins/local/"
echo ""
echo "Done. git pull 后重新运行此脚本即可更新。"
```

---

## 六、迭代流程

### 新增 Skill

```
识别高频场景（每周 >= 2 次、有固定流程）
    ↓
./scripts/create-skill.sh <plugin> <name>
    ↓
AI 起草 SKILL.md（描述目标、流程、输入输出）
    ↓
真实任务中试用 → 发现问题 → 修改
    ↓
git commit → PR → 团队 Review → 合并
    ↓
团队 git pull + setup.sh → 全员更新
```

### 知识库迭代

```
Skill 执行 → 产出自动落盘（Review 报告/会议纪要/说明书...）
    ↓
人工 Review → 发现不准？
    ├── 知识问题 → 修正知识库文档
    └── Skill 问题 → 修正 SKILL.md 或 references/
    ↓
下次 Skill 读取更准的知识 → 产出更准 → 飞轮加速
```

### 团队节奏

| 频率 | 动作 |
|------|------|
| 日常 | 用 Skill 工作，产出落盘知识库 |
| 每周 | Review 知识库 git log，讨论 Skill 改进点 |
| 每月 | 回顾 Skill 使用情况，新增/清理/迭代 |

---

## 七、从现有命令迁移

当前 `.claude-commands/` 命令 → Skill 目录映射：

| 现有命令 | 目标 Plugin | 目标 Skill |
|---------|------------|-----------|
| brainstorm.md | product | brainstorm |
| req-analyze.md | dev-workflow | req-analyze |
| prd.md + update-prd.md | product | prd-writer |
| design.md | product | design |
| create-plan.md + update-plan.md | dev-workflow | create-plan |
| code-by-plan.md | dev-workflow | code-by-plan |
| bug-fix.md | dev-workflow | bug-fix |
| review.md | dev-workflow | mr-review |

**迁移做法：**
- 每个 .md → 一个 Skill 目录（SKILL.md + references/）
- update-xxx 合并到对应 Skill（在 SKILL.md 中区分创建/更新模式）
- 命令中内嵌的模板（如 progress.md 模板）抽取到 `references/`

---

## 八、Skill 与知识库连接关系

每个 SKILL.md 声明自己**读什么、写什么**：

| Skill | 读取 | 写入 |
|-------|------|------|
| product-qa | product/user-guides/ | shared/qa-logs/ |
| prd-writer | product/prd/（历史参考） | product/prd/ |
| mr-review | engineering/coding-standards/ | engineering/review-reports/ |
| bug-fix | engineering/troubleshooting/ | engineering/troubleshooting/ |
| changelog | engineering/changelogs/ | engineering/changelogs/ |
| meeting-notes | shared/meeting-notes/（上文） | shared/meeting-notes/ |
| weekly-report | 个人 memory + git log | shared/weekly-reports/ |

这是飞轮的核心机制：**Skill 消费知识，也生产知识。**

---

## 九、快速开始

### Day 1：建仓

- [ ] 创建 `team-skills` git 仓库，按上述结构建目录
- [ ] 写 README.md + CONTRIBUTING.md
- [ ] 创建 templates/skill-template/
- [ ] 写 scripts/setup.sh 和 scripts/create-skill.sh

### Week 1：迁移核心 Skill

- [ ] 将 `.claude-commands/` 命令迁移为 SKILL.md 格式
- [ ] 按 Plugin 分类（dev-workflow / product / team-common）
- [ ] 运行 setup.sh 验证 Cursor + Claude Code 可加载

### Week 2：建知识库

- [ ] 创建 `team-knowledge` git 仓库
- [ ] 整理现有文档归入 product/ engineering/ shared/
- [ ] 配置 Obsidian 打开知识库
- [ ] 各目录写 README.md 说明边界和维护方式

### Week 3：打通飞轮

- [ ] 给核心 Skill 加上 `知识库依赖` 段（读什么、写到哪）
- [ ] 在真实工作中试用，收集问题
- [ ] 建立每周 Review 节奏
