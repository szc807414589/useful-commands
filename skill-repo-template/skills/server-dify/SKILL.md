---
name: server-dify
description: "dify 服务器（118.196.83.124）的上下文和操作指南。运行 Dify AI 平台。当提到 dify 服务器、dify 平台时使用。"
---

# server-dify

dify 服务器的上下文知识库。提供连接信息和服务器特定上下文。

## SSH 连接

```
Host dify
    HostName 118.196.83.124
    User root
    Port 22
```

SSH 命令: `ssh dify`

## 服务器概况

- 用途: Dify AI 平台
- 部署方式: 通常使用 Docker Compose

## 参考文档索引

| 文件 | 内容 |
|------|------|
| `references/server-context.md` | SSH 信息、服务器概况、注意事项 |

## 关联 skill

- **server-ops-safe**: 对 dify 执行安全排障时，先加载本 skill 获取上下文，再使用 server-ops-safe 的诊断流程
- **server-deploy**: 在 dify 上部署或更新服务时，先加载本 skill 了解现有布局，再使用 server-deploy 的部署流程
