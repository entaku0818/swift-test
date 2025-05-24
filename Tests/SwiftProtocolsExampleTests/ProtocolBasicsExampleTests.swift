import XCTest
@testable import SwiftProtocolsExample

final class ProtocolBasicsExampleTests: XCTestCase {
    // テストデータ
    var book1: Book!
    var book2: Book!
    var book3: Book!
    var book4: Book!
    
    override func setUp() {
        super.setUp()
        book1 = Book(title: "Swift Programming", author: "John Doe", publishedYear: 2024, price: 29.99)
        book2 = Book(title: "Swift Programming", author: "John Doe", publishedYear: 2024, price: 29.99)
        book3 = Book(title: "Advanced Swift", author: "Jane Smith", publishedYear: 2024, price: 39.99)
        book4 = Book(title: "Basic Swift", author: "Bob Wilson", publishedYear: 2023, price: 19.99)
    }
    
    // MARK: - Equatableのメリットを示すテスト
    
    func testEquatableForValueComparison() {
        // 1. 同じ値を持つ本は等しいと判定される
        XCTAssertEqual(book1, book2)
        XCTAssertNotEqual(book1, book3)
        
        // 2. 配列での検索が簡単
        let books = [book1, book2, book3]
        XCTAssertTrue(books.contains(book1))
        XCTAssertFalse(books.contains(book4))
        
        // 3. firstIndexが使える
        XCTAssertEqual(books.firstIndex(of: book1), 0)
        
        // 4. filter操作が簡単
        let filteredBooks = books.filter { $0 == book1 }
        XCTAssertEqual(filteredBooks.count, 2) // book1とbook2が該当
    }
    
    func testEquatableInCollections() {
        // 1. 配列での重複チェック
        let books = [book1, book2, book3]
        let uniqueBooks = Array(Set(books)) // Setを使用して重複を排除
        XCTAssertEqual(uniqueBooks.count, 2) // book1とbook2は同じと判定される
        
        // 2. Dictionaryでの使用
        var bookStatus = [Book: String]()
        bookStatus[book1] = "Available"
        XCTAssertEqual(bookStatus[book2], "Available") // book1とbook2は同じキーとして扱われる
    }
    
    // MARK: - Comparableのメリットを示すテスト
    
    func testComparableForSorting() {
        // 1. 本の並び替え（タイトルのアルファベット順）
        let books = [book3, book4, book1] as [Book]
        let sortedBooks = books.sorted()
        
        // Advanced Swift, Basic Swift, Swift Programming の順になるはず
        XCTAssertEqual(sortedBooks[0], book3) // Advanced Swift
        XCTAssertEqual(sortedBooks[1], book4) // Basic Swift
        XCTAssertEqual(sortedBooks[2], book1) // Swift Programming
    }
    
    func testComparableOperators() {
        // 1. 比較演算子の使用（タイトルのアルファベット順）
        XCTAssertLessThan(book3, book4) // "Advanced Swift" < "Basic Swift"
        XCTAssertGreaterThan(book1, book3) // "Swift Programming" > "Advanced Swift"
        XCTAssertLessThanOrEqual(book1, book2) // 同じタイトルは等しい
        XCTAssertGreaterThanOrEqual(book1, book2) // 同じタイトルは等しい
        
        // 2. min/maxの使用
        let books = [book1, book3, book4] as [Book]
        XCTAssertEqual(books.min(), book3) // "Advanced Swift"が最小
        XCTAssertEqual(books.max(), book1) // "Swift Programming"が最大
    }
    
    func testComparableRanges() {
        // 1. 範囲での検索（タイトルのアルファベット順）
        let books = [book1, book2, book3, book4] as [Book]
        let range = book3...book4 // "Advanced Swift" から "Basic Swift" まで
        
        let booksInRange = books.filter { range.contains($0) }
        XCTAssertEqual(booksInRange.count, 2)
        XCTAssertTrue(booksInRange.contains(book3))
        XCTAssertTrue(booksInRange.contains(book4))
    }
    
    // MARK: - Identifiableのメリットを示すテスト
    
    func testIdentifiableUniqueness() {
        // 1. 同じ内容でも異なるIDを持つ
        let book1Copy = Book(title: book1.title, author: book1.author, publishedYear: book1.publishedYear, price: book1.price)
        XCTAssertNotEqual(book1.id, book1Copy.id)
        
        // 2. 同じ内容の本は同じハッシュ値を持つ（Hashableの実装による）
        let bookSet = Set([book1, book1Copy])
        XCTAssertEqual(bookSet.count, 1) // 同じ内容の本は1つとしてカウント
    }
    
    func testIdentifiableInCollections() {
        // 1. IDベースの辞書管理
        var bookInventory = [Book.ID: Int]() // ID -> 在庫数
        bookInventory[book1.id] = 5
        bookInventory[book2.id] = 3
        
        XCTAssertNotEqual(bookInventory[book1.id], bookInventory[book2.id])
        
        // 2. IDベースの検索
        let books = [book1, book2, book3] as [Book]
        let found = books.first { $0.id == book1.id }
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.title, book1.title)
    }
    
    func testIdentifiableForDataTracking() {
        // 1. 変更追跡のシミュレーション
        var modifiedBooks = Set<Book.ID>()
        
        // 本の状態が変更されたと仮定
        modifiedBooks.insert(book1.id)
        modifiedBooks.insert(book2.id)
        modifiedBooks.insert(book2.id) // 同じIDの重複を試みる
        
        XCTAssertEqual(modifiedBooks.count, 2) // 重複は自動的に排除される
        XCTAssertTrue(modifiedBooks.contains(book1.id))
    }
    
    func testCustomStringConvertible() {
        let book = Book(title: "Swift Programming", author: "John Doe", publishedYear: 2024, price: 29.99)
        XCTAssertEqual(book.description, "Swift Programming by John Doe (2024)")
    }
    
    func testCustomDebugStringConvertible() {
        let book = Book(title: "Swift Programming", author: "John Doe", publishedYear: 2024, price: 29.99)
        let debugDescription = book.debugDescription
        XCTAssertTrue(debugDescription.contains("Swift Programming"))
        XCTAssertTrue(debugDescription.contains("John Doe"))
        XCTAssertTrue(debugDescription.contains("2024"))
        XCTAssertTrue(debugDescription.contains("29.99"))
    }
    
    func testBookGenre() {
        // CaseIterableのテスト
        XCTAssertEqual(BookGenre.allCases.count, 5)
        
        // RawRepresentableのテスト
        XCTAssertEqual(BookGenre.fiction.rawValue, "Fiction")
        XCTAssertEqual(BookGenre.nonFiction.rawValue, "Non-Fiction")
        
        // 文字列からの初期化テスト
        XCTAssertEqual(BookGenre(rawValue: "Mystery"), .mystery)
        XCTAssertNil(BookGenre(rawValue: "Invalid Genre"))
    }
} 