import Foundation

extension Question {
    static let generalKnowledge: [Question] = [
        Question(
            id: UUID(),
            category: "General Knowledge",
            question: "What is the capital of France?",
            options: ["London", "Berlin", "Paris", "Madrid"],
            correctAnswer: 2,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "General Knowledge",
            question: "Which planet is known as the Red Planet?",
            options: ["Venus", "Mars", "Jupiter", "Saturn"],
            correctAnswer: 1,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "General Knowledge",
            question: "What is the largest mammal in the world?",
            options: ["African Elephant", "Blue Whale", "Giraffe", "Polar Bear"],
            correctAnswer: 1,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "General Knowledge",
            question: "How many continents are there on Earth?",
            options: ["5", "6", "7", "8"],
            correctAnswer: 2,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "General Knowledge",
            question: "What is the chemical symbol for gold?",
            options: ["Go", "Gd", "Au", "Ag"],
            correctAnswer: 2,
            difficulty: .medium
        )
    ]
    
    static let science: [Question] = [
        Question(
            id: UUID(),
            category: "Science",
            question: "What is the chemical formula for water?",
            options: ["CO2", "H2O", "O2", "N2"],
            correctAnswer: 1,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "Science",
            question: "What is the powerhouse of the cell?",
            options: ["Nucleus", "Mitochondria", "Ribosome", "Golgi Apparatus"],
            correctAnswer: 1,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "Science",
            question: "What is the speed of light?",
            options: ["300,000 km/s", "150,000 km/s", "500,000 km/s", "1,000,000 km/s"],
            correctAnswer: 0,
            difficulty: .medium
        ),
        Question(
            id: UUID(),
            category: "Science",
            question: "Which element has the atomic number 1?",
            options: ["Helium", "Hydrogen", "Oxygen", "Carbon"],
            correctAnswer: 1,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "Science",
            question: "What is the hardest natural substance on Earth?",
            options: ["Gold", "Iron", "Diamond", "Platinum"],
            correctAnswer: 2,
            difficulty: .easy
        )
    ]
    
    static let history: [Question] = [
        Question(
            id: UUID(),
            category: "History",
            question: "In which year did World War II end?",
            options: ["1943", "1945", "1947", "1950"],
            correctAnswer: 1,
            difficulty: .medium
        ),
        Question(
            id: UUID(),
            category: "History",
            question: "Who was the first President of the United States?",
            options: ["Thomas Jefferson", "John Adams", "George Washington", "Abraham Lincoln"],
            correctAnswer: 2,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "History",
            question: "Which ancient civilization built the Great Pyramids?",
            options: ["Greeks", "Romans", "Egyptians", "Mayans"],
            correctAnswer: 2,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "History",
            question: "When was the Declaration of Independence signed?",
            options: ["1776", "1789", "1791", "1801"],
            correctAnswer: 0,
            difficulty: .medium
        ),
        Question(
            id: UUID(),
            category: "History",
            question: "Who painted the Mona Lisa?",
            options: ["Vincent van Gogh", "Pablo Picasso", "Leonardo da Vinci", "Michelangelo"],
            correctAnswer: 2,
            difficulty: .easy
        )
    ]
    
    static let entertainment: [Question] = [
        Question(
            id: UUID(),
            category: "Entertainment",
            question: "Who played Jack in Titanic?",
            options: ["Brad Pitt", "Johnny Depp", "Leonardo DiCaprio", "Tom Cruise"],
            correctAnswer: 2,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "Entertainment",
            question: "Which band wrote 'Bohemian Rhapsody'?",
            options: ["The Beatles", "Queen", "Led Zeppelin", "Pink Floyd"],
            correctAnswer: 1,
            difficulty: .medium
        ),
        Question(
            id: UUID(),
            category: "Entertainment",
            question: "What is the highest-grossing film of all time?",
            options: ["Avatar", "Avengers: Endgame", "Titanic", "Star Wars: The Force Awakens"],
            correctAnswer: 1,
            difficulty: .medium
        ),
        Question(
            id: UUID(),
            category: "Entertainment",
            question: "Which TV series features the character Walter White?",
            options: ["The Sopranos", "Breaking Bad", "The Wire", "Game of Thrones"],
            correctAnswer: 1,
            difficulty: .easy
        ),
        Question(
            id: UUID(),
            category: "Entertainment",
            question: "Who is known as the 'King of Pop'?",
            options: ["Elvis Presley", "Michael Jackson", "Prince", "Madonna"],
            correctAnswer: 1,
            difficulty: .easy
        )
    ]
    
    // Combine all questions
    static var allQuestions: [Question] {
        return generalKnowledge + science + history + entertainment
    }
}
