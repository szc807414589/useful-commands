# sense 服务器

在此目录下工作时，自动加载以下上下文。

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
- 运行时: Python 3.12.3, Node.js (PM2), Docker + Docker Compose, Git 2.43 (SSH key 已配置 GitHub)

## 项目布局

| 项目 | 位置 | 部署方式 | 端口 | 域名 |
|------|------|---------|------|------|
| ai-cmo | /opt/projects/ai-cmo | Docker | 8000, 8081 | - |
| ai-write (ziliu) | /opt/projects/ai-write | Docker | 3000 | media.geoq.help |
| sense | /opt/projects/sense | Docker Compose | 3001, 3307, 6380 | sense.mindmesh.site |
| thinky | /opt/projects/thinky | PM2 | 8001 | api.thinky.vip |
| ai-quantify | /opt/projects/ai-quantify | systemd + venv | 8002 | quant.mindmesh.site |

## 端口分配

**已用端口**: 3000, 3001, 3306, 3307, 6379, 6380, 8000, 8001, 8002, 8081
**下一个可用端口**: 8003

## 域名映射

| 域名 | 目标 | 备注 |
|------|------|------|
| sense.mindmesh.site | localhost:3001 | cloudflared |
| quant.mindmesh.site | localhost:8002 | cloudflared |
| media.geoq.help | localhost:3000 | cloudflared |
| api.thinky.vip | localhost:8001 | cloudflared |
| admin.thinky.vip | localhost:80 | nginx |
| geoq.help / www.geoq.help | localhost:443 | nginx |

**可用域名后缀**: mindmesh.site, geoq.help, thinky.vip

## cloudflared 隧道

- 隧道名: `sense-tunnel`
- 隧道 ID: `b903f3c6-dc04-4f26-a845-82ae8040fcc4`
- 配置文件: `/etc/cloudflared/config.yml`
- 添加域名: `cloudflared tunnel route dns sense-tunnel <domain>`

## 技术栈与部署模式决策树

| 条件 | 推荐部署方式 |
|------|------------|
| Python FastAPI，无 Dockerfile | systemd + venv |
| 项目有 Dockerfile/docker-compose | Docker Compose |
| Node.js 项目，已有 PM2 | PM2 |
| 内存 < 4GB | 优先 systemd（最轻量） |

### 标准部署路径

```
Python: uvicorn --host 127.0.0.1 --port <N>
  服务文件: /etc/systemd/system/<name>.service
  日志: journalctl -u <name>

Node.js: pm2 start ecosystem.config.js
  日志: pm2 logs

Docker: docker compose up -d --build
  日志: docker compose logs -f

外网访问: cloudflared tunnel route dns sense-tunnel <domain>
本地部署脚本: deploy-server.sh (update/init/status/logs/restart)
```

---

*最后更新: 2026-03-09*
