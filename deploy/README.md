# 以后自建时用的 Docker 样例

这些 compose 文件**没有在本次测试机上运行**（机器没有 Docker）。它们只是把已验证过的版本钉死，方便以后放到 NAS / VPS 上，再用 HTTPS 反代给 iPhone Safari 访问。

- Memos 对外默认 5230（官方 Docker 端口）
- changedetection.io 对外默认 5000

上线后请立刻设置登录密码，不要把未加密的端口直接暴露到公网。
