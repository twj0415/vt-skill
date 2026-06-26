# vt-skill

个人自写 skill 源仓库。

## 同步到 ccs

在本目录执行：

```powershell
.\scripts\sync-ccs-skills.ps1
```

脚本会扫描当前目录下包含 `SKILL.md` 的一级子目录，并在 `C:\Users\Twj\.cc-switch\skills` 中创建目录链接。

默认行为：

- 新 skill：创建 junction 链接。
- 已经是正确链接：跳过。
- 已有同名普通目录：跳过并提示，不覆盖。
- `.git` 和 `scripts`：不作为 skill 同步。

如果确认要把 ccs 中已有同名普通目录替换成链接：

```powershell
.\scripts\sync-ccs-skills.ps1 -ReplaceExisting
```

替换前会把原目录改名为 `.backup.YYYYMMDD_HHMMSS`，不会直接删除。

预演：

```powershell
.\scripts\sync-ccs-skills.ps1 -DryRun
```
