import XCTest
@testable import SwiftProtocolsExample

final class SendableExampleTests: XCTestCase {
    
    // MARK: - 値型のSendableテスト
    func testImmutableMessageSendable() async {
        let message = ImmutableMessage(content: "Hello, World!")
        
        // 複数のタスクで同時にメッセージを使用
        let expectations = (0..<5).map { _ in expectation(description: "Task completion") }
        
        for i in 0..<5 {
            Task {
                // メッセージの内容を確認（読み取り専用なので安全）
                XCTAssertEqual(message.content, "Hello, World!")
                expectations[i].fulfill()
            }
        }
        
        await fulfillment(of: expectations, timeout: 1.0)
    }
    
    // MARK: - 参照型のSendableテスト
    func testMessageQueueSendable() async {
        let queue = MessageQueue()
        let message1 = ImmutableMessage(content: "First")
        let message2 = ImmutableMessage(content: "Second")
        
        // 複数のタスクで同時にキューを操作
        async let enqueueTask1: Void = {
            queue.enqueue(message1)
        }()
        
        async let enqueueTask2: Void = {
            queue.enqueue(message2)
        }()
        
        // すべてのタスクが完了するまで待機
        _ = await [enqueueTask1, enqueueTask2]
        
        // キューの状態を確認
        XCTAssertEqual(queue.count, 2)
        
        // デキューの確認
        let dequeued1 = queue.dequeue()
        XCTAssertEqual(dequeued1?.content, "First")
        
        let dequeued2 = queue.dequeue()
        XCTAssertEqual(dequeued2?.content, "Second")
    }
    
    // MARK: - アクターのテスト
    func testMessageProcessor() async {
        let processor = MessageProcessor()
        let message = ImmutableMessage(content: "Test Message")
        
        // 複数のメッセージを同時に処理
        async let process1 = processor.process(message)
        async let process2 = processor.process(message)
        
        let results = await [process1, process2]
        
        // 処理結果の確認
        XCTAssertTrue(results[0].contains("Test Message"))
        XCTAssertTrue(results[1].contains("Test Message"))
        
        // 処理カウントの確認
        let count = await processor.getProcessedCount()
        XCTAssertEqual(count, 2)
    }
    
    // MARK: - 統合テスト
    func testMessageSystem() async {
        let system = MessageSystem()
        
        // 異なる優先度のメッセージを送信
        await system.sendMessage("High Priority", priority: .high(deadline: Date()))
        await system.sendMessage("Normal Priority")
        await system.sendMessage("Low Priority", priority: .low)
        
        // 処理待ち
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // キューの状態を確認
        let queueCount = await system.getQueueCount()
        XCTAssertEqual(queueCount, 2) // 高優先度メッセージは即時処理されるため
        
        // 次のメッセージを処理
        let result = await system.processNextMessage()
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.contains("Normal Priority") ?? false)
        
        // 処理済みメッセージ数の確認
        let processedCount = await system.getProcessedCount()
        XCTAssertEqual(processedCount, 2) // 高優先度メッセージと通常優先度メッセージ
    }
    
    // MARK: - 非Sendable型との比較テスト
    func testMutableMessageNotSendable() async {
        let mutableMessage = MutableMessage(content: "Mutable Content")
        
        // 以下のようなコードはコンパイルエラーになる（コメントアウト）
        // Task {
        //     mutableMessage.content = "Modified"  // 安全でない並行アクセス
        // }
        
        // 代わりにアクターやDispatchQueueを使用する必要がある
        let expectation = expectation(description: "Queue operation")
        
        DispatchQueue(label: "test.queue").async {
            mutableMessage.content = "Modified"
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(mutableMessage.content, "Modified")
    }
    
    // MARK: - エッジケースのテスト
    func testMessageSystemEdgeCases() async {
        let system = MessageSystem()
        
        // 空のキューからの処理
        let emptyResult = await system.processNextMessage()
        XCTAssertNil(emptyResult)
        
        // 大量のメッセージを同時に送信
        let expectations = (0..<100).map { i in expectation(description: "Message \(i)") }
        
        for i in 0..<100 {
            Task {
                await system.sendMessage("Message \(i)")
                expectations[i].fulfill()
            }
        }
        
        await fulfillment(of: expectations, timeout: 5.0)
        
        // キューの状態を確認
        let finalCount = await system.getQueueCount()
        XCTAssertEqual(finalCount, 100)
    }
} 