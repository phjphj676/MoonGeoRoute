# Mooncakes 发布说明

MoonGeoRoute 的 MoonBit 模块名为 `phjphj676/moongeoroute`，当前已发布修订版本为 `0.1.6`。

## 现状

- 仓库已经具备发布所需的 `moon.mod`、README、测试、CI 和说明文件。
- `0.1.3`、`0.1.4`、`0.1.5` 和 `0.1.6` 均已发布成功；`0.1.6` 包含四目标严格 CI 和端到端场景测试。
- 发布流程已在仓库中提供 `publish.yml`，便于后续自动化。

## Release verification

`0.1.6` carries the validated implementation together with the four-target CI and real-city workflow evidence. Before publishing, run `moon check --deny-warn --target all` and `moon test --deny-warn --target all`; after publishing, verify the exact version from a clean consumer project with `moon add phjphj676/moongeoroute`.

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
