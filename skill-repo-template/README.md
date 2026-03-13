# Central Skill Repo Template

这个模板仓库用于把你的 skill 作为单一事实源统一维护，然后手动同步到 Codex、Claude 和 Cursor。

## 设计原则

- `skills/` 是唯一事实源，每个 skill 一个目录，保持原子化。
- `plugins/` 只做职能分组，不复制 skill 内容。
- `scripts/` 提供三端同步脚本，默认增量同步，不做危险清理。

## 推荐结构

```text
skill-repo/
├── README.md
├── skills/
│   ├── brainstorm/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   ├── scripts/
│   │   └── assets/
│   ├── req-analyze/
│   └── ...
├── team/
│   └── skills/
│       └── brainstorm -> ../../skills/brainstorm
├── governance/
│   ├── README.md
│   └── skills-registry.csv
├── plugins/
│   ├── product/
│   │   └── brainstorm -> ../../skills/brainstorm
│   ├── design/
│   │   └── design -> ../../skills/design
│   ├── engineering/
│   │   └── review -> ../../skills/review
│   └── general/
│       └── doc -> ../../skills/doc
└── scripts/
    ├── bootstrap-repo.sh
    ├── audit-sync.sh
    ├── check-team-links.sh
    ├── publish-common.sh
    ├── publish-team.sh
    ├── publish-personal.sh
    ├── sync-common.sh
    ├── sync-codex.sh
    ├── sync-claude.sh
    └── sync-cursor.sh
```

## 为什么这样设计

- KISS：只维护一份 skill，本体不分叉。
- DRY：plugin 通过 `skills.list` 引用 skill 名称，不复制目录。
- YAGNI：先解决同步和分组，不提前做复杂插件编排。
- SOLID：`sync-common.sh` 负责共用逻辑，三个同步脚本只负责目标差异。

## Plugin 约定

- `product`：产品分析、PRD、方案收敛
- `design`：交互、视觉、品牌、设计资产
- `engineering`：研发、排障、评审、部署、测试
- `general`：跨职能通用能力

`plugins/<name>/` 目录本身就是集合，目录下每个软链都指向 `skills/<name>`。

## Team 视图

`team/skills/` 是团队共享 skill 的软链视图。  
它通常对应 `team-shared`，但允许你做额外人工裁剪，不强制和状态表一一绑定。

如果你想检查它和 `team-shared` 是否一致，可以运行：

```bash
./scripts/check-team-links.sh
./scripts/check-team-links.sh --verbose
```

## 状态治理

`governance/skills-registry.csv` 记录每个原子 skill 的治理状态：

- `team-shared`：团队默认可复用
- `personal-only`：仅个人环境或个人资产绑定
- `experimental`：实验中，先观察再决定是否推广

建议把它作为后续治理入口，而不是把状态写死在软链目录名里。

## 同步方式

### 同步全部 skill

```bash
./scripts/sync-codex.sh
./scripts/sync-claude.sh
./scripts/sync-cursor.sh
```

### 只同步某个 plugin

```bash
./scripts/sync-codex.sh --plugin engineering
./scripts/sync-cursor.sh --plugin product --plugin design
```

### 只同步指定 skill

```bash
./scripts/sync-claude.sh --skill req-analyze --skill create-plan
```

### 按状态同步

```bash
./scripts/sync-codex.sh --status team-shared
./scripts/sync-cursor.sh --status team-shared --status experimental
```

### 预览同步结果

```bash
./scripts/sync-codex.sh --dry-run
```

## 对账方式

### 检查三端是否漂移

```bash
./scripts/audit-sync.sh
```

### 只检查某个平台

```bash
./scripts/audit-sync.sh --platform codex
./scripts/audit-sync.sh --platform cursor --target "/path/to/project/.cursor/skills"
```

### 只检查某个 plugin

```bash
./scripts/audit-sync.sh --plugin engineering
```

### 按状态对账

```bash
./scripts/audit-sync.sh --status team-shared
./scripts/audit-sync.sh --platform claude --status personal-only
```

### 输出详细差异

```bash
./scripts/audit-sync.sh --platform claude --verbose
```

### 显式清理目标中的旧 skill

```bash
./scripts/sync-codex.sh --clean
```

`--clean` 会删除目标目录里不在本次选择集合中的 skill，只建议你确认后手动执行。

## 发布方式

母仓库保留全部 skill。需要导出团队版或个人版仓库时，使用下面两个脚本。

### 导出团队版仓库

```bash
./scripts/publish-team.sh --target "/path/to/team-skills"
```

默认只导出 `team-shared`。

### 导出个人版仓库

```bash
./scripts/publish-personal.sh --target "/path/to/personal-skills"
```

默认导出 `personal-only + experimental`。

### 预览发布结果

```bash
./scripts/publish-team.sh --target "/path/to/team-skills" --dry-run
```

### 按 plugin 或状态缩小发布范围

```bash
./scripts/publish-team.sh --target "/path/to/team-skills" --plugin engineering
./scripts/publish-personal.sh --target "/path/to/personal-skills" --status experimental
```

## Cursor 目标路径建议

- 默认目标：`~/.cursor/skills`
- 如果你更偏向项目级隔离，可以显式指定：

```bash
./scripts/sync-cursor.sh --target "/path/to/project/.cursor/skills"
```

## 初始化一个新仓库

```bash
./scripts/bootstrap-repo.sh "/path/to/my-skill-repo"
```

这个脚本只创建骨架和示例清单，不会覆盖已有 skill 内容。
