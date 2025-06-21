import Foundation

/// PetStore API クライアント使用例
public class PetStoreUsageExample {
    
    /// 基本的な使用例
    public static func basicUsageExample() async {
        // クライアントを初期化
        let client = PetStoreClient()
        
        do {
            // 新しいペットを作成
            let newPet = Components.Schemas.Pet(
                id: nil,
                name: "Buddy",
                category: Components.Schemas.Category(id: 1, name: "Dogs"),
                photoUrls: ["https://example.com/buddy.jpg"],
                tags: [
                    Components.Schemas.Tag(id: 1, name: "friendly"),
                    Components.Schemas.Tag(id: 2, name: "playful")
                ],
                status: .available
            )
            
            // ペットを追加
            let addedPet = try await client.addPet(newPet)
            print("ペットが追加されました: \(addedPet.name)")
            
            // ペットIDで取得
            if let petId = addedPet.id {
                let retrievedPet = try await client.getPet(by: petId)
                print("取得されたペット: \(retrievedPet.name)")
            }
            
            // ステータスで検索
            let availablePets = try await client.findPets(by: .available)
            print("利用可能なペット数: \(availablePets.count)")
            
        } catch {
            print("エラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// エラーハンドリングの例
    public static func errorHandlingExample() async {
        let client = PetStoreClient()
        
        do {
            // 存在しないペットを取得しようとする
            let _ = try await client.getPet(by: 999999)
            
        } catch PetStoreError.petNotFound {
            print("ペットが見つかりませんでした")
            
        } catch PetStoreError.invalidID {
            print("無効なIDが指定されました")
            
        } catch PetStoreError.unexpectedResponse(let statusCode) {
            print("予期しないレスポンス（ステータス: \(statusCode)）")
            
        } catch {
            print("その他のエラー: \(error)")
        }
    }
    
    /// ユーザー操作の例
    public static func userOperationsExample() async {
        let client = PetStoreClient()
        
        do {
            // 新しいユーザーを作成
            let newUser = Components.Schemas.User(
                id: nil,
                username: "testuser",
                firstName: "Test",
                lastName: "User",
                email: "test@example.com",
                password: "securepassword",
                phone: "123-456-7890",
                userStatus: 1
            )
            
            // ユーザーを作成
            try await client.createUser(newUser)
            print("ユーザーが作成されました")
            
            // ログイン
            let token = try await client.loginUser(
                username: "testuser",
                password: "securepassword"
            )
            print("ログイン成功、トークン: \(token)")
            
        } catch {
            print("ユーザー操作でエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// 複数操作を組み合わせた例
    public static func complexOperationsExample() async {
        let client = PetStoreClient()
        
        do {
            // 1. 新しいペットを追加
            let pet = Components.Schemas.Pet(
                id: nil,
                name: "Max",
                category: Components.Schemas.Category(id: 2, name: "Cats"),
                photoUrls: ["https://example.com/max.jpg"],
                tags: [Components.Schemas.Tag(id: 3, name: "indoor")],
                status: .available
            )
            
            let addedPet = try await client.addPet(pet)
            print("ペット追加完了: ID \(addedPet.id ?? 0)")
            
            guard let petId = addedPet.id else { return }
            
            // 2. ペット情報を更新
            var updatedPet = addedPet
            updatedPet.status = .pending
            updatedPet.tags?.append(Components.Schemas.Tag(id: 4, name: "reserved"))
            
            let finalPet = try await client.updatePet(id: petId, pet: updatedPet)
            print("ペット更新完了: ステータス \(finalPet.status?.rawValue ?? "unknown")")
            
            // 3. pending状態のペットを検索（正しい型を使用）
            let pendingPets = try await client.findPets(by: .pending)
            print("保留中のペット数: \(pendingPets.count)")
            
            // 4. ペットを削除
            try await client.deletePet(id: petId)
            print("ペット削除完了")
            
        } catch {
            print("複合操作でエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// 並行処理の例
    public static func concurrentOperationsExample() async {
        let client = PetStoreClient()
        
        await withTaskGroup(of: Void.self) { group in
            // 複数のステータスで並行検索
            group.addTask {
                do {
                    let available = try await client.findPets(by: .available)
                    print("利用可能: \(available.count)匹")
                } catch {
                    print("利用可能ペット取得エラー: \(error)")
                }
            }
            
            group.addTask {
                do {
                    let pending = try await client.findPets(by: .pending)
                    print("保留中: \(pending.count)匹")
                } catch {
                    print("保留中ペット取得エラー: \(error)")
                }
            }
            
            group.addTask {
                do {
                    let sold = try await client.findPets(by: .sold)
                    print("売約済み: \(sold.count)匹")
                } catch {
                    print("売約済みペット取得エラー: \(error)")
                }
            }
        }
    }
}