# Deploy Playbook

## Standard Deployment: Skill Changes

Most changes are to custom skills in `~/.openclaw/workspace/skills/` (the `openclaw-skills` git repo).

### 1. Local Development

```bash
# Clone if not already
cd /Users/my-project/AI-PROJECT
git clone git@github.com:szc807414589/openclaw-skills.git

# Make changes
cd openclaw-skills
# ... edit files ...

# Commit and push
git add -A
git commit -m "description of change"
git push origin main
```

### 2. Server Deploy

```bash
ssh moltbot "cd ~/.openclaw/workspace/skills && git pull origin main"
```

Skills are loaded dynamically by the agent — **no restart needed** for skill file changes.

### 3. Verify

```bash
# Check the file landed
ssh moltbot "cat ~/.openclaw/workspace/skills/path/to/changed/file"

# Watch logs for next invocation
ssh moltbot "tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log"
```

## Config Changes (openclaw.json)

Config changes require a gateway restart.

### 1. Edit Config

Read first, then edit on server (config is server-specific, not in git):

```bash
# Read current config
ssh moltbot "cat ~/.openclaw/openclaw.json"

# Edit a specific field (use python for JSON safety)
ssh moltbot 'python3 -c "
import json
with open(\"/root/.openclaw/openclaw.json\") as f:
    cfg = json.load(f)
cfg[\"channels\"][\"feishu\"][\"dmPolicy\"] = \"open\"
with open(\"/root/.openclaw/openclaw.json\", \"w\") as f:
    json.dump(cfg, f, indent=2)
print(\"Config updated\")
"'
```

### 2. Restart Gateway

```bash
# Graceful restart
ssh moltbot "pkill -f openclaw-gateway; sleep 3; nohup openclaw gateway > /dev/null 2>&1 &"

# Verify it's running
ssh moltbot "sleep 2; ps aux | grep openclaw-gateway | grep -v grep"
```

## Adding API Secrets

Secrets are stored as plain files on the server (never in git):

```bash
# Pattern: create file, set permissions
ssh moltbot "printf '%s' 'SECRET_VALUE' > ~/.secret_name && chmod 600 ~/.secret_name"

# Existing secrets:
# ~/.doubao_appid    — Volcengine Doubao App ID
# ~/.doubao_token    — Volcengine Doubao Access Token
# ~/.noiz_api_key    — Noiz AI API key
# ~/.dashscope_api_key — Alibaba DashScope API key
```

## Adding a New TTS Backend

1. Create `tts/scripts/newbackend_tts.py` following the pattern of `doubao_tts.py` or `qwen_tts.py`
   - Accept `--text` / `--text-file`, `--output`, `--voice`, backend-specific auth args
   - Print `Done. Output: <path>` on success
   - Exit non-zero on failure

2. Edit `tts/scripts/tts.sh`:
   - Add key loader function (`load_newbackend_key`)
   - Add to `detect_backend()` priority list
   - Add `elif [[ "$backend" == "newbackend" ]]` branch in `cmd_speak()`

3. To make it the default for voice messages, edit `send_voice/send_voice.sh`:
   - Change `--backend doubao` to `--backend newbackend`

4. Deploy: push + pull

## Adding a New Skill

1. Create directory: `mkdir -p skillname/scripts`
2. Create `skillname/SKILL.md` with frontmatter (`name`, `description`) and usage docs
3. Create scripts in `skillname/scripts/`
4. Deploy via git push + pull
5. The agent discovers skills automatically from SKILL.md

## OpenClaw CLI Useful Commands

```bash
# Check service status
openclaw status

# List active sessions
openclaw sessions

# Send a test message
openclaw message send --channel feishu --target CHAT_ID --message "test"

# Manage skills
openclaw skills list
openclaw skills sync

# Check plugin health
openclaw channels status

# Run gateway in foreground (for debugging)
openclaw gateway --port 18789
```
