import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// サッカーチーム管理API クライアント実装
public class SoccerTeamClient {
    private let client: Client
    
    public init(serverURL: URL = URL(string: "https://api.soccerteam.example.com/v1")!) {
        // URLSessionベースのトランスポート層を使用
        let transport = URLSessionTransport()
        
        // OpenAPI生成されたクライアントを初期化
        self.client = Client(
            serverURL: serverURL,
            transport: transport
        )
    }
    
    // MARK: - 選手管理
    
    /// 新しい選手を登録する
    public func addPlayer(_ player: Components.Schemas.Player) async throws -> Components.Schemas.Player {
        let response = try await client.addPlayer(.init(body: .json(player)))
        
        switch response {
        case .created(let createdResponse):
            switch createdResponse.body {
            case .json(let player):
                return player
            }
        case .badRequest:
            throw SoccerTeamError.invalidInput
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// 選手一覧を取得する
    public func getPlayers(position: Components.Schemas.Position? = nil, 
                          status: Operations.getPlayers.Input.Query.statusPayload? = nil) async throws -> [Components.Schemas.Player] {
        let response = try await client.getPlayers(.init(query: .init(
            position: position,
            status: status
        )))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let players):
                return players
            }
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// 選手IDで選手情報を取得する
    public func getPlayer(by id: Int64) async throws -> Components.Schemas.Player {
        let response = try await client.getPlayerById(.init(path: .init(playerId: id)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let player):
                return player
            }
        case .notFound:
            throw SoccerTeamError.playerNotFound
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// 選手情報を更新する
    public func updatePlayer(id: Int64, player: Components.Schemas.Player) async throws -> Components.Schemas.Player {
        let response = try await client.updatePlayer(.init(
            path: .init(playerId: id),
            body: .json(player)
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let updatedPlayer):
                return updatedPlayer
            }
        case .notFound:
            throw SoccerTeamError.playerNotFound
        case .badRequest:
            throw SoccerTeamError.invalidInput
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// 選手を削除する（退団処理）
    public func deletePlayer(id: Int64) async throws {
        let response = try await client.deletePlayer(.init(path: .init(playerId: id)))
        
        switch response {
        case .noContent:
            // 削除成功
            return
        case .notFound:
            throw SoccerTeamError.playerNotFound
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    // MARK: - チーム管理
    
    /// 新しいチームを作成する
    public func createTeam(_ team: Components.Schemas.Team) async throws -> Components.Schemas.Team {
        let response = try await client.createTeam(.init(body: .json(team)))
        
        switch response {
        case .created(let createdResponse):
            switch createdResponse.body {
            case .json(let team):
                return team
            }
        case .badRequest:
            throw SoccerTeamError.invalidInput
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// チーム一覧を取得する
    public func getTeams(league: String? = nil) async throws -> [Components.Schemas.Team] {
        let response = try await client.getTeams(.init(query: .init(league: league)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let teams):
                return teams
            }
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// チームIDでチーム情報を取得する
    public func getTeam(by id: Int64) async throws -> Components.Schemas.Team {
        let response = try await client.getTeamById(.init(path: .init(teamId: id)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let team):
                return team
            }
        case .notFound:
            throw SoccerTeamError.teamNotFound
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// チームのラインナップを設定する
    public func setLineup(teamId: Int64, lineup: Components.Schemas.Lineup) async throws -> Components.Schemas.Lineup {
        let response = try await client.setLineup(.init(
            path: .init(teamId: teamId),
            body: .json(lineup)
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let lineup):
                return lineup
            }
        case .badRequest:
            throw SoccerTeamError.invalidLineup
        case .notFound:
            throw SoccerTeamError.teamNotFound
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    // MARK: - 試合管理
    
    /// 新しい試合を登録する
    public func createMatch(_ match: Components.Schemas.Match) async throws -> Components.Schemas.Match {
        let response = try await client.createMatch(.init(body: .json(match)))
        
        switch response {
        case .created(let createdResponse):
            switch createdResponse.body {
            case .json(let match):
                return match
            }
        case .badRequest:
            throw SoccerTeamError.invalidInput
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// 試合一覧を取得する
    public func getMatches(teamId: Int64? = nil, 
                          status: Operations.getMatches.Input.Query.statusPayload? = nil) async throws -> [Components.Schemas.Match] {
        let response = try await client.getMatches(.init(query: .init(
            teamId: teamId,
            status: status
        )))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let matches):
                return matches
            }
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// 試合結果を更新する
    public func updateMatchResult(matchId: Int64, result: Components.Schemas.MatchResult) async throws -> Components.Schemas.Match {
        let response = try await client.updateMatchResult(.init(
            path: .init(matchId: matchId),
            body: .json(result)
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let match):
                return match
            }
        case .notFound:
            throw SoccerTeamError.matchNotFound
        case .badRequest:
            throw SoccerTeamError.invalidResult
        case .undocumented(let statusCode, _):
            throw SoccerTeamError.unexpectedResponse(statusCode: statusCode)
        }
    }
}

/// サッカーチーム管理API エラー型
public enum SoccerTeamError: Error, LocalizedError {
    case invalidInput
    case playerNotFound
    case teamNotFound
    case matchNotFound
    case invalidLineup
    case invalidResult
    case unexpectedResponse(statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "無効な入力データです"
        case .playerNotFound:
            return "選手が見つかりません"
        case .teamNotFound:
            return "チームが見つかりません"
        case .matchNotFound:
            return "試合が見つかりません"
        case .invalidLineup:
            return "無効なラインナップです（選手数が不正など）"
        case .invalidResult:
            return "無効な試合結果データです"
        case .unexpectedResponse(let statusCode):
            return "予期しないレスポンスです（ステータスコード: \(statusCode)）"
        }
    }
}