# AI 開發任務模板

每次交給 AI 修改前，複製下列區塊並填寫。未填欄位由 AI 先從 Repository 查證，不可自行猜測。

```text
Repository: shinryuken0505/three-kingdoms-survivor
Branch:
Base commit:
Target version:

Goal:

Acceptance criteria:
1.
2.
3.

Must not break:
- Existing save compatibility
- Enter / Space / Esc behavior
- 1280×720 layout
- zh_TW fallback
- Skin and gameplay data separation

Affected layer:
- [ ] core
- [ ] data
- [ ] system
- [ ] UI
- [ ] save
- [ ] localization
- [ ] assets

Player-visible text added:
- Translation keys:
- zh_TW:
- zh_CN:
- en:
- ja:

Verification:
- [ ] Godot Check green
- [ ] Project opens with F5
- [ ] Main flow tested
- [ ] Relevant modal tested
- [ ] Save/load tested when applicable

Known limitations:
```

## AI 回報格式

```text
Changed:
- path: purpose

Behavior:
- previous
- now

Data/save impact:
- none / migration details

Localization impact:
- none / keys added

Automated checks:
- status and limitations

Manual test path:
1.
2.
3.
```
