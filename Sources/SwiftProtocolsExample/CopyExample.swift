import Foundation

// Copyableの例
public class Document: Copyable {
    public var title: String
    public var content: String
    public var lastModified: Date
    
    public init(title: String, content: String, lastModified: Date = Date()) {
        self.title = title
        self.content = content
        self.lastModified = lastModified
    }
    
    // Copyableプロトコルの実装
    public func copy() -> Self {
        return Document(title: self.title,
                       content: self.content,
                       lastModified: self.lastModified) as! Self
    }
}

// BitwiseCopyableの例
public struct Point: BitwiseCopyable {
    public var x: Double
    public var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
} 