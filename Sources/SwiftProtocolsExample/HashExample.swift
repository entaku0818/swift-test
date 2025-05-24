import Foundation

// カスタムHashable実装の例
public struct Student: Hashable {
    public let id: Int
    public let name: String
    public let grade: Int
    
    public init(id: Int, name: String, grade: Int) {
        self.id = id
        self.name = name
        self.grade = grade
    }
    
    // Hashableの明示的な実装
    public func hash(into hasher: inout Hasher) {
        // 一意性を保証するために重要なプロパティのみをハッシュに含める
        hasher.combine(id)
        hasher.combine(name)
    }
    
    // Equatableの明示的な実装
    public static func == (lhs: Student, rhs: Student) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

// カスタムHasher使用の例
public struct School {
    // SetでのHashable型の使用
    private var students: Set<Student>
    
    // DictionaryでのHashable型の使用（キーとして）
    private var studentGrades: [Student: String]
    
    public init() {
        self.students = Set<Student>()
        self.studentGrades = [Student: String]()
    }
    
    // 生徒を追加
    public mutating func addStudent(_ student: Student) {
        students.insert(student)
    }
    
    // 生徒の成績を設定
    public mutating func setGrade(for student: Student, grade: String) {
        studentGrades[student] = grade
    }
    
    // 生徒が登録されているか確認
    public func hasStudent(_ student: Student) -> Bool {
        return students.contains(student)
    }
    
    // 生徒の成績を取得
    public func getGrade(for student: Student) -> String? {
        return studentGrades[student]
    }
    
    // 登録されている生徒の数を取得
    public var studentCount: Int {
        return students.count
    }
    
    // 全ての生徒を取得
    public var allStudents: Set<Student> {
        return students
    }
    
    // 特定の学年の生徒を取得
    public func studentsInGrade(_ grade: Int) -> Set<Student> {
        return students.filter { $0.grade == grade }
    }
} 