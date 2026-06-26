# vt-skill

个人自写 skill 源仓库。

## 同步到 ccs

在本目录执行：

```powershell
.\scripts\sync-ccs-skills.ps1
```

脚本会扫描当前目录下包含 `SKILL.md` 的一级子目录，并在这些目录中创建 junction 链接：

```text
C:\Users\Twj\.cc-switch\skills
C:\Users\Twj\.codex\skills
C:\Users\Twj\.agents\skills
C:\Users\Twj\.claude\skills
```

默认行为：

- 新 skill：创建 junction 链接。
- 已经是正确链接：跳过。
- 已有同名普通目录：跳过并提示，不覆盖。
- `.git` 和 `scripts`：不作为 skill 同步。

如果确认要把目标目录中已有同名普通目录替换成链接：

```powershell
.\scripts\sync-ccs-skills.ps1 -ReplaceExisting
```

替换前会把原目录改名为 `.backup.YYYYMMDD_HHMMSS`，不会直接删除。

如果只想同步到某一个目录：

```powershell
.\scripts\sync-ccs-skills.ps1 -TargetRoot "C:\Users\Twj\.codex\skills"
```

预演：

```powershell
.\scripts\sync-ccs-skills.ps1 -DryRun
```
