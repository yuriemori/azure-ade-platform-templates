---
name: iac-test
description: "Bicep IaC のテスト実行。Use when: Bicepテスト, bicep lint, bicep build, What-if分析, IaCバリデーション, デプロイ検証, インフラテスト"
argument-hint: "テスト対象のBicepファイルパスを指定してください（例: environments/WebApp-ACR-templates/main.bicep）"
---

# IaC テスト Skill — Bicep Lint + What-if 分析

Bicep テンプレートの品質を検証するための 3 段階テストを実行し、結果レポートを生成する。

## 前提条件

- Azure CLI がインストール済みであること（`az` コマンドが利用可能）
- Bicep CLI が利用可能であること（`az bicep version` で確認）
- What-if 分析を実行する場合は `az login` 済みであること
- 対象の Resource Group が存在すること（What-if 実行時）

## テスト手順

以下の 3 ステップを **順番に** 実行する。前のステップで致命的エラーが出た場合は修正を優先し、修正後に再実行する。

### Step 1: Bicep Build（構文チェック）

ターミナルで以下を実行し、コンパイルエラーがないことを確認する。

```powershell
az bicep build --file <対象Bicepファイル>
```

**判定基準**:
- 終了コード 0 → PASS
- コンパイルエラー → FAIL（エラーメッセージを記録し、修正を実施）

### Step 2: Bicep Lint（静的解析）

ターミナルで以下を実行し、Lintルール違反を検出する。

```powershell
az bicep lint --file <対象Bicepファイル>
```

**判定基準**:
- Warning のみ → WARN（警告内容を記録、対応推奨だが続行可能）
- Error あり → FAIL（エラー内容を記録し、修正を実施）
- 警告・エラーなし → PASS

**主な Lint ルール**（参考）:
- `no-unused-params` — 未使用パラメータの検出
- `no-unused-vars` — 未使用変数の検出
- `secure-parameter-default` — セキュアパラメータのデフォルト値禁止
- `prefer-interpolation` — 文字列補間の推奨
- `no-hardcoded-env-urls` — 環境依存 URL のハードコード禁止

### Step 3: What-if 分析（デプロイシミュレーション）

ターミナルで以下を実行し、デプロイ時のリソース変更を事前確認する。

```powershell
az deployment group what-if `
  --resource-group <リソースグループ名> `
  --template-file <対象Bicepファイル> `
  --parameters <パラメータファイル or インラインパラメータ>
```

**パラメータの指定方法**:
- パラメータファイル: `--parameters @params.json`
- インライン: `--parameters envName=test sqlAdminPassword=<テスト用パスワード>`

**判定基準**:
- 予期しない `Delete` 操作がない → PASS
- 予期しない `Delete` 操作がある → WARN（ユーザーに確認を促す）
- コマンド実行エラー → FAIL

**変更種別の分類**:
| 種別 | 意味 | アクション |
|------|------|----------|
| Create | 新規作成 | 想定通りか確認 |
| Modify | 既存リソースの変更 | 変更内容を確認 |
| Delete | リソース削除 | **要注意** — 意図した削除か必ず確認 |
| NoChange | 変更なし | 対応不要 |
| Ignore | What-if 未対応 | 手動確認推奨 |

## 結果レポート

テスト完了後、以下の形式で結果を報告する。

```markdown
## IaC テスト結果レポート

| ステップ | 結果 | 詳細 |
|---------|------|------|
| Bicep Build | PASS/FAIL | （エラーがあれば内容を記載） |
| Bicep Lint | PASS/WARN/FAIL | （警告・エラーがあれば内容を記載） |
| What-if | PASS/WARN/FAIL/SKIP | （変更サマリーまたはスキップ理由） |

**総合判定**: PASS / WARN / FAIL
```

**総合判定ルール**:
- 全ステップ PASS → **PASS**
- FAIL が 1 つでもある → **FAIL**（修正が必要）
- WARN のみ → **WARN**（確認推奨、続行可能）
- What-if を SKIP した場合は Build + Lint の結果で判定

## エラー修正ガイドライン

テスト結果が FAIL の場合:
1. エラーメッセージを確認し、該当する Bicep ファイルと行番号を特定する
2. 修正を実施する
3. **Step 1 から再実行** して修正が正しいことを確認する
4. 全ステップ PASS になるまで繰り返す

## 参照

- 既存 CI ワークフロー: `.github/workflows/webapp-acr-bicep-ci.yml`
- 設計書: `environments/WebApp-ACR-templates/design.md`
