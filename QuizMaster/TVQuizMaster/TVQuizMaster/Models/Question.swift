import Foundation

struct Question: Codable, Identifiable {
    let id: UUID
    let category: String
    let question: String
    let options: [String]
    let correctAnswer: Int
    let difficulty: Difficulty
    
    enum Difficulty: String, Codable {
        case easy, medium, hard
    }
}

struct Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let iconName: String
    var questionCount: Int
}

// For preview purposes
#if DEBUG
extension Question {
    static var sample: [Question] {
        [
            Question(
                id: UUID(),
                category: "Science",
                question: "What is the chemical symbol for water?",
                options: ["H2O", "CO2", "NaCl", "O2"],
                correctAnswer: 0,
                difficulty: .easy
            ),
            Question(
                id: UUID(),
                category: "History",
                question: "In which year did World War II end?",
                options: ["1943", "1944", "1945", "1946"],
                correctAnswer: 2,
                difficulty: .medium
            )
        ]
    }
}

#endif
