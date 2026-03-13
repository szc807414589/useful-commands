# Skill 仓库使用说明

## 目录约定

- `skills/`：原子 skill 本体
- `team/skills/`：团队共享视图，软链到 `skills/`
- `plugins/*/`：按职能分组的软链视图
- `governance/skills-registry.csv`：状态表

## 日常维护

### 1. 新增或修改 skill

直接维护：

```bash
skills/<skill-name>/
```

### 2. 调整团队共享

维护软链：

```bash
team/skills/<skill-name> -> ../../skills/<skill-name>
```

### 3. 调整插件分类

维护软链：

```bash
plugins/<plugin>/<skill-name> -> ../../skills/<skill-name>
```

### 4. 更新状态

编辑：

```bash
governance/skills-registry.csv
```

状态值：

- `team-shared`
- `personal-only`
- `experimental`

## 校验

### 检查 team 视图是否和 `team-shared` 一致

```bash
./scripts/check-team-links.sh
```

### 检查三端是否漂移

```bash
./scripts/audit-sync.sh
./scripts/audit-sync.sh --platform codex
./scripts/audit-sync.sh --status team-shared
```

## 同步到本机

### 同步全部

```bash
./scripts/sync-codex.sh
./scripts/sync-claude.sh
./scripts/sync-cursor.sh
```

### 按状态同步

```bash
./scripts/sync-codex.sh --status team-shared
./scripts/sync-cursor.sh --status experimental
```

### 按插件同步

```bash
./scripts/sync-codex.sh --plugin engineering
```

## 发布

### 导出团队版仓库

```bash
./scripts/publish-team.sh --target "/path/to/team-skills"
```

### 导出个人版仓库

```bash
./scripts/publish-personal.sh --target "/path/to/personal-skills"
```

### 预览

```bash
./scripts/publish-team.sh --target "/path/to/team-skills" --dry-run
```

## 推荐流程

1. 改 `skills/`
2. 调整 `team/skills/` 和 `plugins/*/`
3. 更新 `skills-registry.csv`
4. 运行 `./scripts/check-team-links.sh`
5. 运行 `./scripts/audit-sync.sh --status team-shared`
6. 再执行同步或发布
