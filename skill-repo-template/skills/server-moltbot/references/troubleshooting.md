# Troubleshooting Guide

## Log Analysis

OpenClaw logs are JSON-structured, one entry per line. The message is in field `"0"`.

### View today's logs

```bash
ssh moltbot "tail -100 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log"
```

### Extract readable messages

```bash
# All messages (strip JSON wrapper)
ssh moltbot "grep -o '\"0\":\"[^\"]*\"' /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | tail -30"

# Errors only
ssh moltbot "grep -o '\"0\":\"[^\"]*\"' /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i 'error\|fail' | tail -20"

# Feishu-specific
ssh moltbot "grep -o '\"0\":\"[^\"]*\"' /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i 'feishu' | tail -20"

# Voice/audio/TTS related
ssh moltbot "grep -o '\"0\":\"[^\"]*\"' /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i 'audio\|voice\|tts\|opus\|whisper\|transcri' | tail -20"
```

### Log levels

Entries have `logLevelName` in `_meta`: TRACE, DEBUG, INFO, WARN, ERROR.

```bash
# Errors only (structured)
ssh moltbot 'grep "\"logLevelName\":\"ERROR\"" /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | tail -10'
```

## Common Issues

### 1. Feishu opus conversion failed

**Symptom**: `[feishu] opus conversion failed, sending as file`

**Cause**: ffmpeg can't convert the TTS output. Usually the input file is corrupted or empty.

**Fix**: Check that the TTS backend actually produces valid audio:
```bash
ssh moltbot "python3 ~/.openclaw/workspace/skills/tts/scripts/doubao_tts.py \
  --appid \$(cat ~/.doubao_appid) --token \$(cat ~/.doubao_token) \
  --text 'test' --output /tmp/tts_test.mp3 && file /tmp/tts_test.mp3"
```

### 2. messages.tts.enabled deprecation warning

**Symptom**: Repeated `messages.tts.enabled was replaced by messages.tts.auto`

**Cause**: Old config key in openclaw.json.

**Fix**: Already auto-migrated on load. The warning is harmless but noisy. To silence it:
```bash
ssh moltbot 'python3 -c "
import json
with open(\"/root/.openclaw/openclaw.json\") as f:
    cfg = json.load(f)
tts = cfg.get(\"messages\",{}).get(\"tts\",{})
tts.pop(\"enabled\", None)
if \"auto\" not in tts:
    tts[\"auto\"] = \"off\"
cfg[\"messages\"][\"tts\"] = tts
with open(\"/root/.openclaw/openclaw.json\",\"w\") as f:
    json.dump(cfg, f, indent=2)
print(\"Fixed\")
"'
```

### 3. Feishu API permission error (code 99991672)

**Symptom**: Bot can't resolve sender names, logs show permission violation.

**Cause**: Feishu app lacks `contact:user.base:readonly` scope.

**Fix**: Open the permission grant URL from the log. It looks like:
`https://open.feishu.cn/app/cli_xxx/...`

The bot already has cooldown logic (5min) to avoid spamming this error.

### 4. feishu_send_voice: command not found

**Symptom**: `[tools] exec failed: feishu_send_voice: command not found`

**Cause**: Agent trying to call an old/nonexistent tool name.

**Fix**: This is the agent hallucinating a tool. The correct flow is via `send_voice.sh` skill. The skill's SKILL.md should clearly describe the workflow. Check that the SKILL.md is well-written.

### 5. TTS API key not configured

**Symptom**: `Error: DOUBAO_APPID/DOUBAO_TOKEN not configured`

**Fix**:
```bash
ssh moltbot "printf '%s' 'YOUR_APPID' > ~/.doubao_appid && chmod 600 ~/.doubao_appid"
ssh moltbot "printf '%s' 'YOUR_TOKEN' > ~/.doubao_token && chmod 600 ~/.doubao_token"
```

### 6. Gateway not running

**Symptom**: No responses from bot, no new log entries.

**Check**:
```bash
ssh moltbot "ps aux | grep openclaw-gateway | grep -v grep"
```

**Fix**:
```bash
ssh moltbot "nohup openclaw gateway > /dev/null 2>&1 &"
# Wait and verify
ssh moltbot "sleep 3; ps aux | grep openclaw-gateway | grep -v grep"
```

## Health Check Sequence

Run these in order to verify the system is healthy:

```bash
# 1. Gateway process alive?
ssh moltbot "ps aux | grep openclaw-gateway | grep -v grep | wc -l"
# Expected: 1

# 2. Recent log activity?
ssh moltbot "tail -1 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | python3 -c \"import sys,json; print(json.load(sys.stdin).get('time','?'))\""
# Expected: recent timestamp

# 3. Docker containers up?
ssh moltbot "docker ps --format 'table {{.Names}}\t{{.Status}}'"

# 4. Skills in place?
ssh moltbot "ls ~/.openclaw/workspace/skills/tts/scripts/doubao_tts.py && echo OK"

# 5. Secrets configured?
ssh moltbot "test -s ~/.doubao_appid && test -s ~/.doubao_token && echo 'Doubao keys OK' || echo 'MISSING'"

# 6. TTS quick test
ssh moltbot "python3 ~/.openclaw/workspace/skills/tts/scripts/doubao_tts.py \
  --appid \$(cat ~/.doubao_appid) --token \$(cat ~/.doubao_token) \
  --text 'health check' --output /tmp/hc.mp3 && echo 'TTS OK' && rm /tmp/hc.mp3"
```
