import Foundation

// Book構造体の定義
public struct Book: Equatable, Comparable, Hashable, Identifiable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: UUID
    public let title: String
    public let author: String
    public let publishedYear: Int
    public let price: Double
    
    public init(id: UUID = UUID(), title: String, author: String, publishedYear: Int, price: Double) {
        self.id = id
        self.title = title
        self.author = author
        self.publishedYear = publishedYear
        self.price = price
    }
    
    // Equatableの明示的な実装
    public static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.title == rhs.title &&
               lhs.author == rhs.author &&
               lhs.publishedYear == rhs.publishedYear &&
               lhs.price == rhs.price
    }
    
    // Comparableの実装（タイトルのアルファベット順）
    public static func < (lhs: Book, rhs: Book) -> Bool {
        return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }
    
    // CustomStringConvertibleの実装
    public var description: String {
        return "\(title) by \(author) (\(publishedYear))"
    }
    
    // CustomDebugStringConvertibleの実装
    public var debugDescription: String {
        return "Book(id: \(id), title: \(title), author: \(author), publishedYear: \(publishedYear), price: \(price))"
    }
    
    // Hashableの実装（Equatableと同じ属性を使用）
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(author)
        hasher.combine(publishedYear)
        hasher.combine(price)
    }
}

// BookGenreの定義 (RawRepresentableとCaseIterableの例)
public enum BookGenre: String, CaseIterable {
    case fiction = "Fiction"
    case nonFiction = "Non-Fiction"
    case mystery = "Mystery"
    case scienceFiction = "Science Fiction"
    case fantasy = "Fantasy"
    
    public var description: String {
        return self.rawValue
    }
} 