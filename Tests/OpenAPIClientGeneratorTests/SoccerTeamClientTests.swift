import XCTest
@testable import OpenAPIClientGenerator

final class SoccerTeamClientTests: XCTestCase {
    
    func testSoccerTeamErrorDescriptions() {
        // エラーメッセージのテスト
        XCTAssertEqual(SoccerTeamError.invalidInput.errorDescription, "無効な入力データです")
        XCTAssertEqual(SoccerTeamError.playerNotFound.errorDescription, "選手が見つかりません")
        XCTAssertEqual(SoccerTeamError.teamNotFound.errorDescription, "チームが見つかりません")
        XCTAssertEqual(SoccerTeamError.matchNotFound.errorDescription, "試合が見つかりません")
        XCTAssertEqual(SoccerTeamError.invalidLineup.errorDescription, "無効なラインナップです（選手数が不正など）")
        XCTAssertEqual(SoccerTeamError.invalidResult.errorDescription, "無効な試合結果データです")
        XCTAssertEqual(SoccerTeamError.unexpectedResponse(statusCode: 500).errorDescription, "予期しないレスポンスです（ステータスコード: 500）")
    }
    
    func testSoccerTeamClientInitialization() {
        // クライアントの初期化テスト
        let client = SoccerTeamClient()
        XCTAssertNotNil(client)
        
        // カスタムURLでの初期化
        let customURL = URL(string: "https://api.example.com")!
        let customClient = SoccerTeamClient(serverURL: customURL)
        XCTAssertNotNil(customClient)
    }
    
    // NOTE: 実際のAPI呼び出しテストは、モックサーバーまたはテスト環境で実行する必要があります
    // 以下は、生成されたコードの型安全性をテストする例です
    
    func testPlayerModelCreation() {
        // 選手モデルの作成テスト
        let player = Components.Schemas.Player(
            id: 1,
            name: "山田太郎",
            position: .FW,
            jerseyNumber: 10,
            dateOfBirth: "1995-04-15",
            nationality: "Japan",
            height: 175.5,
            weight: 68.0,
            status: .active,
            teamId: 1,
            stats: Components.Schemas.PlayerStats(
                goals: 12,
                assists: 8,
                yellowCards: 3,
                redCards: 0,
                appearances: 25
            )
        )
        
        XCTAssertEqual(player.id, 1)
        XCTAssertEqual(player.name, "山田太郎")
        XCTAssertEqual(player.position, .FW)
        XCTAssertEqual(player.jerseyNumber, 10)
        XCTAssertEqual(player.nationality, "Japan")
        XCTAssertEqual(player.height, 175.5)
        XCTAssertEqual(player.weight, 68.0)
        XCTAssertEqual(player.status, .active)
        XCTAssertEqual(player.teamId, 1)
        XCTAssertEqual(player.stats?.goals, 12)
        XCTAssertEqual(player.stats?.assists, 8)
    }
    
    func testTeamModelCreation() {
        // チームモデルの作成テスト
        let team = Components.Schemas.Team(
            id: 1,
            name: "FC東京",
            foundedYear: 1998,
            homeStadium: "味の素スタジアム",
            league: "J1リーグ",
            manager: "鈴木一郎",
            players: nil
        )
        
        XCTAssertEqual(team.id, 1)
        XCTAssertEqual(team.name, "FC東京")
        XCTAssertEqual(team.foundedYear, 1998)
        XCTAssertEqual(team.homeStadium, "味の素スタジアム")
        XCTAssertEqual(team.league, "J1リーグ")
        XCTAssertEqual(team.manager, "鈴木一郎")
    }
    
    func testPositionEnum() {
        // ポジション列挙型のテスト
        let goalkeeper: Components.Schemas.Position = .GK
        let defender: Components.Schemas.Position = .DF
        let midfielder: Components.Schemas.Position = .MF
        let forward: Components.Schemas.Position = .FW
        
        XCTAssertEqual(goalkeeper.rawValue, "GK")
        XCTAssertEqual(defender.rawValue, "DF")
        XCTAssertEqual(midfielder.rawValue, "MF")
        XCTAssertEqual(forward.rawValue, "FW")
    }
    
    func testPlayerStatusEnum() {
        // 選手ステータス列挙型のテスト
        let active: Components.Schemas.Player.statusPayload = .active
        let injured: Components.Schemas.Player.statusPayload = .injured
        let suspended: Components.Schemas.Player.statusPayload = .suspended
        
        XCTAssertEqual(active.rawValue, "active")
        XCTAssertEqual(injured.rawValue, "injured")
        XCTAssertEqual(suspended.rawValue, "suspended")
    }
    
    func testLineupModelCreation() {
        // ラインナップモデルの作成テスト
        let lineup = Components.Schemas.Lineup(
            id: 1,
            formation: "4-4-2",
            playerIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
            substituteIds: [12, 13, 14, 15, 16],
            captain: 5
        )
        
        XCTAssertEqual(lineup.formation, "4-4-2")
        XCTAssertEqual(lineup.playerIds.count, 11)
        XCTAssertEqual(lineup.substituteIds?.count, 5)
        XCTAssertEqual(lineup.captain, 5)
    }
    
    func testMatchModelCreation() {
        // 試合モデルの作成テスト
        let matchDate = ISO8601DateFormatter().date(from: "2024-03-20T19:00:00Z")!
        
        let match = Components.Schemas.Match(
            id: 1,
            homeTeamId: 1,
            awayTeamId: 2,
            scheduledDate: matchDate,
            venue: "東京スタジアム",
            status: .scheduled,
            result: nil
        )
        
        XCTAssertEqual(match.id, 1)
        XCTAssertEqual(match.homeTeamId, 1)
        XCTAssertEqual(match.awayTeamId, 2)
        XCTAssertEqual(match.venue, "東京スタジアム")
        XCTAssertEqual(match.status, .scheduled)
        XCTAssertNil(match.result)
    }
    
    func testMatchResultModelCreation() {
        // 試合結果モデルの作成テスト
        let result = Components.Schemas.MatchResult(
            homeScore: 2,
            awayScore: 1,
            scorers: [
                Components.Schemas.Goal(
                    playerId: 9,
                    minute: 23,
                    assistPlayerId: 10,
                    _type: .regular
                ),
                Components.Schemas.Goal(
                    playerId: 11,
                    minute: 67,
                    assistPlayerId: nil,
                    _type: .penalty
                )
            ]
        )
        
        XCTAssertEqual(result.homeScore, 2)
        XCTAssertEqual(result.awayScore, 1)
        XCTAssertEqual(result.scorers?.count, 2)
        XCTAssertEqual(result.scorers?[0].playerId, 9)
        XCTAssertEqual(result.scorers?[0]._type, .regular)
        XCTAssertEqual(result.scorers?[1]._type, .penalty)
    }
    
    func testGoalTypeEnum() {
        // ゴールタイプ列挙型のテスト
        let regular: Components.Schemas.Goal._typePayload = .regular
        let penalty: Components.Schemas.Goal._typePayload = .penalty
        let ownGoal: Components.Schemas.Goal._typePayload = .own_goal
        let freeKick: Components.Schemas.Goal._typePayload = .free_kick
        
        XCTAssertEqual(regular.rawValue, "regular")
        XCTAssertEqual(penalty.rawValue, "penalty")
        XCTAssertEqual(ownGoal.rawValue, "own_goal")
        XCTAssertEqual(freeKick.rawValue, "free_kick")
    }
    
    // MARK: - Integration Test Examples (要モックサーバー)
    
    /*
    func testSoccerTeamIntegration() async throws {
        // 実際のAPI呼び出しテスト（モックサーバー使用）
        let client = SoccerTeamClient(serverURL: URL(string: "http://localhost:8080")!)
        
        let player = Components.Schemas.Player(
            id: nil,
            name: "テスト選手",
            position: .FW,
            jerseyNumber: 99,
            dateOfBirth: "2000-01-01",
            nationality: "Japan",
            height: 180.0,
            weight: 75.0,
            status: .active,
            teamId: 1,
            stats: nil
        )
        
        let addedPlayer = try await client.addPlayer(player)
        XCTAssertEqual(addedPlayer.name, "テスト選手")
        XCTAssertNotNil(addedPlayer.id)
        
        if let playerId = addedPlayer.id {
            let retrievedPlayer = try await client.getPlayer(by: playerId)
            XCTAssertEqual(retrievedPlayer.name, "テスト選手")
            
            try await client.deletePlayer(id: playerId)
        }
    }
    */
}