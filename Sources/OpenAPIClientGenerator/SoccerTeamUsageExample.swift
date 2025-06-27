import Foundation

/// サッカーチーム管理API クライアント使用例
public class SoccerTeamUsageExample {
    
    /// 基本的な選手管理の例
    public static func basicPlayerManagementExample() async {
        let client = SoccerTeamClient()
        
        do {
            // 新しい選手を登録
            let newPlayer = Components.Schemas.Player(
                id: nil,
                name: "山田太郎",
                position: .FW,
                jerseyNumber: 9,
                dateOfBirth: "1998-05-15",
                nationality: "Japan",
                height: 178.5,
                weight: 72.0,
                status: .active,
                teamId: 1,
                stats: Components.Schemas.PlayerStats(
                    goals: 0,
                    assists: 0,
                    yellowCards: 0,
                    redCards: 0,
                    appearances: 0
                )
            )
            
            let addedPlayer = try await client.addPlayer(newPlayer)
            print("選手が登録されました: \(addedPlayer.name) (背番号: \(addedPlayer.jerseyNumber))")
            
            // 選手IDで取得
            if let playerId = addedPlayer.id {
                let retrievedPlayer = try await client.getPlayer(by: playerId)
                print("取得された選手: \(retrievedPlayer.name), ポジション: \(retrievedPlayer.position)")
            }
            
            // ポジションで選手を検索
            let forwards = try await client.getPlayers(position: .FW)
            print("フォワードの選手数: \(forwards.count)")
            
            // アクティブな選手を検索
            let activePlayers = try await client.getPlayers(status: .active)
            print("アクティブな選手数: \(activePlayers.count)")
            
        } catch {
            print("エラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// チーム管理の例
    public static func teamManagementExample() async {
        let client = SoccerTeamClient()
        
        do {
            // 新しいチームを作成
            let newTeam = Components.Schemas.Team(
                id: nil,
                name: "東京ユナイテッド",
                foundedYear: 2024,
                homeStadium: "東京スタジアム",
                league: "J2リーグ",
                manager: "佐藤監督",
                players: nil
            )
            
            let createdTeam = try await client.createTeam(newTeam)
            print("チームが作成されました: \(createdTeam.name)")
            
            // リーグでチームを検索
            let j2Teams = try await client.getTeams(league: "J2リーグ")
            print("J2リーグのチーム数: \(j2Teams.count)")
            
            // チーム情報を取得
            if let teamId = createdTeam.id {
                let team = try await client.getTeam(by: teamId)
                print("チーム: \(team.name), ホームスタジアム: \(team.homeStadium ?? "未設定")")
            }
            
        } catch {
            print("チーム管理でエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// ラインナップ設定の例
    public static func lineupSettingExample() async {
        let client = SoccerTeamClient()
        
        do {
            // 4-4-2フォーメーションのラインナップを設定
            let lineup = Components.Schemas.Lineup(
                id: nil,
                formation: "4-4-2",
                playerIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],  // スターティング11人
                substituteIds: [12, 13, 14, 15, 16, 17, 18],     // 控え選手7人
                captain: 5  // キャプテンのID
            )
            
            let setLineup = try await client.setLineup(teamId: 1, lineup: lineup)
            print("ラインナップが設定されました: フォーメーション \(setLineup.formation)")
            print("キャプテン: 選手ID \(setLineup.captain ?? 0)")
            
        } catch SoccerTeamError.invalidLineup {
            print("無効なラインナップです（選手数を確認してください）")
        } catch {
            print("ラインナップ設定でエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// 試合管理の例
    public static func matchManagementExample() async {
        let client = SoccerTeamClient()
        
        do {
            // 新しい試合を登録
            let dateFormatter = ISO8601DateFormatter()
            let matchDate = dateFormatter.date(from: "2024-03-20T19:00:00Z")!
            
            let newMatch = Components.Schemas.Match(
                id: nil,
                homeTeamId: 1,
                awayTeamId: 2,
                scheduledDate: matchDate,
                venue: "東京スタジアム",
                status: .scheduled,
                result: nil
            )
            
            let createdMatch = try await client.createMatch(newMatch)
            print("試合が登録されました: ID \(createdMatch.id ?? 0)")
            
            guard let matchId = createdMatch.id else { return }
            
            // 試合結果を更新
            let matchResult = Components.Schemas.MatchResult(
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
                    ),
                    Components.Schemas.Goal(
                        playerId: 20,  // 相手チームの選手
                        minute: 89,
                        assistPlayerId: 21,
                        _type: .regular
                    )
                ]
            )
            
            let updatedMatch = try await client.updateMatchResult(matchId: matchId, result: matchResult)
            print("試合結果が更新されました: \(updatedMatch.result?.homeScore ?? 0) - \(updatedMatch.result?.awayScore ?? 0)")
            
            // チームの試合一覧を取得
            let teamMatches = try await client.getMatches(teamId: 1)
            print("チーム1の試合数: \(teamMatches.count)")
            
            // 終了した試合を取得
            let finishedMatches = try await client.getMatches(status: .finished)
            print("終了した試合数: \(finishedMatches.count)")
            
        } catch {
            print("試合管理でエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// 選手のステータス更新と統計管理の例
    public static func playerStatsManagementExample() async {
        let client = SoccerTeamClient()
        
        do {
            // 選手を取得
            let player = try await client.getPlayer(by: 9)
            
            // 統計情報を更新
            var updatedPlayer = player
            let currentStats = updatedPlayer.stats
            updatedPlayer.stats = Components.Schemas.PlayerStats(
                goals: (currentStats?.goals ?? 0) + 1,
                assists: currentStats?.assists ?? 0,
                yellowCards: currentStats?.yellowCards ?? 0,
                redCards: currentStats?.redCards ?? 0,
                appearances: (currentStats?.appearances ?? 0) + 1
            )
            
            let finalPlayer = try await client.updatePlayer(id: 9, player: updatedPlayer)
            print("選手の統計が更新されました: \(finalPlayer.name)")
            print("ゴール数: \(finalPlayer.stats?.goals ?? 0)")
            print("出場試合数: \(finalPlayer.stats?.appearances ?? 0)")
            
            // 怪我した選手のステータス更新
            var injuredPlayer = player
            injuredPlayer.status = .injured
            
            let updatedStatus = try await client.updatePlayer(id: 9, player: injuredPlayer)
            print("選手のステータスが更新されました: \(updatedStatus.status?.rawValue ?? "不明")")
            
        } catch {
            print("選手統計管理でエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// エラーハンドリングの例
    public static func errorHandlingExample() async {
        let client = SoccerTeamClient()
        
        do {
            // 存在しない選手を取得しようとする
            let _ = try await client.getPlayer(by: 999999)
            
        } catch SoccerTeamError.playerNotFound {
            print("選手が見つかりませんでした")
            
        } catch SoccerTeamError.teamNotFound {
            print("チームが見つかりませんでした")
            
        } catch SoccerTeamError.invalidLineup {
            print("無効なラインナップです")
            
        } catch SoccerTeamError.unexpectedResponse(let statusCode) {
            print("予期しないレスポンス（ステータス: \(statusCode)）")
            
        } catch {
            print("その他のエラー: \(error)")
        }
    }
    
    /// 複雑な検索と集計の例
    public static func advancedSearchExample() async {
        let client = SoccerTeamClient()
        
        do {
            // 各ポジションの選手数を集計
            let positions: [Components.Schemas.Position] = [.GK, .DF, .MF, .FW]
            
            for position in positions {
                let players = try await client.getPlayers(position: position)
                print("\(position)の選手数: \(players.count)")
            }
            
            // 怪我をしている選手のリスト
            let injuredPlayers = try await client.getPlayers(status: .injured)
            print("\n負傷者リスト:")
            for player in injuredPlayers {
                print("- \(player.name) (背番号: \(player.jerseyNumber))")
            }
            
            // 得点ランキング（仮想的な実装）
            let allPlayers = try await client.getPlayers()
            let topScorers = allPlayers
                .filter { ($0.stats?.goals ?? 0) > 0 }
                .sorted { ($0.stats?.goals ?? 0) > ($1.stats?.goals ?? 0) }
                .prefix(5)
            
            print("\n得点ランキング TOP5:")
            for (index, player) in topScorers.enumerated() {
                print("\(index + 1). \(player.name) - \(player.stats?.goals ?? 0)ゴール")
            }
            
        } catch {
            print("詳細検索でエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    /// 並行処理の例
    public static func concurrentOperationsExample() async {
        let client = SoccerTeamClient()
        
        await withTaskGroup(of: Void.self) { group in
            // 複数のチームデータを並行取得
            group.addTask {
                do {
                    let teams = try await client.getTeams()
                    print("全チーム数: \(teams.count)")
                } catch {
                    print("チーム取得エラー: \(error)")
                }
            }
            
            group.addTask {
                do {
                    let matches = try await client.getMatches(status: .scheduled)
                    print("予定されている試合数: \(matches.count)")
                } catch {
                    print("試合取得エラー: \(error)")
                }
            }
            
            group.addTask {
                do {
                    let players = try await client.getPlayers(status: .active)
                    print("アクティブな選手総数: \(players.count)")
                } catch {
                    print("選手取得エラー: \(error)")
                }
            }
        }
    }
}