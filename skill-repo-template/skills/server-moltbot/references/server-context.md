# moltbot Server & OpenClaw Service

When working in this directory or on tasks involving the moltbot server / OpenClaw service, follow these instructions.

## Server Access

```
Host moltbot
    HostName 69.5.7.188
    User root
    Port 2299
    IdentityFile ~/.ssh/id_rsa
```

SSH command: `ssh moltbot`

**Important**: SSH connections to this server are slow to establish (10-20s). Always use `-o ConnectTimeout=15` and set tool timeouts to 30000+ms.

## Core Principle: Local Edit, Remote Deploy

All code changes happen **locally** then deploy via git. NEVER edit files directly on the server.

```
Local edit → git push → ssh moltbot "cd ~/.openclaw/workspace/skills && git pull"
```

Server is only for: reading logs, checking status, running deploy pulls, testing, configuring secrets.

## OpenClaw Architecture

See `openclaw-architecture.md` for full directory layout.

Key paths on server:
- **Install**: `/usr/lib/node_modules/openclaw/`
- **Config**: `~/.openclaw/openclaw.json`
- **Workspace**: `~/.openclaw/workspace/`
- **Custom skills**: `~/.openclaw/workspace/skills/` (git repo: `szc807414589/openclaw-skills`)
- **Built-in skills**: `/usr/lib/node_modules/openclaw/skills/`
- **Extensions**: `/usr/lib/node_modules/openclaw/extensions/`
- **Logs**: `/tmp/openclaw/openclaw-YYYY-MM-DD.log`

## Deployment Workflow

See `deploy-playbook.md` for the full step-by-step.

Quick version:
1. Clone/edit locally: `cd /Users/my-project/AI-PROJECT/openclaw-skills`
2. Commit & push to GitHub
3. Server pull: `ssh moltbot "cd ~/.openclaw/workspace/skills && git pull origin main"`
4. If config changed: edit `~/.openclaw/openclaw.json` on server
5. If restart needed: `ssh moltbot "pkill -f openclaw-gateway; sleep 2; nohup openclaw gateway &"`

## Secrets Management

API keys are stored as files on the server (NOT in git):
- `~/.doubao_appid` / `~/.doubao_token` — Volcengine Doubao TTS
- `~/.noiz_api_key` — Noiz TTS
- `~/.dashscope_api_key` — Alibaba DashScope

To add a new secret: `ssh moltbot "printf '%s' 'VALUE' > ~/.secret_file && chmod 600 ~/.secret_file"`

## Current Channel Setup

| Channel | Status | Mode |
|---------|--------|------|
| Feishu (飞书) | enabled | WebSocket, appId: cli_a9f6b977e2f99ccd |
| WeCom (企业微信) | enabled | Webhook |
| DingTalk (钉钉) | enabled | Plugin |
| QQBot | enabled | Plugin |

## TTS (Text-to-Speech) Stack

Backend priority (auto-detected by `tts/scripts/tts.sh`):
1. **doubao** — Volcengine, voice: `zh_female_vv_uranus_bigtts`
2. **edge** — Microsoft Edge-TTS (free, no key)
3. **noiz** — Noiz AI
4. **qwen** — Alibaba Qwen3-TTS
5. **kokoro** — Local engine

Voice message flow: `send_voice.sh → tts.sh (doubao) → ffmpeg (mp3→opus) → feishu sendAudioFeishu()`

## CLI-Proxy-API

Docker 容器运行的多端口 AI API 代理服务。

**关键路径**:
- 配置文件: `/opt/CLIProxyAPI/config.yaml`
- 认证目录: `/opt/CLIProxyAPI/auths` → 容器内 `/root/.cli-proxy-api`
- 日志目录: `/opt/CLIProxyAPI/logs`

**端口**:
| 端口 | 用途 |
|------|------|
| 8317 | 管理面板 |
| 1455, 8085, 11451, 51121, 54545 | API 端口 |

管理面板地址: `http://69.5.7.188:8317`

**升级命令**:
```bash
# 1. 拉取最新镜像
ssh moltbot "docker pull eceasy/cli-proxy-api:latest"

# 2. 停止并删除旧容器
ssh moltbot "docker stop cli-proxy-api && docker rm cli-proxy-api"

# 3. 用相同参数重建容器（配置/认证/日志都是 bind mount，不会丢失）
ssh moltbot "docker run -d \
  --name cli-proxy-api \
  --restart unless-stopped \
  -e TZ=Asia/Shanghai \
  -v /opt/CLIProxyAPI/config.yaml:/CLIProxyAPI/config.yaml \
  -v /opt/CLIProxyAPI/logs:/CLIProxyAPI/logs \
  -v /opt/CLIProxyAPI/auths:/root/.cli-proxy-api \
  -p 1455:1455 \
  -p 8085:8085 \
  -p 8317:8317 \
  -p 11451:11451 \
  -p 51121:51121 \
  -p 54545:54545 \
  eceasy/cli-proxy-api:latest"

# 4. 验证
ssh moltbot "docker ps | grep cli-proxy-api && docker logs --tail 20 cli-proxy-api"
```

## 防火墙与 IP 白名单

服务器使用 iptables 限制 SSH（端口 2299）只允许特定 IP 访问，其余 DROP。

**连接被拒时的排查步骤**:
1. 检查本机当前公网 IP: `curl -s ifconfig.me`
2. 对比服务器白名单中的 IP 是否匹配
3. 如果 IP 变化（换 WiFi、重拨等），需要通过云厂商 VNC 控制台登录服务器添加新 IP

**添加/移除白名单 IP**（需通过 VNC 控制台或已有 SSH 连接执行）:
```bash
# 查看当前规则
iptables -L INPUT -n --line-numbers

# 添加新 IP 到白名单（插入到 DROP 规则之前）
iptables -I INPUT -s <NEW_IP> -p tcp --dport 2299 -j ACCEPT

# 移除旧 IP（先用上面命令找到行号）
iptables -D INPUT <行号>

# 持久化规则
iptables-save > /etc/iptables.rules
```

**IP 变化应对方案**:
1. `curl -s ifconfig.me` 获取当前公网 IP
2. 登录云厂商控制台，使用 VNC 远程连接进入服务器
3. 执行 `iptables -I INPUT -s <新IP> -p tcp --dport 2299 -j ACCEPT`
4. 执行 `iptables-save > /etc/iptables.rules` 持久化
5. 退出 VNC，用 SSH 验证连接

## Troubleshooting

See `troubleshooting.md` for log analysis patterns and common errors.

Quick log check:
```bash
ssh moltbot "grep -o '\"0\":\"[^\"]*\"' /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i 'error\|fail' | tail -20"
```
