---
name: server-moltbot
description: "moltbot 服务器（69.5.7.188:2299）的上下文和操作指南。运行 OpenClaw 聊天机器人系统，含飞书/企微/钉钉/QQ 渠道集成和 TTS 语音功能。当提到 moltbot、openclaw、聊天机器人服务器、语音机器人、飞书机器人部署时使用此 skill 获取服务器上下文。"
---

# server-moltbot

moltbot 服务器的上下文知识库。提供连接信息、架构知识、项目布局等服务器特定上下文。

## SSH 连接

```
Host moltbot
    HostName 69.5.7.188
    User root
    Port 2299
    IdentityFile ~/.ssh/id_rsa
```

SSH 命令: `ssh moltbot`

**注意**: SSH 连接较慢（10-20s），始终使用 `-o ConnectTimeout=15`，工具超时设为 30000+ms。

## 服务器用途

运行 OpenClaw 聊天机器人平台，包含：
- 飞书/企微/钉钉/QQ 多渠道集成
- TTS 语音合成（doubao/edge/noiz/qwen/kokoro 多后端）
- CLI-Proxy-API Docker 容器（多端口 AI API 代理）
- iptables 防火墙 IP 白名单

## 关键路径速查

| 路径 | 说明 |
|------|------|
| `/usr/lib/node_modules/openclaw/` | OpenClaw 安装目录 |
| `~/.openclaw/openclaw.json` | 主配置文件 |
| `~/.openclaw/workspace/` | 工作区 |
| `~/.openclaw/workspace/skills/` | 自定义 skill（git 管理） |
| `/usr/lib/node_modules/openclaw/skills/` | 内置 skill |
| `/usr/lib/node_modules/openclaw/extensions/` | 渠道扩展 |
| `/tmp/openclaw/openclaw-YYYY-MM-DD.log` | 日志 |
| `/opt/CLIProxyAPI/` | CLI-Proxy-API 配置和日志 |

## 参考文档索引

| 文件 | 内容 |
|------|------|
| `references/server-context.md` | SSH 信息、架构路径、secrets 管理、渠道配置、TTS 栈、Docker 容器、防火墙规则 |
| `references/openclaw-architecture.md` | OpenClaw 完整目录结构、配置格式、语音消息流程、Skill 规范 |
| `references/deploy-playbook.md` | 部署步骤、skill 变更流程、配置变更、secrets 管理、TTS 后端添加 |
| `references/troubleshooting.md` | 日志分析方法、常见问题排查、健康检查序列 |

## 关联 skill

- **server-ops-safe**: 对 moltbot 执行安全排障时，先加载本 skill 获取上下文，再使用 server-ops-safe 的诊断流程
- **server-deploy**: 在 moltbot 上部署新服务时，先加载本 skill 了解现有布局，再使用 server-deploy 的部署流程
