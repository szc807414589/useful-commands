---
name: server-servyou169
description: "servyou169 内网服务器（10.199.157.169）的上下文和操作指南。内网环境，需 VPN 连接。使用 id_ed25519 密钥认证。当提到 servyou169、内网服务器 169 时使用。"
---

# server-servyou169

servyou169 内网服务器的上下文知识库。提供连接信息和服务器特定上下文。

## SSH 连接

```
Host servyou169
    HostName 10.199.157.169
    User root
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

SSH 命令: `ssh servyou169`

**前提**: 需要先连接 VPN 才能 SSH。

## 服务器概况

- 用途: 内网服务器
- 网络: 内网 IP，需要 VPN 才能访问
- 认证: id_ed25519 密钥

## 参考文档索引

| 文件 | 内容 |
|------|------|
| `references/server-context.md` | SSH 信息、服务器概况、VPN 注意事项 |

## 关联 skill

- **server-ops-safe**: 对 servyou169 执行安全排障时，先加载本 skill 获取上下文，再使用 server-ops-safe 的诊断流程
- **server-deploy**: 在 servyou169 上部署服务时，先加载本 skill 了解现有布局，再使用 server-deploy 的部署流程
