import XCTest
@testable import SwiftProtocolsExample

final class BookTests: XCTestCase {
    func testEquatable() {
        let book1 = Book(title: "Swift Programming", author: "John Doe", publishedYear: 2024, price: 29.99)
        let book2 = Book(title: "Swift Programming", author: "John Doe", publishedYear: 2024, price: 29.99)
        let book3 = Book(title: "Different Book", author: "Jane Smith", publishedYear: 2024, price: 19.99)
        
        XCTAssertEqual(book1, book2)
        XCTAssertNotEqual(book1, book3)
    }
    
    func testComparable() {
        let book1 = Book(title: "A Book", author: "Author A", publishedYear: 2024, price: 29.99)
        let book2 = Book(title: "B Book", author: "Author B", publishedYear: 2023, price: 19.99)
        
        XCTAssertLessThan(book1, book2)
        XCTAssertGreaterThan(book2, book1)
    }
    
    func testHashable() {
        let book1 = Book(title: "Swift Programming", author: "John Doe", publishedYear: 2024, price: 29.99)
        let book2 = Book(title: "Different Book", author: "Jane Smith", publishedYear: 2024, price: 19.99)
        
        var bookSet = Set<Book>()
        bookSet.insert(book1)
        bookSet.insert(book2)
        
        XCTAssertEqual(bookSet.count, 2)
        XCTAssertTrue(bookSet.contains(book1))
    }
    
    func testIdentifiable() {
        let book = Book(title: "Swift Programming", author: "John Doe", publishedYear: 2024, price: 29.99)
        XCTAssertNotNil(book.id)
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