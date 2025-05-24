# Swift Protocols Example

このプロジェクトは、Swiftの基本的なプロトコルの実装例を示すサンプルコードです。

## 実装されているプロトコル

### Book構造体で実装されているプロトコル

1. **Equatable**
   - 値の等価性を比較するためのプロトコル
   - `==` 演算子による比較が可能

2. **Comparable**
   - 値の大小関係を比較するためのプロトコル
   - `<`, `<=`, `>=`, `>` 演算子による比較が可能

3. **Hashable**
   - ハッシュ値を生成するためのプロトコル
   - `Set`や`Dictionary`のキーとして使用可能

4. **Identifiable**
   - 安定した識別子を持つ型を定義するためのプロトコル
   - `id`プロパティを通じて一意の識別子を提供

5. **CustomStringConvertible**
   - カスタマイズされた文字列表現を提供するためのプロトコル
   - `description`プロパティで文字列表現を定義

6. **CustomDebugStringConvertible**
   - デバッグ用の文字列表現を提供するためのプロトコル
   - `debugDescription`プロパティでデバッグ用の文字列表現を定義

### BookGenre列挙型で実装されているプロトコル

1. **RawRepresentable**
   - 生の値（この場合は文字列）との相互変換が可能
   - `rawValue`プロパティで生の値にアクセス可能

2. **CaseIterable**
   - すべてのケースを列挙可能
   - `allCases`プロパティで全ケースにアクセス可能

## 使用例

```swift
// 本の作成
let book = Book(
    title: "Swift Programming",
    author: "John Doe",
    publishedYear: 2024,
    price: 29.99
)

// 文字列表現の取得
print(book) // "Swift Programming by John Doe (2024)"

// Set での使用
var bookSet = Set<Book>()
bookSet.insert(book)

// ジャンルの使用
let genre = BookGenre.fiction
print(genre.rawValue) // "Fiction"
```

## テスト

プロジェクトには各プロトコルの実装をテストするための包括的なテストスイートが含まれています。
テストを実行するには以下のコマンドを使用してください：

```bash
swift test
``` 