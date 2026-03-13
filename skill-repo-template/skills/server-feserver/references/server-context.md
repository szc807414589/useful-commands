# feserver 服务器

在此目录下工作时，自动加载以下上下文。

## SSH 连接

```
Host feserver
    HostName 10.199.157.75
    User afe
    Port 22
```

SSH 命令: `ssh feserver`

## 服务器概况

- 用途: 前端服务器
- 网络: 内网 IP，需要 VPN 才能访问

## 项目布局

> 首次使用时运行 `scan_server.sh` 探测并补充。
>
> ```bash
> ssh feserver "bash -s" < ../server-deploy/scripts/scan_server.sh
> ```

## 注意事项

- 需要先连接 VPN 才能 SSH
- 用户为 `afe`（非 root），部分操作可能需要 sudo
