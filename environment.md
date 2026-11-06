# 测试环境

记录于 2026-11-06 23:42 CST（Asia/Shanghai）。本报告中的时间若无其它时区标注，均为这个时区。

| 项目 | 实测值 |
| --- | --- |
| 系统 | Linux 6.12.94+ x86_64 |
| Docker | **没有** Docker CLI / Compose（因此本次不测依赖 Docker 的项目） |
| Python | 3.13.5（pip 25.1.1） |
| Node.js | v20.19.2 / npm 11.21.1 |
| Go | 1.27.3 |
| ffmpeg | 已安装（`/usr/bin/ffmpeg`） |
| 内存 | 约 15 GiB 总量，开始测试时可用约 2.3 GiB |
| 磁盘 | 约 120 GiB 可用 |

选用实测项目的原则：能在无 Docker、无付费 LLM/API Key 的前提下，用官方二进制或 pip 安装，并真正跑通核心功能。
