# 107MCP

通过 Tailscale 和 Windows-MCP，允许 macOS 上的 Codex 使用 Windows 主机已经认证的 PuTTY/Plink SSH 共享连接。客户端不需要学校服务器私钥或验证码。

## 同事的 Mac：让 Codex 自动配置

先安装 Tailscale 并接受 Windows 设备的共享邀请。然后可以将以下内容交给 Mac 上的 Codex：

> 请克隆 https://github.com/Qesire/107MCP，阅读 README 并帮我配置 school MCP。保留已有配置；需要 Tailscale 登录、设备共享、Windows 主机地址和 MCP 密码时请让我提供。运行 `bash mac/setup.sh`，完成后检查 MCP 是否连接并只读执行服务器 `hostname`。

脚本会要求输入 Windows 的 Tailscale IPv4 地址，检查现有 Codex 配置，并在不覆盖原配置的情况下添加 `school` MCP。已有同名配置时它会停止，不会覆盖。脚本需要 Python 3.11 或更高版本以及已安装的 Codex CLI。

配置后，运行 `~/.local/bin/school-codex`，输入 Windows 主机设置的 MCP 密码，启动 Codex。密码仅保存在当前进程的环境中，每次启动时输入；桌面应用不能保证继承终端变量。

使用 Codex 时告诉它：通过 `school` MCP 的 PowerShell 工具调用下面的命令，按 `SCHOOL_EXIT_CODE` 和 `Status Code` 判断结果：

```powershell
& 'C:\school-bridge\run.ps1' 'hostname'; exit $LASTEXITCODE
```

后续命令以服务器上已登录的账号执行。GPU 作业使用 Slurm，先查询已有作业，避免重复提交。上传或下载 Mac 本地文件不由这个 MCP 自动提供。

## Windows 主机

Windows 主机须安装 Tailscale、PuTTY/Plink、uv、Python 3.14 和支持 `--control-policy relaxed` 的 Windows-MCP。先登录 PuTTY 并启用共享连接，再启动 Windows-MCP；监听 Tailscale IPv4 地址，启用认证并限制为 PowerShell 工具。`windows/run.ps1` 是运行远程命令的适配脚本，按实际 PuTTY 会话名设置 `PUTTY_SESSION` 环境变量，默认值为 `107`。

当前项目不包含私钥、密码、主机地址或 PuTTY 配置；它们必须由主机所有者自行设置。Mac 配置脚本不会在仓库中写入密码。

**权限范围：** Windows-MCP 的 PowerShell 工具能运行当前 Windows 用户有权执行的任意命令，并非只允许连接学校服务器。请只向可信任的人共享设备和 MCP 令牌，遵守学校账号使用规定。连接信息通过私密渠道传递，建议使用随机强令牌。Tailscale 负责传输加密；不要把 MCP 端口直接开放到公网。

