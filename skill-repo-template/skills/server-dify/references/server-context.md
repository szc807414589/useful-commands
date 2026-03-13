# dify 服务器

在此目录下工作时，自动加载以下上下文。

## SSH 连接

```
Host dify
    HostName 118.196.83.124
    User root
    Port 22
```

SSH 命令: `ssh dify`

## 服务器概况

- 用途: Dify 平台
- 已知服务: Dify（AI 应用开发平台）

## 项目布局

> 首次使用时运行 `scan_server.sh` 探测并补充。
>
> ```bash
> ssh dify "bash -s" < ../server-deploy/scripts/scan_server.sh
> ```

## 注意事项

- Dify 通常使用 Docker Compose 部署，检查 `/opt` 或 `/home` 下的项目目录
