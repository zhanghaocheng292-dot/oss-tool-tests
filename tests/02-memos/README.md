# Memos 实测记录

版本 26.11.0，Linux amd64 官方二进制。登录必须使用：

```json
{"passwordCredentials":{"username":"tester","password":"..."}}
```

扁平的 `{"username","password"}` 会返回 HTTP 400 `invalid credentials`。完整结论见仓库根目录 README。
