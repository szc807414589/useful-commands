# OpenClaw Architecture Reference

## Server Directory Layout

```
/usr/lib/node_modules/openclaw/          # OpenClaw install (npm global)
├── openclaw.mjs                          # Entry point
├── dist/                                 # Compiled JS
├── extensions/                           # Channel & feature extensions
│   ├── feishu/                           # 飞书 extension
│   │   ├── src/
│   │   │   ├── bot.ts                    # Message receive/dispatch logic
│   │   │   ├── media.ts                  # Upload/download/send media (image, audio, file)
│   │   │   ├── send.ts                   # Message sending
│   │   │   ├── client.ts                 # Feishu API client factory
│   │   │   ├── accounts.ts              # Multi-account resolution
│   │   │   ├── channel.ts               # Channel registration
│   │   │   ├── policy.ts                # Group/DM allowlist policies
│   │   │   ├── reply-dispatcher.ts      # Reply routing (text splitting, typing indicator)
│   │   │   ├── mention.ts              # @mention parsing and forward
│   │   │   ├── reactions.ts            # Emoji reactions
│   │   │   ├── typing.ts              # Typing indicators
│   │   │   ├── monitor.ts             # Health monitoring
│   │   │   ├── onboarding.ts          # First-run setup
│   │   │   └── ...
│   │   ├── skills/
│   │   │   ├── feishu-doc/
│   │   │   ├── feishu-drive/
│   │   │   ├── feishu-perm/
│   │   │   └── feishu-wiki/
│   │   └── openclaw.plugin.json
│   ├── voice-call/                       # Phone call extension (Twilio/Telnyx)
│   │   ├── src/
│   │   │   ├── telephony-audio.ts       # PCM/mulaw audio conversion
│   │   │   ├── telephony-tts.ts         # TTS for phone calls
│   │   │   ├── webhook.ts              # Inbound call webhooks
│   │   │   ├── manager.ts              # Call state management
│   │   │   └── ...
│   │   └── openclaw.plugin.json
│   ├── discord/
│   ├── slack/
│   ├── telegram/
│   ├── whatsapp/
│   ├── memory/
│   ├── memory-core/
│   └── ...
├── skills/                               # Built-in skills
│   ├── openai-whisper/                   # Local Whisper STT
│   ├── openai-whisper-api/               # OpenAI Whisper API STT
│   │   └── scripts/transcribe.sh
│   ├── sherpa-onnx-tts/                  # Local TTS engine
│   └── ...
└── node_modules/

~/.openclaw/                              # User state directory
├── openclaw.json                         # Main config (channels, models, agents, gateway)
├── workspace/
│   ├── BOOTSTRAP.md                      # First-run conversation guide
│   ├── IDENTITY.md                       # Bot identity (name: moss)
│   ├── USER.md                           # User info (老常, GitHub: szc807414589)
│   ├── TOOLS.md                          # Environment-specific tool notes
│   ├── AGENTS.md
│   ├── HEARTBEAT.md
│   ├── SOUL.md
│   ├── memory/                           # Agent memory files
│   └── skills/                           # Custom workspace skills (git managed)
│       ├── .git/                         # → github.com:szc807414589/openclaw-skills
│       ├── tts/                          # Text-to-speech (multi-backend)
│       │   ├── SKILL.md
│       │   └── scripts/
│       │       ├── tts.sh               # Main TTS dispatcher
│       │       ├── doubao_tts.py        # Volcengine Doubao backend
│       │       ├── edge_tts_wrapper.py  # Microsoft Edge TTS backend
│       │       ├── noiz_tts.py          # Noiz AI backend
│       │       ├── qwen_tts.py          # Alibaba Qwen3 backend
│       │       ├── render_timeline.py   # SRT timeline rendering
│       │       └── text_to_srt.py       # Text to SRT conversion
│       ├── send_voice/                   # Feishu voice bubble sender
│       │   ├── SKILL.md
│       │   └── send_voice.sh
│       ├── characteristic-voice/
│       ├── image-generate/
│       ├── video-generate/
│       ├── video-translation/
│       └── ...
└── extensions/                           # User-installed extensions
    ├── dingtalk-connector/
    ├── wecom/
    └── qqbot/
```

## Config Structure (openclaw.json)

Key sections of `~/.openclaw/openclaw.json`:

```jsonc
{
  "agents": {
    "defaults": {
      "model": { "primary": "openai-codex/gpt-5.3-codex" },
      "workspace": "/root/.openclaw/workspace",
      "maxConcurrent": 4
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "appId": "cli_a9f6b977e2f99ccd",
      "appSecret": "...",
      "connectionMode": "websocket",
      "dmPolicy": "open",
      "groupPolicy": "open"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "lan",
    "controlUi": { "enabled": true }
  },
  "messages": {
    "tts": { "auto": "off" }
  },
  "plugins": {
    "entries": {
      "feishu": { "enabled": true },
      "wecom": { "enabled": true },
      "dingtalk-connector": { "enabled": true },
      "qqbot": { "enabled": true }
    }
  }
}
```

## Feishu Voice Message Flow

### Receiving voice (STT):
```
User sends voice in Feishu
  → bot.ts: handleFeishuMessage()
    → resolveFeishuMediaList(): downloads audio via messageResource API
    → saves to disk as inbound media
    → passes <media:audio> + MediaPath to agent
    → agent uses openai-whisper-api skill to transcribe
```

### Sending voice (TTS):
```
Agent decides to send voice
  → send_voice/send_voice.sh --text "content"
    → tts/scripts/tts.sh speak --backend doubao
      → doubao_tts.py: HTTP POST to openspeech.bytedance.com/api/v1/tts
      → outputs MP3
    → ffmpeg: MP3 → opus (16kHz mono, libopus 32k)
    → outputs MEDIA:/tmp/feishu_voice_xxx.opus
  → message --action sendAttachment --media /path/to/file.opus
    → media.ts: sendMediaFeishu()
      → detects .opus → isAudio path
      → uploadFileFeishu(fileType: "opus")
      → sendAudioFeishu(msg_type: "audio")
      → Feishu shows voice bubble
```

## Skill Anatomy

Each skill is a directory under `~/.openclaw/workspace/skills/` with at minimum a `SKILL.md`:

```yaml
---
name: skill-name
description: "What this skill does and when to invoke it"
---

# Skill Name

Usage instructions, examples, workflow steps.
The agent reads this to know how to use the skill.
```

Scripts go in `scripts/` subdirectory. The agent invokes them via bash.

## Docker Containers on Server

```
cli-proxy-api (eceasy/cli-proxy-api:latest)
  Ports: 1455, 8085, 8317, 11451, 51121, 54545
```
