# changedetection.io 实测记录

版本 0.70.2。若抓取公网页面时报 “resolves to a private/reserved IP address”，在**受信任的排错环境**里用：

```bash
CD_ALLOW_PRIVATE=1 tests/03-changedetection/scripts/start.sh
```

这会设置 `ALLOW_IANA_RESTRICTED_ADDRESSES=true`。普通家庭或 VPS 部署不要默认打开。完整结论见仓库根目录 README。
