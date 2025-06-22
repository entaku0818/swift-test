# Swift OpenAPI Generator コマンドパターン集

このドキュメントでは、Swift OpenAPI Generatorの様々な使用パターンとコマンド例を紹介します。

## 🚀 基本的な使用方法

### 1. Package Plugin を使用（推奨）

```bash
# ビルド時に自動的にコード生成
swift build

# クリーンビルド（生成されたコードも削除）
swift package clean
swift build
```

### 2. 手動でコード生成

```bash
# 基本的な生成コマンド
swift run swift-openapi-generator generate \
  openapi.yaml \
  --config openapi-generator-config.yaml

# 出力ディレクトリを指定
swift run swift-openapi-generator generate \
  openapi.yaml \
  --config openapi-generator-config.yaml \
  --output-directory Sources/Generated
```

## 📑 openapi-generator-config.yaml 完全ガイド

### 設定ファイルの基本構造

```yaml
# 必須設定
generate:              # 生成するコンポーネントを指定
  - types             # 型定義（スキーマ）を生成
  - client            # クライアントコードを生成
  - server            # サーバーコードを生成

# オプション設定
accessModifier: public    # アクセス修飾子（public/internal/package/fileprivate/private）
namingStrategy: defensive # 命名戦略（defensive/optimistic）
filter:                  # フィルタリング設定
  paths: []              # 生成する/除外するパス
  schemas: []            # 生成する/除外するスキーマ

# 追加設定
additionalImports:       # 追加でインポートするモジュール
  - Foundation
  - Combine

featureFlags:           # 実験的機能フラグ
  - ExperimentalObjectOneOf
  - ExperimentalAllOf
  - ExperimentalStringlyTypedRawValues

# オーバーライド設定
nameOverrides:          # 名前のオーバーライド
  schemas:
    OldName: NewName
  operations:
    getOldEndpoint: getNewEndpoint

typeOverrides:          # 型のオーバーライド
  schemas:
    CustomDate: Foundation.Date
```

### 各設定項目の詳細

#### 1. generate（必須）
生成するコンポーネントを指定します。

| 値 | 説明 | 生成されるファイル |
|---|---|---|
| `types` | OpenAPIスキーマから型定義を生成 | Types.swift |
| `client` | HTTPクライアントコードを生成 | Client.swift |
| `server` | サーバー実装用プロトコルを生成 | Server.swift |

```yaml
# クライアント開発用
generate:
  - types
  - client

# サーバー開発用
generate:
  - types
  - server

# フルスタック開発用
generate:
  - types
  - client
  - server
```

#### 2. accessModifier（デフォルト: internal）
生成されるコードのアクセスレベルを指定します。

| 値 | 説明 | 使用例 |
|---|---|---|
| `public` | 他のモジュールから参照可能 | ライブラリ開発 |
| `internal` | 同一モジュール内のみ参照可能 | アプリ開発（デフォルト） |
| `package` | 同一パッケージ内で参照可能 | Swift 5.9+ |
| `fileprivate` | 同一ファイル内のみ参照可能 | 特殊用途 |
| `private` | 同一スコープ内のみ参照可能 | 特殊用途 |

```yaml
# ライブラリとして公開する場合
accessModifier: public

# アプリ内部で使用する場合
accessModifier: internal
```

#### 3. namingStrategy（デフォルト: defensive）
名前の衝突を避ける戦略を指定します。

| 値 | 説明 | 特徴 |
|---|---|---|
| `defensive` | 衝突を避けるため接頭辞/接尾辞を追加 | 安全だが冗長 |
| `optimistic` | 可能な限りシンプルな名前を使用 | 簡潔だが衝突リスクあり |

```yaml
# 安全性重視（推奨）
namingStrategy: defensive

# 簡潔性重視
namingStrategy: optimistic
```

#### 4. filter
特定のパスやスキーマの生成を制御します。

```yaml
# 特定のパスのみ生成
filter:
  paths:
    - /users
    - /posts
    - /comments

# 特定のスキーマのみ生成
filter:
  schemas:
    - User
    - Post
    - Comment

# 除外パターン（!で開始）
filter:
  paths:
    - "!*/admin/*"  # adminパスを除外
  schemas:
    - "!Internal*"  # Internal で始まるスキーマを除外
```

#### 5. additionalImports
生成されたコードに追加でインポートするモジュールを指定します。

```yaml
additionalImports:
  - Foundation      # 基本的に必要
  - Combine        # Combine を使用する場合
  - SwiftUI        # SwiftUI との統合
  - MyCustomModule # カスタムモジュール
```

#### 6. featureFlags
実験的機能を有効化します。

| フラグ | 説明 |
|---|---|
| `ExperimentalObjectOneOf` | oneOf のサポート（実験的） |
| `ExperimentalAllOf` | allOf のサポート（実験的） |
| `ExperimentalStringlyTypedRawValues` | 文字列型の raw value サポート |

```yaml
featureFlags:
  - ExperimentalObjectOneOf
  - ExperimentalAllOf
```

#### 7. nameOverrides
自動生成される名前をオーバーライドします。

```yaml
nameOverrides:
  schemas:
    # スキーマ名の変更
    user_profile: UserProfile
    post_item: Post
  operations:
    # オペレーション名の変更
    get_user_by_id: getUserById
    list_all_posts: listPosts
```

#### 8. typeOverrides
型のマッピングをカスタマイズします。

```yaml
typeOverrides:
  schemas:
    # カスタム日付型を使用
    CustomDate: Foundation.Date
    # カスタムUUID型を使用
    UniqueID: Foundation.UUID
```

## 📋 設定ファイルパターン

### クライアント専用（最も一般的）

```yaml
# openapi-generator-config.yaml
generate:
  - types
  - client
accessModifier: public
```

```bash
# コマンドライン実行
swift run swift-openapi-generator generate \
  openapi.yaml \
  --mode types \
  --mode client \
  --access-modifier public
```

### サーバー専用

```yaml
# openapi-generator-config-server.yaml
generate:
  - types
  - server
accessModifier: internal
```

```bash
# サーバー設定を使用
swift run swift-openapi-generator generate \
  openapi.yaml \
  --config openapi-generator-config-server.yaml
```

### 型定義のみ

```yaml
# openapi-generator-config-types-only.yaml
generate:
  - types
accessModifier: internal
```

```bash
# 型定義のみ生成
swift run swift-openapi-generator generate \
  openapi.yaml \
  --mode types \
  --access-modifier internal
```

## 🛠️ 高度な使用例

### 複数の OpenAPI 仕様書を扱う

```bash
# API v1 用
swift run swift-openapi-generator generate \
  api-v1.yaml \
  --config config-v1.yaml \
  --output-directory Sources/APIv1

# API v2 用
swift run swift-openapi-generator generate \
  api-v2.yaml \
  --config config-v2.yaml \
  --output-directory Sources/APIv2
```

### 実験的機能を有効化

```yaml
# openapi-generator-config-experimental.yaml
generate:
  - types
  - client
accessModifier: public
featureFlags:
  - ExperimentalObjectOneOf
  - ExperimentalAllOf
```

### カスタムインポートを追加

```yaml
# openapi-generator-config-custom.yaml
generate:
  - types
  - client
accessModifier: public
additionalImports:
  - Foundation
  - Combine
  - MyCustomFramework
```

### 実践的な設定例

#### iOS アプリ開発用
```yaml
generate:
  - types
  - client
accessModifier: internal
additionalImports:
  - Foundation
  - SwiftUI
  - Combine
```

#### Swift パッケージライブラリ用
```yaml
generate:
  - types
  - client
accessModifier: public
namingStrategy: defensive
additionalImports:
  - Foundation
```

#### マイクロサービス用
```yaml
generate:
  - types
  - server
accessModifier: internal
filter:
  paths:
    - /api/v1/*
    - "!*/internal/*"  # 内部APIを除外
additionalImports:
  - Foundation
  - Vapor
```

#### テスト環境用（モックサーバー）
```yaml
generate:
  - types
  - client
  - server
accessModifier: internal
featureFlags:
  - ExperimentalObjectOneOf
  - ExperimentalAllOf
```

## 🏗️ プロジェクト構成例

### 基本構成（Package Plugin 使用）

```
MyProject/
├── Package.swift
├── Sources/
│   └── MyApp/
│       ├── openapi.yaml
│       ├── openapi-generator-config.yaml
│       └── main.swift
```

### 複数ターゲット構成

```
MyProject/
├── Package.swift
├── Sources/
│   ├── APIClient/
│   │   ├── openapi.yaml
│   │   └── openapi-generator-config.yaml
│   ├── APIServer/
│   │   ├── openapi.yaml
│   │   └── openapi-generator-config-server.yaml
│   └── SharedTypes/
│       ├── openapi.yaml
│       └── openapi-generator-config-types-only.yaml
```

## 🔧 CI/CD での使用

### GitHub Actions

```yaml
name: Build
on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: swift-actions/setup-swift@v1
        with:
          swift-version: "5.9"
      - name: Generate OpenAPI Code
        run: swift build
      - name: Run Tests
        run: swift test
```

### Makefile パターン

```makefile
# Makefile
.PHONY: generate build test clean

generate:
	swift run swift-openapi-generator generate \
		openapi.yaml \
		--config openapi-generator-config.yaml

build: generate
	swift build

test: build
	swift test

clean:
	swift package clean
	rm -rf .build
```

## 🎯 トラブルシューティング

### 生成されたコードの場所を確認

```bash
# Package Plugin 使用時の生成先
find .build -name "*.swift" -path "*OpenAPIGenerator*" | head -10

# 通常は以下のパスに生成される
# .build/plugins/outputs/<package-name>/<target-name>/destination/OpenAPIGenerator/GeneratedSources/
```

### 生成エラーのデバッグ

```bash
# 詳細なログを出力
swift build -v

# ドライラン（実際には生成しない）
swift run swift-openapi-generator generate \
  openapi.yaml \
  --config openapi-generator-config.yaml \
  --dry-run
```

### クリーンビルド

```bash
# 生成されたコードを含めて完全にクリーン
rm -rf .build
swift package clean
swift build
```

## 📝 ベストプラクティス

1. **Package Plugin を優先使用** - 自動化されており、常に最新の状態を保てる
2. **設定ファイルで管理** - コマンドラインオプションより保守性が高い
3. **バージョン固定** - Package.swift で exact バージョンを指定
4. **生成コードは commit しない** - .gitignore に追加

### 設定ファイルのベストプラクティス

#### ✅ 推奨される設定
```yaml
# 明示的に必要な設定のみ記載
generate:
  - types
  - client
accessModifier: internal  # デフォルトでも明示的に記載

# 必要に応じて追加
additionalImports:
  - Foundation  # Date, URL などを使用する場合
```

#### ❌ 避けるべき設定
```yaml
# 過度に複雑な設定は避ける
featureFlags:
  - ExperimentalObjectOneOf  # 本当に必要な場合のみ
  - ExperimentalAllOf        # 実験的機能は慎重に
  
# 不要なインポートは避ける
additionalImports:
  - UIKit       # SwiftUI アプリには不要
  - Foundation  # すでにデフォルトで含まれている
```

### コマンドラインオプションとの対応

| 設定ファイル | コマンドラインオプション |
|---|---|
| `generate: [types]` | `--mode types` |
| `generate: [client]` | `--mode client` |
| `generate: [server]` | `--mode server` |
| `accessModifier: public` | `--access-modifier public` |
| `filter.paths: [/users]` | `--filter-path /users` |
| `featureFlags: [flag]` | `--feature-flag flag` |

```gitignore
# .gitignore
.build/
.swiftpm/
*.xcodeproj
```

## 🔗 参考リンク

- [公式ドキュメント](https://github.com/apple/swift-openapi-generator)
- [サンプルプロジェクト](https://github.com/apple/swift-openapi-generator/tree/main/Examples)
- [Swift Forums](https://forums.swift.org/c/related-projects/swift-openapi)