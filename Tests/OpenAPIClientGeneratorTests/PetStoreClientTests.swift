import XCTest
@testable import OpenAPIClientGenerator

final class PetStoreClientTests: XCTestCase {
    
    func testPetStoreErrorDescriptions() {
        // エラーメッセージのテスト
        XCTAssertEqual(PetStoreError.invalidInput.errorDescription, "無効な入力データです")
        XCTAssertEqual(PetStoreError.petNotFound.errorDescription, "ペットが見つかりません")
        XCTAssertEqual(PetStoreError.unexpectedResponse(statusCode: 500).errorDescription, "予期しないレスポンスです（ステータスコード: 500）")
    }
    
    func testPetStoreClientInitialization() {
        // クライアントの初期化テスト
        let client = PetStoreClient()
        XCTAssertNotNil(client)
        
        // カスタムURLでの初期化
        let customURL = URL(string: "https://api.example.com")!
        let customClient = PetStoreClient(serverURL: customURL)
        XCTAssertNotNil(customClient)
    }
    
    // NOTE: 実際のAPI呼び出しテストは、モックサーバーまたはテスト環境で実行する必要があります
    // 以下は、生成されたコードの型安全性をテストする例です
    
    func testPetModelCreation() {
        // ペットモデルの作成テスト
        let pet = Components.Schemas.Pet(
            id: 1,
            name: "Buddy",
            category: Components.Schemas.Category(id: 1, name: "Dogs"),
            photoUrls: ["https://example.com/photo.jpg"],
            tags: [Components.Schemas.Tag(id: 1, name: "friendly")],
            status: .available
        )
        
        XCTAssertEqual(pet.id, 1)
        XCTAssertEqual(pet.name, "Buddy")
        XCTAssertEqual(pet.category?.name, "Dogs")
        XCTAssertEqual(pet.photoUrls.first, "https://example.com/photo.jpg")
        XCTAssertEqual(pet.tags?.first?.name, "friendly")
        XCTAssertEqual(pet.status, .available)
    }
    
    func testUserModelCreation() {
        // ユーザーモデルの作成テスト
        let user = Components.Schemas.User(
            id: 1,
            username: "testuser",
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            password: "password",
            phone: "123-456-7890",
            userStatus: 1
        )
        
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.email, "test@example.com")
    }
    
    func testPetStatusEnum() {
        // ペットステータス列挙型のテスト
        let availableStatus: Components.Schemas.Pet.statusPayload = .available
        let pendingStatus: Components.Schemas.Pet.statusPayload = .pending
        let soldStatus: Components.Schemas.Pet.statusPayload = .sold
        
        XCTAssertEqual(availableStatus.rawValue, "available")
        XCTAssertEqual(pendingStatus.rawValue, "pending")
        XCTAssertEqual(soldStatus.rawValue, "sold")
    }
    
    func testCategoryModelCreation() {
        // カテゴリモデルの作成テスト
        let category = Components.Schemas.Category(id: 1, name: "Dogs")
        
        XCTAssertEqual(category.id, 1)
        XCTAssertEqual(category.name, "Dogs")
    }
    
    func testTagModelCreation() {
        // タグモデルの作成テスト
        let tag = Components.Schemas.Tag(id: 1, name: "friendly")
        
        XCTAssertEqual(tag.id, 1)
        XCTAssertEqual(tag.name, "friendly")
    }
    
    // MARK: - Integration Test Examples (要モックサーバー)
    
    /*
    func testPetStoreIntegration() async throws {
        // 実際のAPI呼び出しテスト（モックサーバー使用）
        let client = PetStoreClient(serverURL: URL(string: "http://localhost:8080")!)
        
        let pet = Components.Schemas.Pet(
            id: nil,
            name: "Test Pet",
            category: Components.Schemas.Category(id: 1, name: "Test Category"),
            photoUrls: ["https://example.com/photo.jpg"],
            tags: nil,
            status: .available
        )
        
        let addedPet = try await client.addPet(pet)
        XCTAssertEqual(addedPet.name, "Test Pet")
        XCTAssertNotNil(addedPet.id)
        
        if let petId = addedPet.id {
            let retrievedPet = try await client.getPet(by: petId)
            XCTAssertEqual(retrievedPet.name, "Test Pet")
            
            try await client.deletePet(id: petId)
        }
    }
    */
}