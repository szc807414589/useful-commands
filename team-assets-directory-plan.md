# 团队级 Skill + 知识库目录方案

这件事如果只讲一句话，其实就是：

- `Skill` 负责“它会怎么做”
- `知识库` 负责“它知道什么”

团队真正需要维护的，不是零散 Prompt，也不是一堆难以复用的资料，而是一套**可以在 Cursor / Claude 中持续复用、持续打磨的共同资产**。

---

## 一、整体结构

```text
team-skills/                           ← 它会怎么做：能力资产
team-kb/                               ← 它知道什么：知识资产
    │
    ├── Skill 读取知识执行            ← 消费知识
    ├── 执行结果回流知识库            ← 产出知识
    └── 团队评审后持续迭代            ← 形成飞轮

Cursor / Claude                        ← 团队成员与下游消费者的统一入口
```

这里最重要的是三个判断：

1. `Skill` 不是一次性 Prompt，而是可装载、可共享、可维护的能力包
2. `知识库` 不是资料归档，而是让后续判断和执行更准的背景认知
3. 统一维护的是 Git 仓库，按需加载的是 Cursor / Claude

---

## 二、`team-skills` 怎么组织

`team-skills` 最好是一个单独仓库，集中维护，不跟着业务项目分支四散维护。

推荐结构：

```text
team-skills/
├── README.md                          ← 仓库说明 + 使用入口
├── CONTRIBUTING.md                    ← 如何新增、修改 Skill
├── CHANGELOG.md                       ← 重要变化记录
├── plugins/                           ← 按能力域分组，而不是按项目分
│   ├── dev-workflow/                  ← 研发工作流
│   │   ├── .cursor-plugin/            ← Cursor 插件元数据
│   │   │   └── plugin.json
│   │   ├── .claude-plugin/            ← Claude / Claude Code 元数据
│   │   │   └── plugin.json
│   │   └── skills/
│   │       ├── req-analyze/
│   │       │   ├── SKILL.md           ← 核心说明：触发条件、流程、输出格式
│   │       │   ├── references/        ← 参考资料：规范、清单、案例
│   │       │   └── examples/          ← few-shot 示例
│   │       ├── create-plan/
│   │       ├── code-by-plan/
│   │       ├── mr-review/
│   │       └── bug-fix/
│   ├── product/                       ← 产品工作流
│   │   ├── .cursor-plugin/
│   │   ├── .claude-plugin/
│   │   └── skills/
│   │       ├── brainstorm/
│   │       ├── prd-writer/
│   │       ├── design/
│   │       └── product-qa/
│   └── team-common/                   ← 团队通用能力
│       ├── .cursor-plugin/
│       ├── .claude-plugin/
│       └── skills/
│           ├── weekly-report/
│           ├── meeting-notes/
│           ├── changelog/
│           └── doc-writer/
├── templates/                         ← 新建 Skill 模板
│   └── skill-template/
│       ├── SKILL.md
│       ├── references/
│       └── examples/
└── scripts/
    ├── setup.sh                       ← 一键安装到 Cursor / Claude
    ├── create-skill.sh                ← 快速创建 Skill 脚手架
    └── validate.sh                    ← 校验 Skill 结构完整性
```

### 为什么这样分

按 `Plugin -> Skill` 组织，比按项目分 Skill 更稳。

比如：

- `dev-workflow` 下面放研发能力
- `product` 下面放产品能力
- `team-common` 下面放团队通用能力

这样一个人封装的东西，天然更容易变成团队资产，而不是某个项目里的私有脚本。

---

## 三、单个 Skill 里面放什么

推荐最小结构：

```text
skill-name/
├── SKILL.md                           ← 目标、触发条件、执行流程、输出格式
├── references/                        ← 这个 Skill 依赖的局部知识
├── examples/                          ← 输入输出示例
├── evals/                             ← 最小评估集，防止退化
├── scripts/                           ← 可选辅助脚本
├── CHANGELOG.md                       ← 版本演进记录
└── OWNERS                             ← 维护人和评审人
```

这里最难的不是建目录，而是把 `SKILL.md` 写清楚。  
一个成熟 Skill，至少要把下面几件事说清楚：

1. 这是帮谁做什么
2. 什么情况下触发
3. 它读什么输入
4. 它按什么步骤执行
5. 它输出什么结果
6. 它依赖哪些知识
7. 什么叫做好，什么情况下需要人工介入

换句话说，Skill 的核心不是文案，而是**流程被写清楚**。

---

## 四、`team-kb` 怎么组织

如果说 `team-skills` 管的是“能力”，  
那 `team-kb` 管的就是“背景认知”和“判断依据”。

推荐结构：

```text
team-kb/
├── README.md                          ← 总索引：各目录说明 + 使用入口
├── CONTRIBUTING.md                    ← 如何新增、修订知识
├── CHANGELOG.md                       ← 重要变化记录
├── governance/
│   ├── doc-template.md                ← 文档模板
│   ├── metadata-spec.md               ← 元数据规范
│   ├── review-process.md              ← 团队评审方式
│   ├── archival-rules.md              ← 归档规则
│   └── ownership.md                   ← owner 机制
├── product/                           ← 产品知识
│   ├── README.md                      ← 目录边界说明
│   ├── user-guides/                   ← 产品说明书
│   ├── prd/                           ← PRD 归档
│   ├── design-specs/                  ← 设计规范
│   └── api-docs/                      ← API 文档
├── engineering/                       ← 研发知识
│   ├── README.md
│   ├── architecture/                  ← 架构决策记录
│   ├── coding-standards/              ← 编码规范
│   ├── troubleshooting/               ← 踩坑记录
│   ├── review-reports/                ← Review 报告
│   └── changelogs/                    ← 变更记录
├── shared/                            ← 团队共享知识
│   ├── README.md
│   ├── meeting-notes/                 ← 会议纪要
│   ├── retrospectives/                ← 复盘
│   ├── onboarding/                    ← 新人资料
│   └── industry/                      ← 行业洞察
├── protocols/                         ← 输入输出协议、流程契约
├── playbooks/                         ← 行动手册、操作手册
├── cases/                             ← 代表性案例
└── patterns/                          ← 从案例中提炼出的模式
```

### 为什么知识库要这样拆

知识库最容易出的问题，不是“不够多”，而是“太乱”。

更适合保留下来的，一般就是这几类：

- `protocols/`：协议、字段定义、输入输出契约
- `playbooks/`：怎么做的行动手册
- `cases/`：经过确认、可复用的代表性案例
- `patterns/`：从多个案例里抽出来的模式

再加上业务域本身的知识目录：

- `product/`
- `engineering/`
- `shared/`

这样 Skill 读知识的时候，路径天然就会更清楚。

---

## 五、知识从哪里来

团队知识库的内容，通常有三个来源：

### 1. Skill 执行产出

比如：

- Review 报告
- 变更记录
- 会议纪要
- 说明书

这些内容最适合按固定结构落盘。

### 2. 人工编写

比如：

- 架构决策
- 编码规范
- 踩坑记录
- 纠错补充

这些内容不是 AI 自动生成的，但往往最能拉高团队判断质量。

### 3. 项目文档就近维护，再接回团队知识库

知识库不一定是原始文档的生产位置，更像统一读取入口。

比较实用的方式是：

```text
项目仓库 A/.ai-configs/prd/        ← 原位置维护
项目仓库 B/.ai-configs/prd/        ← 原位置维护
项目仓库 A/docs/                   ← 原位置维护
    │
    └── 通过软链或索引接入 team-kb  ← 团队统一读取入口
```

这样既不破坏项目原有文档习惯，也能让团队知识库成为统一入口。

---

## 六、Skill 和知识库怎么连起来

真正的关键不是把两个仓库都建出来，而是让它们形成关系。

每个 Skill 都应该声明自己：

- **读什么**
- **写什么**

例如：

| Skill | 读取 | 写入 |
|------|------|------|
| `product-qa` | `product/user-guides/` | `shared/qa-logs/` |
| `prd-writer` | `product/prd/` | `product/prd/` |
| `mr-review` | `engineering/coding-standards/` | `engineering/review-reports/` |
| `bug-fix` | `engineering/troubleshooting/` | `engineering/troubleshooting/` |
| `meeting-notes` | `shared/meeting-notes/` | `shared/meeting-notes/` |
| `weekly-report` | `个人 memory + git log` | `shared/weekly-reports/` |

这一步非常关键。  
只有当 Skill 明确知道自己读什么、写什么，团队知识才会真正形成飞轮。

一句话说就是：

**Skill 消费知识，也生产知识。**

---

## 七、团队平时怎么维护，才不会散

比较顺手的节奏通常是：

### 新增 Skill

```text
识别高频场景                 ← 每周至少出现 2 次，且流程稳定
-> AI 起草 SKILL.md          ← 先把目标、流程、输入输出写清楚
-> 真实任务试用              ← 在实际工作里打磨
-> 提 PR 修改                ← 团队 Review
-> 合并后统一分发            ← Cursor / Claude 同步更新
```

### 知识库迭代

```text
Skill 执行                    ← 产出报告、纪要、案例、结论
-> 结果落盘                   ← 写回团队知识库
-> 人工发现不准               ← 开始纠偏
   ├── 知识问题               ← 修正文档、补背景知识
   └── Skill 问题             ← 修改 SKILL.md 或 references/
-> 下次再执行更准             ← 飞轮继续加速
```

团队真正要打磨的，不是某一篇文档本身，而是：

- Skill 的执行标准
- 知识库的目录结构
- 文档应该写到哪里、按什么格式写

---

## 八、命名这件小事，其实很重要

命名不统一，后面检索、复用、评审都会变得很痛苦。

### Skill 目录命名

统一用小写短横线：

```text
bug-analysis-readonly
change-plan-generator
meeting-summary
```

不要写成：

```text
BugAnalysis
bug_analysis
我的技能
```

### 知识文档命名

直接表达用途：

```text
bug-input-protocol.md
change-plan-spec.md
frontend-cache-bug-pattern.md
review-playbook.md
```

尽量避免：

- `说明文档.md`
- `最终版.md`
- `新版说明.md`

这些名字短期省事，长期一定会变成噪音。

---

## 九、如果只做第一版，先收成这样就够了

很多时候不是做不到，而是一开始铺得太大。

### `team-skills`

```text
team-skills/
├── plugins/                           ← 先只收统一插件结构
│   ├── dev-workflow/                  ← 研发
│   ├── product/                       ← 产品
│   └── team-common/                   ← 通用
├── templates/                         ← 新建 Skill 模板
└── scripts/                           ← 安装、创建、校验脚本
```

首批 Skill 可以先只放这些：

1. `bug-analysis-readonly`
2. `meeting-summary`
3. `mr-review`

### `team-kb`

```text
team-kb/
├── protocols/                         ← 输入输出协议
├── playbooks/                         ← 行动手册
├── cases/                             ← 代表性案例
├── patterns/                          ← 常见模式
├── engineering/                       ← 研发知识
├── product/                           ← 产品知识
└── shared/                            ← 团队共享知识
```

首批知识先收这几类就够了：

1. Bug 输入协议
2. 分析输出协议
3. 评审手册
4. 典型案例
5. 常见缺陷模式

先把这些跑顺，比一开始就做一个很大的平台更重要。

---

## 十、最后一句话

团队统一维护的，不应该是一堆零散 Prompt，也不应该是一堆没人再看的文档。

更有价值的做法是：

- 把能力沉淀成 `Skills`
- 把判断沉淀成 `知识`
- 把项目和个人的真实输出，提炼后提升到团队库
- 让所有团队成员和所有下游，都在 Cursor / Claude 中复用同一套资产

当这套结构稳定下来以后，团队真正积累下来的，就不只是文档和提示词，而是一套会越来越准、越来越好用的共同能力。
