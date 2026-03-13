# servyou169 服务器

在此目录下工作时，自动加载以下上下文。

## SSH 连接

```
Host servyou169
    HostName 10.199.157.169
    User root
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

SSH 命令: `ssh servyou169`

## 服务器概况

- 用途: 内网服务器
- 网络: 内网 IP，需要 VPN 才能访问

## 项目布局

> 首次使用时运行 `scan_server.sh` 探测并补充。
>
> ```bash
> ssh servyou169 "bash -s" < ../server-deploy/scripts/scan_server.sh
> ```

## 注意事项

- 需要先连接 VPN 才能 SSH
- 连接前确认 VPN 状态正常
