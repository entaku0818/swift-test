import XCTest
@testable import SwiftProtocolsExample

final class HashExampleTests: XCTestCase {
    var school: School!
    var student1: Student!
    var student2: Student!
    var student3: Student!
    
    override func setUp() {
        super.setUp()
        school = School()
        student1 = Student(id: 1, name: "Alice", grade: 1)
        student2 = Student(id: 2, name: "Bob", grade: 2)
        student3 = Student(id: 3, name: "Charlie", grade: 1)
    }
    
    func testHashableEquality() {
        // 同じ値を持つ2つのStudentインスタンスを作成
        let student1a = Student(id: 1, name: "Alice", grade: 1)
        let student1b = Student(id: 1, name: "Alice", grade: 2) // gradeが異なる
        
        // Equatableの実装では、idとnameのみを比較
        XCTAssertEqual(student1, student1a)
        XCTAssertEqual(student1, student1b) // gradeは比較に含まれない
        XCTAssertNotEqual(student1, student2)
    }
    
    func testSetOperations() {
        // Setへの追加
        school.addStudent(student1)
        school.addStudent(student2)
        school.addStudent(student3)
        
        // 重複する要素は追加されない
        let duplicateStudent = Student(id: 1, name: "Alice", grade: 1)
        school.addStudent(duplicateStudent)
        
        XCTAssertEqual(school.studentCount, 3)
        XCTAssertTrue(school.hasStudent(student1))
        
        // 特定の学年の生徒を取得
        let grade1Students = school.studentsInGrade(1)
        XCTAssertEqual(grade1Students.count, 2)
        XCTAssertTrue(grade1Students.contains(student1))
        XCTAssertTrue(grade1Students.contains(student3))
    }
    
    func testDictionaryOperations() {
        // 生徒を追加
        school.addStudent(student1)
        school.addStudent(student2)
        
        // 成績を設定
        school.setGrade(for: student1, grade: "A")
        school.setGrade(for: student2, grade: "B")
        
        // 成績を取得
        XCTAssertEqual(school.getGrade(for: student1), "A")
        XCTAssertEqual(school.getGrade(for: student2), "B")
        
        // 存在しない生徒の成績を取得
        XCTAssertNil(school.getGrade(for: student3))
    }
    
    func testHasherCombine() {
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        
        // 同じ値を持つ2つの異なるStudentインスタンス
        let studentA = Student(id: 1, name: "Alice", grade: 1)
        let studentB = Student(id: 1, name: "Alice", grade: 2)
        
        // ハッシュ値を生成
        studentA.hash(into: &hasher1)
        studentB.hash(into: &hasher2)
        
        // gradeは異なるが、ハッシュ値は同じになる（idとnameのみを使用）
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }
    
    // MARK: - テストデータ
    struct Product: Hashable {
        let id: String
        let name: String
        let price: Double
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Product, rhs: Product) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    struct Order: Hashable {
        let orderId: String
        let userId: String
        let products: Set<Product>
        let orderDate: Date
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(orderId)
        }
        
        static func == (lhs: Order, rhs: Order) -> Bool {
            return lhs.orderId == rhs.orderId
        }
    }
    
    // MARK: - 重複排除のテスト
    func testDuplicateElimination() {
        // 商品データ
        let product1 = Product(id: "1", name: "iPhone", price: 999.99)
        let product2 = Product(id: "1", name: "iPhone (Refurbished)", price: 899.99) // 同じID
        let product3 = Product(id: "2", name: "iPad", price: 799.99)
        
        // 商品カタログ（重複を排除）
        let catalog = Set([product1, product2, product3])
        XCTAssertEqual(catalog.count, 2) // product1とproduct2は同じIDなので1つとしてカウント
        XCTAssertTrue(catalog.contains(product1))
    }
    
    // MARK: - 高速検索のテスト
    func testFastLookup() {
        let products = Set([
            Product(id: "1", name: "iPhone", price: 999.99),
            Product(id: "2", name: "iPad", price: 799.99),
            Product(id: "3", name: "MacBook", price: 1299.99)
        ])
        
        // 存在する商品の検索
        let searchProduct = Product(id: "2", name: "", price: 0) // 名前と価格が異なっても、IDが同じなら同じ商品
        XCTAssertTrue(products.contains(searchProduct))
        
        // 存在しない商品の検索
        let nonExistentProduct = Product(id: "4", name: "AirPods", price: 199.99)
        XCTAssertFalse(products.contains(nonExistentProduct))
    }
    
    // MARK: - キャッシュ実装のテスト
    func testCaching() {
        // 簡易的なキャッシュシステム
        var cache: [Product: Int] = [:] // 商品の在庫数をキャッシュ
        
        let product = Product(id: "1", name: "iPhone", price: 999.99)
        cache[product] = 100 // 在庫数を設定
        
        // キャッシュから値を取得
        XCTAssertEqual(cache[product], 100)
        
        // 同じIDの商品でも取得可能
        let sameProduct = Product(id: "1", name: "iPhone (Different Name)", price: 888.88)
        XCTAssertEqual(cache[sameProduct], 100)
    }
    
    // MARK: - データ集計のテスト
    func testAggregation() {
        let now = Date()
        
        // 注文データ
        let order1 = Order(orderId: "1", userId: "user1", products: [
            Product(id: "1", name: "iPhone", price: 999.99),
            Product(id: "2", name: "iPad", price: 799.99)
        ], orderDate: now)
        
        let order2 = Order(orderId: "2", userId: "user1", products: [
            Product(id: "1", name: "iPhone", price: 999.99), // 重複商品
            Product(id: "3", name: "MacBook", price: 1299.99)
        ], orderDate: now)
        
        // ユーザーが購入した一意の商品を取得
        let allProducts = order1.products.union(order2.products)
        XCTAssertEqual(allProducts.count, 3) // 重複を除いた商品数
        
        // 注文セットを使用した操作
        let orders = Set([order1, order2])
        XCTAssertEqual(orders.count, 2)
    }
    
    // MARK: - データ整合性チェックのテスト
    func testDataIntegrity() {
        // ユーザーIDと注文の対応を管理
        var userOrders: [String: Set<Order>] = [:]
        let userId = "user1"
        let now = Date()
        
        // 注文を追加
        let order1 = Order(orderId: "1", userId: userId, products: [], orderDate: now)
        let order2 = Order(orderId: "2", userId: userId, products: [], orderDate: now)
        let duplicateOrder = Order(orderId: "1", userId: userId, products: [], orderDate: now) // 重複する注文ID
        
        // ユーザーの注文セットを初期化
        userOrders[userId] = Set([order1, order2, duplicateOrder])
        
        // 重複する注文IDは1つとしてカウント
        XCTAssertEqual(userOrders[userId]?.count, 2)
    }
    
    // MARK: - セット操作のテスト
    func testAdvancedSetOperations() {
        let now = Date()
        
        // 2つの注文セット
        let orderSet1 = Set([
            Order(orderId: "1", userId: "user1", products: [], orderDate: now),
            Order(orderId: "2", userId: "user1", products: [], orderDate: now)
        ])
        
        let orderSet2 = Set([
            Order(orderId: "2", userId: "user1", products: [], orderDate: now),
            Order(orderId: "3", userId: "user1", products: [], orderDate: now)
        ])
        
        // 和集合（全ての注文）
        let allOrders = orderSet1.union(orderSet2)
        XCTAssertEqual(allOrders.count, 3)
        
        // 積集合（共通の注文）
        let commonOrders = orderSet1.intersection(orderSet2)
        XCTAssertEqual(commonOrders.count, 1)
        
        // 差集合（orderSet1固有の注文）
        let uniqueToSet1 = orderSet1.subtracting(orderSet2)
        XCTAssertEqual(uniqueToSet1.count, 1)
    }
} 