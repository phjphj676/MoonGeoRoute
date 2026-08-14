# Mooncakes 发布说明

MoonGeoRoute 的 MoonBit 模块名为 `phjphj676/moongeoroute`，当前已发布修订版本为 `0.1.4`。

## 现状

- 仓库已经具备发布所需的 `moon.mod`、README、测试、CI 和说明文件。
- `0.1.3` 和 `0.1.4` 均已发布成功；`0.1.4` 包含本轮文档和验收说明更新。
- 发布流程已在仓库中提供 `publish.yml`，便于后续自动化。

## Release verification

`0.1.4` carries the validated implementation together with the corrected acceptance documentation. Before publishing, run `moon check --deny-warn` and `moon test --deny-warn`; after publishing, verify the exact version from a clean consumer project with `moon add phjphj676/moongeoroute`.

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
