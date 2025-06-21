# Swift OpenAPI Generator 設定オプションと生成される内容の違い

## 概要

Swift OpenAPI Generatorは`openapi-generator-config.yaml`ファイルの設定によって異なるコードを生成します。
このドキュメントでは、各設定オプションがどのように生成されるコードに影響するかを説明します。

## 主要な設定オプション

### 1. generate オプション

#### `types` のみ
```yaml
generate:
  - types
```

**生成される内容:**
- `Components.Schemas.*` - OpenAPIスキーマから生成されるSwift構造体・列挙型
- リクエスト・レスポンス型定義
- エラー型定義

**生成されない内容:**
- クライアント実装クラス
- サーバー実装プロトコル
- HTTPメソッド呼び出し機能

**使用ケース:**
- 複数のライブラリで共通の型定義を使いたい場合
- 手動でHTTP通信を実装したい場合
- 型安全性のみが必要な場合

#### `types` + `client`
```yaml
generate:
  - types
  - client
```

**生成される内容:**
- 上記の型定義
- `Client` クラス - API呼び出し用のクライアント実装
- `Operations.*` - 各APIエンドポイント用の入力・出力型
- HTTPメソッド呼び出し機能

**使用ケース:**
- APIクライアントアプリケーション開発
- 最も一般的な使用パターン

#### `types` + `server`
```yaml
generate:
  - types
  - server
```

**生成される内容:**
- 型定義
- `APIProtocol` - 実装すべきサーバーAPIプロトコル
- サーバーハンドラー登録機能
- ルーティング機能

**使用ケース:**
- APIサーバー実装
- Vapor、Hummingbirdなどのサーバーフレームワークとの統合

#### `types` + `client` + `server`
```yaml
generate:
  - types
  - client
  - server
```

**生成される内容:**
- 全ての型定義
- クライアント実装
- サーバー実装プロトコル

**使用ケース:**
- フルスタック開発
- テスト環境でのモックサーバー実装

### 2. accessModifier オプション

#### `internal` (デフォルト)
```yaml
accessModifier: internal
```

**生成されるコード例:**
```swift
internal struct Pet {
    internal let id: Int64?
    internal let name: String
}

internal class Client {
    internal func getPetById(_ input: Operations.GetPetById.Input) async throws -> Operations.GetPetById.Output
}
```

**使用ケース:**
- モジュール内部でのみ使用
- アプリケーション内での使用

#### `public`
```yaml
accessModifier: public
```

**生成されるコード例:**
```swift
public struct Pet {
    public let id: Int64?
    public let name: String
}

public class Client {
    public func getPetById(_ input: Operations.GetPetById.Input) async throws -> Operations.GetPetById.Output
}
```

**使用ケース:**
- ライブラリとして他のモジュールに公開
- SPMパッケージとして配布

#### `package` (Swift 5.9+)
```yaml
accessModifier: package
```

**使用ケース:**
- パッケージ内の複数モジュール間での共有
- モジュール境界を超えた内部API

### 3. featureFlags オプション（実験的機能）

#### ExperimentalObjectOneOf
```yaml
featureFlags:
  - ExperimentalObjectOneOf
```

**影響:**
- OpenAPI 3.1の`oneOf`構文サポート
- より複雑な型定義の生成
- 条件付き型の実装

#### ExperimentalAllOf
```yaml
featureFlags:
  - ExperimentalAllOf
```

**影響:**
- `allOf`構文サポート
- 型の組み合わせと継承的構造
- より柔軟なスキーマ定義サポート

## 実際の生成コード比較

### Client生成時の主要クラス

```swift
// openapi-generator-config.yaml で generate: [types, client] の場合

public class Client {
    public init(serverURL: URL, transport: ClientTransport)
    
    // 各APIエンドポイントに対応するメソッド
    public func addPet(_ input: Operations.AddPet.Input) async throws -> Operations.AddPet.Output
    public func getPetById(_ input: Operations.GetPetById.Input) async throws -> Operations.GetPetById.Output
    public func updatePet(_ input: Operations.UpdatePet.Input) async throws -> Operations.UpdatePet.Output
    // ...その他のメソッド
}
```

### Server生成時の主要プロトコル

```swift
// openapi-generator-config.yaml で generate: [types, server] の場合

public protocol APIProtocol {
    func addPet(_ input: Operations.AddPet.Input) async throws -> Operations.AddPet.Output
    func getPetById(_ input: Operations.GetPetById.Input) async throws -> Operations.GetPetById.Output
    func updatePet(_ input: Operations.UpdatePet.Input) async throws -> Operations.UpdatePet.Output
    // ...その他のメソッド
}

// サーバー実装例
extension APIProtocol {
    public func registerHandlers(on transport: ServerTransport, serverURL: URL) throws {
        // ルーティング設定の自動生成
    }
}
```

## 設定による生成ファイル数の違い

### Types のみ
- 生成ファイル数: 約3-5ファイル
- 主要ファイル: `Types.swift`, `Components.swift`

### Types + Client  
- 生成ファイル数: 約8-12ファイル
- 追加ファイル: `Client.swift`, `Operations.swift`

### Types + Server
- 生成ファイル数: 約8-12ファイル  
- 追加ファイル: `APIProtocol.swift`, `ServerTransport.swift`

### Types + Client + Server
- 生成ファイル数: 約15-20ファイル
- 全ての実装ファイルが生成される

## パフォーマンスへの影響

### コンパイル時間
- Types のみ: 最高速
- Types + Client: 中程度
- Types + Server: 中程度  
- Types + Client + Server: 最も長い

### バイナリサイズ
- 生成オプションに比例してバイナリサイズが増加
- 使用しない機能は`generate`から除外することを推奨

## 推奨設定パターン

### iOS/macOSアプリ開発
```yaml
generate:
  - types
  - client
accessModifier: internal
```

### ライブラリ開発
```yaml
generate:
  - types
  - client
accessModifier: public
```

### サーバー開発
```yaml
generate:
  - types
  - server
accessModifier: public
```

### フルスタック開発・テスト環境
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

## まとめ

設定オプションの選択により、生成されるコードの量、アクセスレベル、機能が大きく変わります。
プロジェクトの要件に応じて適切な設定を選択することで、効率的な開発が可能になります。