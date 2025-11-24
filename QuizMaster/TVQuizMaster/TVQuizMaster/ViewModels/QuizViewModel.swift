import Foundation
import Combine
import GameController

class QuizViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var currentQuestions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var selectedCategory: Category?
    @Published var gameState: GameState = .menu
    
    private var cancellables = Set<AnyCancellable>()
    private let questionsFileName = "questions.json"
    private let userDefaults = UserDefaults.standard
    private let scoresKey = "highScores"
    
    enum GameState {
        case menu, playing, result
    }
    
    init() {
        setupGameControllerObservers()
    }
    
    func loadCategories() {
        // In a real app, this would load from JSON
        // For now, we'll use sample categories
        categories = [
            Category(name: "General Knowledge", iconName: "globe", questionCount: 10),
            Category(name: "Science", iconName: "atom", questionCount: 15),
            Category(name: "History", iconName: "book.closed", questionCount: 12),
            Category(name: "Entertainment", iconName: "tv", questionCount: 8)
        ]
    }
    
    func startGame(with category: Category) {
        selectedCategory = category
        
        // Load questions based on the selected category
        switch category.name {
        case "General Knowledge":
            currentQuestions = Question.generalKnowledge
        case "Science":
            currentQuestions = Question.science
        case "History":
            currentQuestions = Question.history
        case "Entertainment":
            currentQuestions = Question.entertainment
        default:
            // Fallback to general knowledge if category not found
            currentQuestions = Question.generalKnowledge
        }
        
        // Shuffle the questions for variety
        currentQuestions.shuffle()
        
        // If we have more than 10 questions, take the first 10
        if currentQuestions.count > 10 {
            currentQuestions = Array(currentQuestions.prefix(10))
        }
        
        currentQuestionIndex = 0
        score = 0
        userAnswers = [:] // Reset user answers
        gameState = .playing
    }
    
    // Store user answers for scoring
    private var userAnswers: [Int: Int] = [:]
    
    func submitAnswer(_ answerIndex: Int) {
        // Store the answer for the current question
        userAnswers[currentQuestionIndex] = answerIndex
        
        // Check if answer is correct and update score immediately
        if currentQuestionIndex < currentQuestions.count {
            let currentQuestion = currentQuestions[currentQuestionIndex]
            if answerIndex == currentQuestion.correctAnswer {
                score += 1
            }
        }
    }
    
    func nextQuestion() {
        // Move to next question
        if currentQuestionIndex < currentQuestions.count - 1 {
            currentQuestionIndex += 1
        } else {
            gameState = .result
        }
    }
    
    func restartGame() {
        gameState = .menu
        selectedCategory = nil
        currentQuestionIndex = 0
        score = 0
        userAnswers = [:] // Reset user answers
    }
    
    func calculateFinalScore(userAnswers: [Int: Int]) -> Int {
        var finalScore = 0
        for (index, question) in currentQuestions.enumerated() {
            if let userAnswer = userAnswers[index], userAnswer == question.correctAnswer {
                finalScore += 1
            }
        }
        score = finalScore
        saveHighScore()
        return finalScore
    }
    
    private func saveHighScore() {
        guard let category = selectedCategory else { return }
        
        var highScores = getHighScores()
        highScores[category.name] = max(highScores[category.name, default: 0], score)
        userDefaults.set(highScores, forKey: scoresKey)
    }
    
    func getHighScores() -> [String: Int] {
        return userDefaults.dictionary(forKey: scoresKey) as? [String: Int] ?? [:]
    }
    
    // MARK: - Game Controller Support
    private func setupGameControllerObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidConnect),
            name: .GCControllerDidConnect,
            object: nil
        )
    }
    
    @objc private func controllerDidConnect() {
        // Handle game controller connection
        if let controller = GCController.controllers().first {
            setupGameController(controller)
        }
    }
    
    private func setupGameController(_ controller: GCController) {
        // Setup game controller input handling
        controller.extendedGamepad?.valueChangedHandler = { (gamepad, element) in
            if gamepad.buttonA.isPressed || gamepad.buttonX.isPressed {
                // Handle button press
            }
        }
    }
}
