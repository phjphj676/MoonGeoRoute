# Mooncakes 发布说明

MoonGeoRoute 的 MoonBit 模块名为 `phjphj676/moongeoroute`。

## 现状

- 仓库已经具备发布所需的 `moon.mod`、README、测试、CI 和说明文件。
- 本地 MoonBit 工具链已登录 Mooncakes，可以直接执行发布。
- 发布流程已在仓库中提供 `publish.yml`，便于后续自动化。

## 手动发布

```bash
moon publish
```

发布前建议先确认：

```bash
moon whoami
moon version --all
moon check
moon test
```
