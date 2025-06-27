import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// @MainActor と並行処理の使用例
/// 
/// @MainActor は Swift 5.5 以降で利用可能な、メインスレッド（UIスレッド）での
/// 実行を保証するためのグローバルアクターです。
public struct MainActorExample {
    
    // MARK: - @MainActor の基本的な使用
    
    /// @MainActor を使用したメソッド
    @MainActor
    public static func mainActorMethod() {
        print("@MainActor メソッド: メインスレッドで実行")
        // このメソッド内の処理は自動的にメインスレッドで実行される
    }
    
    /// 非 @MainActor メソッドから @MainActor メソッドを呼ぶ
    public static func callMainActorMethod() async {
        print("バックグラウンドから開始")
        
        // @MainActor メソッドを呼ぶには await が必要
        await mainActorMethod()
    }
    
    // MARK: - @MainActor クラス
    
    /// UI を管理する @MainActor クラス
    @MainActor
    public class UIManager {
        private var viewCount = 0
        private var isLoading = false
        
        public init() {
            print("UIManager 初期化（メインスレッド）")
        }
        
        public func updateView() {
            viewCount += 1
            print("ビュー更新: \(viewCount)")
        }
        
        public func setLoading(_ loading: Bool) {
            isLoading = loading
            print("ローディング状態: \(loading)")
        }
        
        // 非同期処理の例
        public func loadData() async {
            setLoading(true)
            
            // バックグラウンドでデータを取得
            let data = await fetchDataInBackground()
            
            // メインスレッドで UI を更新
            print("データ受信: \(data)")
            viewCount = data.count
            setLoading(false)
        }
        
        // nonisolated を使用してバックグラウンド処理を定義
        nonisolated func fetchDataInBackground() async -> [String] {
            // バックグラウンドで実行される
            print("バックグラウンドでデータ取得中...")
            
            // ネットワーク処理のシミュレーション
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
            
            return ["Item 1", "Item 2", "Item 3"]
        }
    }
    
    // MARK: - Task と @MainActor
    
    /// @MainActor Task の使用例
    public static func mainActorTask() {
        Task { @MainActor in
            print("Task 内で @MainActor: メインスレッドで実行")
            updateUI()
        }
        
        Task.detached {
            print("Detached Task: バックグラウンドで実行")
            
            // メインスレッドで UI を更新
            Task { @MainActor in
                updateUI()
            }
        }
    }
    
    @MainActor
    private static func updateUI() {
        print("UI を更新中...")
    }
    
    // MARK: - @MainActor とプロパティ
    
    /// 部分的に @MainActor を適用するクラス
    public class PartialMainActorClass {
        // メインスレッドでのみアクセス可能
        @MainActor var uiLabel: String = "初期テキスト"
        
        // どのスレッドからでもアクセス可能
        var dataCount: Int = 0
        
        public init() {}
        
        // メインスレッドでのみ実行可能
        @MainActor
        public func updateLabel(_ text: String) {
            uiLabel = text
            print("ラベル更新: \(text)")
        }
        
        // どのスレッドからでも実行可能
        public func incrementCount() {
            dataCount += 1
            print("カウント: \(dataCount)")
        }
        
        // 非同期でラベルを更新
        public func asyncUpdateLabel() async {
            let newText = "更新: \(Date())"
            await updateLabel(newText)
        }
    }
    
    // MARK: - @MainActor と Sendable
    
    /// Sendable かつ @MainActor なクラス
    @MainActor
    public final class SendableUIManager: Sendable {
        private let id: UUID
        private(set) var state: ViewState
        
        public init() {
            self.id = UUID()
            self.state = ViewState(title: "初期状態", isLoading: false)
        }
        
        public func updateState(title: String? = nil, isLoading: Bool? = nil) {
            state = ViewState(
                title: title ?? state.title,
                isLoading: isLoading ?? state.isLoading
            )
        }
    }
    
    /// Sendable な状態構造体
    public struct ViewState: Sendable {
        let title: String
        let isLoading: Bool
    }
    
    // MARK: - 実践的な使用例
    
    /// ネットワークリクエストと UI 更新
    public class NetworkDataLoader {
        @MainActor private var isLoading = false
        @MainActor private var data: [String] = []
        
        @MainActor
        public func getData() -> [String] {
            return data
        }
        
        public func loadData() async {
            // ローディング開始
            await setLoading(true)
            
            do {
                // バックグラウンドでデータ取得
                let fetchedData = try await performNetworkRequest()
                
                // メインスレッドでデータを更新
                await updateData(fetchedData)
            } catch {
                print("エラー: \(error)")
            }
            
            // ローディング終了
            await setLoading(false)
        }
        
        @MainActor
        private func setLoading(_ loading: Bool) {
            isLoading = loading
            print("ローディング: \(loading)")
        }
        
        @MainActor
        private func updateData(_ newData: [String]) {
            data = newData
            print("データ更新: \(newData.count) 件")
        }
        
        private func performNetworkRequest() async throws -> [String] {
            // ネットワークリクエストのシミュレーション
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            return (1...5).map { "データ \($0)" }
        }
    }
    
    // MARK: - @MainActor と Timer の統合
    
    /// Timer と @MainActor の統合例
    @MainActor
    public class TimerViewModel {
        private var text = "初期値"
        private var count = 0
        private var timer: Timer?
        
        public init() {
            // Timer を使用した自動更新
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.count += 1
                    print("タイマーカウント: \(self?.count ?? 0)")
                }
            }
        }
        
        deinit {
            timer?.invalidate()
        }
        
        public func updateText(_ newText: String) {
            text = newText
            print("テキスト更新: \(text)")
        }
        
        public func getCount() -> Int {
            return count
        }
    }
    
    // MARK: - エラーハンドリング
    
    /// エラーを含む非同期処理
    public enum DataError: Error {
        case networkError
        case parseError
    }
    
    @MainActor
    public class ErrorHandlingExample {
        private var errorMessage: String?
        
        public func performRiskyOperation() async {
            do {
                let result = try await riskyAsyncOperation()
                errorMessage = nil
                print("成功: \(result)")
            } catch DataError.networkError {
                errorMessage = "ネットワークエラーが発生しました"
            } catch DataError.parseError {
                errorMessage = "データの解析に失敗しました"
            } catch {
                errorMessage = "不明なエラー: \(error)"
            }
            
            if let error = errorMessage {
                print("エラー表示: \(error)")
            }
        }
        
        nonisolated func riskyAsyncOperation() async throws -> String {
            // ランダムにエラーを発生させる
            if Bool.random() {
                throw DataError.networkError
            }
            return "成功データ"
        }
    }
    
    // MARK: - 使用例の実行
    
    /// すべての例を実行
    public static func runAllExamples() async {
        print("=== @MainActor Examples ===\n")
        
        print("1. 基本的な使用:")
        await callMainActorMethod()
        
        print("\n2. UIManager の使用:")
        let uiManager = await UIManager()
        await uiManager.updateView()
        await uiManager.loadData()
        
        print("\n3. Task の使用:")
        mainActorTask()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        print("\n4. 部分的な @MainActor:")
        let partial = PartialMainActorClass()
        partial.incrementCount()
        await partial.asyncUpdateLabel()
        
        print("\n5. Sendable UI Manager:")
        let sendableManager = await SendableUIManager()
        await sendableManager.updateState(title: "新しいタイトル")
        
        print("\n6. ネットワークローダー:")
        let loader = NetworkDataLoader()
        await loader.loadData()
        let loadedData = await loader.getData()
        print("取得したデータ: \(loadedData)")
        
        print("\n7. エラーハンドリング:")
        let errorExample = await ErrorHandlingExample()
        await errorExample.performRiskyOperation()
        
        print("\n8. Timer 統合:")
        let timerModel = await TimerViewModel()
        await timerModel.updateText("更新されたテキスト")
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒待機
        print("最終カウント: \(await timerModel.getCount())")
        
        print("\n=== 完了 ===")
    }
}