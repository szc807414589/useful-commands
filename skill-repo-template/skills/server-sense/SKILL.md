---
name: server-sense
description: "sense 服务器（49.235.42.84）的上下文和操作指南。通用项目部署服务器（Ubuntu 24.04），运行 ai-cmo、ai-write、sense、thinky、ai-quantify 等多个项目。使用 cloudflared 隧道和 nginx 做域名路由。当提到 sense 服务器、ai-cmo、ai-write、thinky、mindmesh.site 域名时使用。"
---

# server-sense

sense 服务器的上下文知识库。提供连接信息、项目布局、端口分配、域名映射等服务器特定上下文。

## SSH 连接

```
Host sense
   HostName 49.235.42.84
   User ubuntu
   Port 22
   IdentityFile ~/.ssh/id_rsa
```

SSH 命令: `ssh sense`

## 服务器概况

- OS: Ubuntu 24.04 | CPU: 2核 | 内存: 3.6GB
- 用途: 通用项目部署（多项目共存）
- 运行时: Python 3.12.3, Node.js (PM2), Docker + Docker Compose, Git 2.43

## 项目布局

| 项目 | 位置 | 部署方式 | 端口 | 域名 |
|------|------|---------|------|------|
| ai-cmo | /opt/projects/ai-cmo | Docker | 8000, 8081 | - |
| ai-write (ziliu) | /opt/projects/ai-write | Docker | 3000 | media.geoq.help |
| sense | /opt/projects/sense | Docker Compose | 3001, 3307, 6380 | sense.mindmesh.site |
| thinky | /opt/projects/thinky | PM2 | 8001 | api.thinky.vip |
| ai-quantify | /opt/projects/ai-quantify | systemd + venv | 8002 | quant.mindmesh.site |

## 端口分配

- 已用端口: 3000, 3001, 3306, 3307, 6379, 6380, 8000, 8001, 8002, 8081
- 下一个可用端口: 8003

## 域名映射

| 域名 | 目标 | 备注 |
|------|------|------|
| sense.mindmesh.site | localhost:3001 | cloudflared |
| quant.mindmesh.site | localhost:8002 | cloudflared |
| media.geoq.help | localhost:3000 | cloudflared |
| api.thinky.vip | localhost:8001 | cloudflared |
| admin.thinky.vip | localhost:80 | nginx |
| geoq.help / www.geoq.help | localhost:443 | nginx |

可用域名后缀: mindmesh.site, geoq.help, thinky.vip

## 参考文档索引

| 文件 | 内容 |
|------|------|
| `references/server-context.md` | 完整服务器上下文：SSH 信息、项目布局、端口分配、域名映射、cloudflared 隧道配置、部署模式决策树 |

## 关联 skill

- **server-ops-safe**: 对 sense 执行安全排障时，先加载本 skill 获取上下文，再使用 server-ops-safe 的诊断流程
- **server-deploy**: 在 sense 上部署新项目时，先加载本 skill 了解现有布局和端口占用，再使用 server-deploy 的部署流程
