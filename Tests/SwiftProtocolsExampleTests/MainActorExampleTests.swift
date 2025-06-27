import XCTest
@testable import SwiftProtocolsExample

final class MainActorExampleTests: XCTestCase {
    
    // MARK: - @MainActor 基本テスト
    
    func testMainActorMethod() async {
        // @MainActor メソッドの呼び出しテスト
        await MainActorExample.mainActorMethod()
        // 正常に実行されることを確認（コンソール出力で確認）
    }
    
    func testCallMainActorMethod() async {
        // 非 @MainActor から @MainActor メソッドを呼ぶテスト
        await MainActorExample.callMainActorMethod()
    }
    
    // MARK: - UIManager のテスト
    
    func testUIManager() async {
        let uiManager = await MainActorExample.UIManager()
        
        // updateView のテスト
        await uiManager.updateView()
        await uiManager.updateView()
        // viewCount が増加していることを期待（内部状態なので直接確認不可）
        
        // setLoading のテスト
        await uiManager.setLoading(true)
        await uiManager.setLoading(false)
        
        // loadData のテスト（非同期処理を含む）
        await uiManager.loadData()
        // データの読み込みが完了することを確認
    }
    
    func testUIManagerBackgroundFetch() async {
        let uiManager = await MainActorExample.UIManager()
        
        // nonisolated メソッドの直接呼び出し
        let data = await uiManager.fetchDataInBackground()
        XCTAssertEqual(data.count, 3)
        XCTAssertEqual(data[0], "Item 1")
    }
    
    // MARK: - Task のテスト
    
    func testMainActorTask() async throws {
        // Task の実行をテスト
        MainActorExample.mainActorTask()
        
        // Task が完了するまで少し待機
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
    }
    
    // MARK: - 部分的な @MainActor のテスト
    
    func testPartialMainActorClass() async {
        let instance = MainActorExample.PartialMainActorClass()
        
        // 通常のメソッド（どのスレッドからでも呼べる）
        instance.incrementCount()
        instance.incrementCount()
        XCTAssertEqual(instance.dataCount, 2)
        
        // @MainActor メソッド（await が必要）
        await instance.updateLabel("テストラベル")
        
        // 非同期更新
        await instance.asyncUpdateLabel()
        
        // @MainActor プロパティへのアクセス
        let labelText = await instance.uiLabel
        XCTAssertTrue(labelText.contains("更新:"))
    }
    
    // MARK: - Sendable UIManager のテスト
    
    func testSendableUIManager() async {
        let manager = await MainActorExample.SendableUIManager()
        
        // 初期状態の確認
        let initialState = await manager.state
        XCTAssertEqual(initialState.title, "初期状態")
        XCTAssertFalse(initialState.isLoading)
        
        // 状態更新
        await manager.updateState(title: "新しいタイトル", isLoading: true)
        
        let updatedState = await manager.state
        XCTAssertEqual(updatedState.title, "新しいタイトル")
        XCTAssertTrue(updatedState.isLoading)
    }
    
    // MARK: - NetworkDataLoader のテスト
    
    func testNetworkDataLoader() async {
        let loader = MainActorExample.NetworkDataLoader()
        
        // 初期状態では空
        let initialData = await loader.getData()
        XCTAssertTrue(initialData.isEmpty)
        
        // データ読み込み
        await loader.loadData()
        
        // データが読み込まれたことを確認
        let loadedData = await loader.getData()
        XCTAssertEqual(loadedData.count, 5)
        XCTAssertEqual(loadedData[0], "データ 1")
    }
    
    // MARK: - エラーハンドリングのテスト
    
    func testErrorHandling() async {
        let errorExample = await MainActorExample.ErrorHandlingExample()
        
        // エラーが発生する可能性がある操作を複数回実行
        for _ in 0..<5 {
            await errorExample.performRiskyOperation()
        }
        // エラーハンドリングが正しく動作することを確認（コンソール出力で確認）
    }
    
    // MARK: - Timer 統合のテスト
    
    func testTimerViewModel() async throws {
        let timerModel = await MainActorExample.TimerViewModel()
        
        // テキスト更新
        await timerModel.updateText("新しいテキスト")
        
        // 初期カウントの確認
        let initialCount = await timerModel.getCount()
        
        // カウントが自動的に増加することを確認
        try await Task.sleep(nanoseconds: 1_100_000_000) // 1.1秒待機
        let updatedCount = await timerModel.getCount()
        XCTAssertGreaterThan(updatedCount, initialCount)
    }
    
    // MARK: - 並行処理のテスト
    
    func testConcurrentAccess() async {
        let uiManager = await MainActorExample.UIManager()
        
        // 複数のタスクから同時にアクセス
        await withTaskGroup(of: Void.self) { group in
            for i in 1...5 {
                group.addTask {
                    await uiManager.updateView()
                    print("タスク \(i) 完了")
                }
            }
        }
        // すべてのタスクが安全に完了することを確認
    }
    
    // MARK: - パフォーマンステスト
    
    func testMainActorPerformance() {
        // @MainActor メソッドの呼び出しパフォーマンス
        measure {
            let expectation = XCTestExpectation(description: "パフォーマンステスト")
            
            Task {
                for _ in 0..<100 {
                    await MainActorExample.mainActorMethod()
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - 統合テスト
    
    func testRunAllExamples() async {
        // すべての例を実行
        await MainActorExample.runAllExamples()
        // 正常に完了することを確認
    }
}