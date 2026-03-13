# Governance

这个目录放中心 skill 仓库的治理元数据。

## skills-registry.csv

`skills-registry.csv` 是当前唯一的状态登记表，字段如下：

- `skill`：原子 skill 名称，必须和 `skills/<name>/` 一致
- `status`：治理状态，当前只允许以下三种
  - `team-shared`：团队默认可复用，允许进入标准同步集合
  - `personal-only`：强依赖个人环境、个人账号、个人服务器或个人偏好
  - `experimental`：尚未沉淀稳定工作流，保留试验和观察空间
- `source`：当前事实来源，便于后续回溯
- `note`：补充说明，解释为什么这么标

## 建议治理规则

1. 新增 skill 时，必须同步补 `skills-registry.csv`
2. `plugin` 负责“按职能分组”，现在由 `plugins/<name>/` 下的软链表达；`status` 负责“按治理状态分层”
3. 要给团队大面积开放之前，先从 `experimental` 升级到 `team-shared`
4. 任何带具体机器、账号、内网、服务器指向的 skill，默认先标 `personal-only`
5. 已归档或不建议继续扩散的 skill，不要直接放 `team-shared`
