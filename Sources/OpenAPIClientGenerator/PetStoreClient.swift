import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// PetStore API クライアント実装の例
public class PetStoreClient {
    private let client: Client
    
    public init(serverURL: URL = URL(string: "https://petstore3.swagger.io/api/v3")!) {
        // URLSessionベースのトランスポート層を使用
        let transport = URLSessionTransport()
        
        // OpenAPI生成されたクライアントを初期化
        self.client = Client(
            serverURL: serverURL,
            transport: transport
        )
    }
    
    /// ペットを追加する
    public func addPet(_ pet: Components.Schemas.Pet) async throws -> Components.Schemas.Pet {
        let response = try await client.addPet(.init(body: .json(pet)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pet):
                return pet
            }
        case .badRequest:
            throw PetStoreError.invalidInput
        case .undocumented(let statusCode, _):
            throw PetStoreError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// ペットIDでペットを取得する
    public func getPet(by id: Int64) async throws -> Components.Schemas.Pet {
        let response = try await client.getPetById(.init(path: .init(petId: id)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pet):
                return pet
            }
        case .badRequest:
            throw PetStoreError.invalidID
        case .notFound:
            throw PetStoreError.petNotFound
        case .undocumented(let statusCode, _):
            throw PetStoreError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// ステータスでペットを検索する
    public func findPets(by status: Operations.findPetsByStatus.Input.Query.statusPayload = .available) async throws -> [Components.Schemas.Pet] {
        let response = try await client.findPetsByStatus(.init(query: .init(status: status)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let pets):
                return pets
            }
        case .badRequest:
            throw PetStoreError.invalidStatus
        case .undocumented(let statusCode, _):
            throw PetStoreError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// ペットを更新する
    public func updatePet(id: Int64, pet: Components.Schemas.Pet) async throws -> Components.Schemas.Pet {
        let response = try await client.updatePet(.init(
            path: .init(petId: id),
            body: .json(pet)
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let updatedPet):
                return updatedPet
            }
        case .badRequest:
            throw PetStoreError.invalidID
        case .notFound:
            throw PetStoreError.petNotFound
        case .unprocessableContent:
            throw PetStoreError.validationError
        case .undocumented(let statusCode, _):
            throw PetStoreError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// ペットを削除する
    public func deletePet(id: Int64) async throws {
        let response = try await client.deletePet(.init(path: .init(petId: id)))
        
        switch response {
        case .badRequest:
            throw PetStoreError.invalidPetValue
        case .undocumented(let statusCode, _):
            throw PetStoreError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// ユーザーを作成する
    public func createUser(_ user: Components.Schemas.User) async throws {
        let response = try await client.createUser(.init(body: .json(user)))
        
        switch response {
        case .default(let statusCode, _):
            // 成功時の処理（デフォルトレスポンス）
            if statusCode >= 200 && statusCode < 300 {
                // 成功
                return
            } else {
                throw PetStoreError.unexpectedResponse(statusCode: statusCode)
            }
        }
    }
    
    /// ユーザーログイン
    public func loginUser(username: String, password: String) async throws -> String {
        let response = try await client.loginUser(.init(query: .init(
            username: username,
            password: password
        )))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let token):
                return token
            }
        case .badRequest:
            throw PetStoreError.invalidCredentials
        case .undocumented(let statusCode, _):
            throw PetStoreError.unexpectedResponse(statusCode: statusCode)
        }
    }
}

/// PetStore API エラー型
public enum PetStoreError: Error, LocalizedError {
    case invalidInput
    case invalidID
    case petNotFound
    case invalidStatus
    case validationError
    case invalidPetValue
    case invalidCredentials
    case unexpectedResponse(statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "無効な入力データです"
        case .invalidID:
            return "無効なIDです"
        case .petNotFound:
            return "ペットが見つかりません"
        case .invalidStatus:
            return "無効なステータスです"
        case .validationError:
            return "バリデーションエラーです"
        case .invalidPetValue:
            return "無効なペット値です"
        case .invalidCredentials:
            return "無効な認証情報です"
        case .unexpectedResponse(let statusCode):
            return "予期しないレスポンスです（ステータスコード: \(statusCode)）"
        }
    }
}