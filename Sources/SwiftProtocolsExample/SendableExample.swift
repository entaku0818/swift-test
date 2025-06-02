import Foundation

// MARK: - 値型の例（自動的にSendable準拠）
public struct ImmutableMessage: Sendable {
    public let id: UUID
    public let content: String
    public let timestamp: Date
    
    public init(id: UUID = UUID(), content: String, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - 参照型の例（明示的なSendable準拠が必要）
public final class MessageQueue: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.example.messagequeue")
    private var messages: [ImmutableMessage] = []
    
    public init() {}
    
    public func enqueue(_ message: ImmutableMessage) {
        queue.async {
            self.messages.append(message)
        }
    }
    
    public func dequeue() -> ImmutableMessage? {
        var result: ImmutableMessage?
        queue.sync {
            result = self.messages.isEmpty ? nil : self.messages.removeFirst()
        }
        return result
    }
    
    public var count: Int {
        var result = 0
        queue.sync {
            result = self.messages.count
        }
        return result
    }
}

// MARK: - アクター（自動的にSendable準拠）
public actor MessageProcessor {
    private var processedCount: Int = 0
    
    public init() {}
    
    public func process(_ message: ImmutableMessage) async -> String {
        processedCount += 1
        return "Processed message [\(message.content)] - Count: \(processedCount)"
    }
    
    public func getProcessedCount() -> Int {
        processedCount
    }
}

// MARK: - 列挙型の例（自動的にSendable準拠）
public enum MessagePriority: Sendable {
    case low
    case normal
    case high(deadline: Date)
}

// MARK: - カスタムSendable型（手動でのSendable準拠）
public struct MessageWithPriority: Sendable {
    public let message: ImmutableMessage
    public let priority: MessagePriority
    
    public init(message: ImmutableMessage, priority: MessagePriority) {
        self.message = message
        self.priority = priority
    }
}

// MARK: - 非Sendable型の例
public class MutableMessage {
    public var content: String
    
    public init(content: String) {
        self.content = content
    }
}

// MARK: - Sendableプロトコルの実践的な使用例
public actor MessageSystem {
    private let queue: MessageQueue
    private let processor: MessageProcessor
    
    public init() {
        self.queue = MessageQueue()
        self.processor = MessageProcessor()
    }
    
    public func sendMessage(_ content: String, priority: MessagePriority = .normal) {
        let message = ImmutableMessage(content: content)
        let priorityMessage = MessageWithPriority(message: message, priority: priority)
        handleMessage(priorityMessage)
    }
    
    private func handleMessage(_ priorityMessage: MessageWithPriority) {
        // 優先度に基づいてメッセージを処理
        switch priorityMessage.priority {
        case .high:
            queue.enqueue(priorityMessage.message)
            Task {
                // 高優先度メッセージは即時処理
                if let message = queue.dequeue() {
                    let result = await processor.process(message)
                    print(result)
                }
            }
        case .normal, .low:
            queue.enqueue(priorityMessage.message)
        }
    }
    
    public func processNextMessage() async -> String? {
        guard let message = queue.dequeue() else {
            return nil
        }
        return await processor.process(message)
    }
    
    public func getQueueCount() -> Int {
        queue.count
    }
    
    public func getProcessedCount() async -> Int {
        await processor.getProcessedCount()
    }
} 