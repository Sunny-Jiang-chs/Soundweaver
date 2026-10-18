# 第三方运行组件

织声 Soundweaver 的安装包内含 FFmpeg 和 FFprobe，用作独立子进程。它们安装在 `tools/ffmpeg/`，仅供本应用调用，不更改系统 PATH。

当前随包分发的是 Gyan 的 Windows 64 位静态 FFmpeg 9.0.1 essentials build，许可证为 GPL v3。完整许可证和构建配置、版权及源代码地址随二进制一同保存在 `tools/ffmpeg/LICENSE` 与 `tools/ffmpeg/README.txt`。

- 二进制与构建信息：https://www.gyan.dev/ffmpeg/builds/
- FFmpeg 源码：https://github.com/FFmpeg/FFmpeg/commit/bf1b838f2a
- FFmpeg 项目：https://ffmpeg.org/

安装包同时附带 Microsoft 签名的 WebView2 Evergreen Bootstrapper。已有 WebView2 的电脑直接使用现有运行时；缺少时引导程序联网下载并安装 Microsoft 运行时。WebView2 适用 Microsoft 的许可条款。

Python、pywebview、pythonnet、PyInstaller 及其依赖随桌面程序打包；各组件适用其自身许可证，随包元数据保留在 `_internal/`。FFmpeg 的许可不代替其他组件的许可。
