import SwiftUI

// MARK: - Quiz View
struct QuizView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @State private var selectedAnswer: Int?
    @State private var showFeedback = false
    @State private var isAnimating = false
    @State private var userAnswers: [Int: Int] = [:]
    @State private var isAnswerSelected = false
    
    private var currentQuestion: Question? {
        guard viewModel.currentQuestionIndex < viewModel.currentQuestions.count else { return nil }
        return viewModel.currentQuestions[viewModel.currentQuestionIndex]
    }
    
    private var progress: Double {
        guard !viewModel.currentQuestions.isEmpty else { return 0 }
        return Double(viewModel.currentQuestionIndex + 1) / Double(viewModel.currentQuestions.count)
    }
    
    var body: some View {
        if let question = currentQuestion {
            VStack(spacing: 40) {
                // 1. Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 10)
                            .opacity(0.3)
                            .foregroundColor(Color.gray)
                        
                        Rectangle()
                            .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width),
                                   height: 10)
                            .foregroundColor(.blue)
                            .animation(.linear, value: progress)
                    }
                    .cornerRadius(5)
                }
                .frame(height: 10)
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // 2. Question Text
                VStack(spacing: 20) {
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.currentQuestions.count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(question.question)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .frame(maxWidth: .infinity, minHeight: 150, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(white: 0.9, opacity: 0.3))
                        )
                        .padding(.horizontal, 40)
                }
                
                // 3. Answer Options
                VStack(spacing: 20) {
                    ForEach(0..<question.options.count, id: \.self) { index in
                        AnswerButton(
                            text: question.options[index],
                            isSelected: selectedAnswer == index,
                            isCorrect: showFeedback && index == question.correctAnswer,
                            isIncorrect: showFeedback && selectedAnswer == index && selectedAnswer != question.correctAnswer,
                            isFeedbackShown: showFeedback
                        ) {
                            // Action Logic
                            guard !isAnswerSelected else { return }
                            
                            // Lock in answer
                            selectedAnswer = index
                            isAnswerSelected = true
                            userAnswers[viewModel.currentQuestionIndex] = index
                            showFeedback = true
                            
                            // Auto-advance logic
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                // Check if this is the last question BEFORE submitting
                                let isLastQuestion = viewModel.currentQuestionIndex >= viewModel.currentQuestions.count - 1
                                
                                // Submit the answer to the view model (this will track the answer and update score)
                                viewModel.submitAnswer(selectedAnswer ?? 0)
                                
                                if isLastQuestion {
                                    // Game Over - just change state, score is already calculated
                                    viewModel.gameState = .result
                                } else {
                                    // Move to next question
                                    viewModel.nextQuestion()
                                    // Reset local state for the new question
                                    selectedAnswer = nil
                                    showFeedback = false
                                    isAnswerSelected = false
                                }
                            }
                        }
                        // CRITICAL FIX: Give each button a unique ID based on the question index.
                        // This forces SwiftUI to redraw the button and reset focus when the question changes.
                        .id("q\(viewModel.currentQuestionIndex)_opt\(index)")
                    }
                }
                .padding(.horizontal, 60)
                
                Spacer()
                
                // 4. Footer (Quit Button)
                HStack {
                    Button(action: {
                        viewModel.restartGame()
                    }) {
                        Text("Quit")
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(20)
                    }
                    .buttonStyle(CardButtonStyle()) // Use custom style here too
                    
                    Spacer()
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 40)
            }
            .onAppear {
                isAnimating = true
            }
            .animation(.easeInOut, value: isAnimating)
        } else {
            ProgressView("Loading...")
                .onAppear {
                    viewModel.gameState = .result
                }
        }
    }
}

// MARK: - Fixed Answer Button
struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let isFeedbackShown: Bool
    let action: () -> Void
    
    // Track focus state explicitly
    @FocusState private var isFocused: Bool
    
    private var backgroundColor: Color {
        if isCorrect {
            return .green.opacity(0.4)
        } else if isIncorrect {
            return .red.opacity(0.4)
        } else if isSelected {
            return .blue.opacity(0.4)
        } else if isFocused {
            // Visual feedback for focus state - make it more visible
            return Color.white.opacity(0.3)
        } else {
            return Color(white: 0.9, opacity: 0.15)
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return .green
        } else if isIncorrect {
            return .red
        } else if isFocused {
            // Highlight border on focus - make it bright and visible
            return .white
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    var body: some View {
        Button(action: {
            // Prevent multiple clicks only if feedback is already showing
            guard !isFeedbackShown else { return }
            action()
        }) {
            HStack {
                Spacer()
                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(minHeight: 80) // Use minHeight to prevent cutting off text
            .background(backgroundColor)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(borderColor, lineWidth: isFocused ? 5 : 2)
            )
            // Scale up slightly when focused (standard tvOS behavior)
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .shadow(color: isFocused ? .white.opacity(0.5) : .clear, radius: 10)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFocused)
        }
        .buttonStyle(CardButtonStyle())
        .focused($isFocused)
    }
}

// MARK: - Helper Button Style
// This is required to make custom buttons clickable on tvOS without
// the system forcing its own opaque background.

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = QuizViewModel()
        // Assuming you have sample questions in your Question struct
        // viewModel.currentQuestions = Question.sample
        return QuizView()
            .environmentObject(viewModel)
    }
}
