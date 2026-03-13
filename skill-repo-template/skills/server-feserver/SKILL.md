---
name: server-feserver
description: "feserver 前端内网服务器（10.199.157.75）的上下文和操作指南。内网环境需 VPN，用户为 afe（非 root），部分操作需 sudo。当提到 feserver、前端服务器、75 服务器时使用。"
---

# server-feserver

feserver 前端内网服务器的上下文知识库。提供连接信息和服务器特定上下文。

## SSH 连接

```
Host feserver
    HostName 10.199.157.75
    User afe
    Port 22
```

SSH 命令: `ssh feserver`

**前提**: 需要先连接 VPN 才能 SSH。

## 服务器概况

- 用途: 前端服务器
- 网络: 内网 IP，需要 VPN 才能访问
- 用户: afe（非 root），部分操作需 sudo

## 参考文档索引

| 文件 | 内容 |
|------|------|
| `references/server-context.md` | SSH 信息、服务器概况、用户权限说明、VPN 注意事项 |

## 关联 skill

- **server-ops-safe**: 对 feserver 执行安全排障时，先加载本 skill 获取上下文，再使用 server-ops-safe 的诊断流程
- **server-deploy**: 在 feserver 上部署服务时，先加载本 skill 了解现有布局，再使用 server-deploy 的部署流程
