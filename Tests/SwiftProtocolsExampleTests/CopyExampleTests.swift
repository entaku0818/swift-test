import XCTest
@testable import SwiftProtocolsExample

final class CopyExampleTests: XCTestCase {
    func testCopyable() {
        let originalDoc = Document(title: "Original", content: "Hello")
        let copiedDoc = originalDoc.copy()
        
        // コピー後の値が同じことを確認
        XCTAssertEqual(originalDoc.title, copiedDoc.title)
        XCTAssertEqual(originalDoc.content, copiedDoc.content)
        
        // コピーが独立していることを確認
        copiedDoc.title = "Modified"
        XCTAssertNotEqual(originalDoc.title, copiedDoc.title)
    }
    
    func testBitwiseCopyable() {
        let originalPoint = Point(x: 10.0, y: 20.0)
        let copiedPoint = originalPoint // 暗黙的にビットコピーが行われる
        
        // コピー後の値が同じことを確認
        XCTAssertEqual(originalPoint.x, copiedPoint.x)
        XCTAssertEqual(originalPoint.y, copiedPoint.y)
        
        // 構造体は値型なので、自動的に独立したコピーになる
        var modifiedPoint = copiedPoint
        modifiedPoint.x = 30.0
        XCTAssertNotEqual(originalPoint.x, modifiedPoint.x)
    }
} 