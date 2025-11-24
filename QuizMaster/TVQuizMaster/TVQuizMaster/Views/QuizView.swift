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
            ZStack {
                // Refined gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.2, blue: 0.35),   // Deep Navy
                        Color(red: 0.2, green: 0.3, blue: 0.4),     // Medium Blue-Gray
                        Color(red: 0.25, green: 0.35, blue: 0.45)   // Lighter Blue-Gray
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .hueRotation(.degrees(progress * 360))
                .animation(.easeInOut(duration: 1), value: progress)
                
                VStack(spacing: 40) {
                    // 1. Enhanced Progress bar
                    VStack(spacing: 15) {
                        HStack {
                            Text("Progress")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial.opacity(0.3))
                                    .frame(height: 16)
                                
                                // Progress fill with gradient
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.4, green: 0.6, blue: 0.7), Color(red: 0.3, green: 0.5, blue: 0.6)], // Soft Teal
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: min(CGFloat(progress) * geometry.size.width, geometry.size.width),
                                        height: 16
                                    )
                                    .shadow(color: Color(red: 0.4, green: 0.6, blue: 0.7).opacity(0.4), radius: 6)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)
                                
                                // Animated shimmer effect
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white.opacity(0.3), .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 60, height: 16)
                                    .offset(x: -30 + (geometry.size.width + 60) * progress)
                                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: progress)
                            }
                        }
                        .frame(height: 16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 30)
                
                    // 2. Enhanced Question Display
                    VStack(spacing: 25) {
                        // Question counter with modern styling
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.6, blue: 0.7), Color(red: 0.5, green: 0.7, blue: 0.8)], // Soft Teal
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.currentQuestions.count)")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            // Score indicator
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.7))
                                Text("\(viewModel.score)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial.opacity(0.6))
                            )
                        }
                        
                        // Question text with enhanced styling
                        Text(question.question)
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 25)
                            .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.ultraThinMaterial.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.4), .clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 15)
                            )
                            .padding(.horizontal, 30)
                    }
                
                    // 3. Enhanced Answer Options
                    VStack(spacing: 20) {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            AnswerButton(
                                text: question.options[index],
                                optionIndex: index,
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
                    .padding(.horizontal, 50)
                
                Spacer()
                
                    Spacer()
                    
                    // 4. Enhanced Footer
                    HStack {
                        Button(action: {
                            viewModel.restartGame()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                Text("Quit Game")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.6, green: 0.4, blue: 0.4), Color(red: 0.7, green: 0.5, blue: 0.5)], // Muted red gradient
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.4).opacity(0.3), radius: 6)
                        }
                        .buttonStyle(CardButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 40)
                }
                .onAppear {
                    isAnimating = true
                }
                .animation(.easeInOut, value: isAnimating)
            }
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.15, green: 0.2, blue: 0.35), Color(red: 0.25, green: 0.35, blue: 0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                    
                    Text("Loading Quiz...")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                viewModel.gameState = .result
            }
        }
    }
}

// MARK: - Enhanced Answer Button
struct AnswerButton: View {
    let text: String
    let optionIndex: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let isFeedbackShown: Bool
    let action: () -> Void
    
    // Track focus state explicitly
    @FocusState private var isFocused: Bool
    
    private var optionLetter: String {
        String(UnicodeScalar(65 + optionIndex)!) // A, B, C, D
    }
    
    private var backgroundGradient: LinearGradient {
        if isCorrect {
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.6, blue: 0.7), Color(red: 0.5, green: 0.7, blue: 0.8)], // Soft Teal for correct
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isIncorrect {
            return LinearGradient(
                colors: [Color(red: 0.6, green: 0.4, blue: 0.4), Color(red: 0.7, green: 0.5, blue: 0.5)], // Muted Red for incorrect
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isSelected {
            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.5, blue: 0.6), Color(red: 0.4, green: 0.6, blue: 0.7)], // Medium Teal for selected
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isFocused {
            return LinearGradient(
                colors: [Color(red: 0.8, green: 0.85, blue: 0.9).opacity(0.4), Color(red: 0.7, green: 0.75, blue: 0.8).opacity(0.2)], // Warm Gray for focus
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(red: 0.6, green: 0.65, blue: 0.7).opacity(0.2), Color(red: 0.7, green: 0.75, blue: 0.8).opacity(0.1)], // Light Gray default
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderGradient: LinearGradient {
        if isCorrect {
            return LinearGradient(colors: [Color(red: 0.4, green: 0.6, blue: 0.7), Color(red: 0.5, green: 0.7, blue: 0.8)], startPoint: .leading, endPoint: .trailing)
        } else if isIncorrect {
            return LinearGradient(colors: [Color(red: 0.6, green: 0.4, blue: 0.4), Color(red: 0.7, green: 0.5, blue: 0.5)], startPoint: .leading, endPoint: .trailing)
        } else if isFocused {
            return LinearGradient(colors: [Color(red: 0.8, green: 0.85, blue: 0.9), Color(red: 0.4, green: 0.6, blue: 0.7)], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var body: some View {
        Button(action: {
            // Prevent multiple clicks only if feedback is already showing
            guard !isFeedbackShown else { return }
            action()
        }) {
            HStack(spacing: 20) {
                // Option letter indicator
                Text(optionLetter)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isFocused ? [Color(red: 0.8, green: 0.85, blue: 0.9).opacity(0.3), Color(red: 0.7, green: 0.75, blue: 0.8).opacity(0.1)] : [Color(red: 0.2, green: 0.25, blue: 0.3).opacity(0.3), Color(red: 0.1, green: 0.15, blue: 0.2).opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.4), lineWidth: 2)
                    )
                
                // Answer text
                Text(text)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Status indicator
                Group {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    } else if isIncorrect {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    } else if isFocused {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 90)
            .background(backgroundGradient)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderGradient, lineWidth: isFocused ? 6 : (isSelected || isCorrect || isIncorrect) ? 4 : 0)
            )
            .scaleEffect(isFocused ? 1.03 : 1.0)
            .shadow(
                color: isCorrect ? Color(red: 0.4, green: 0.6, blue: 0.7).opacity(0.3) :
                       isIncorrect ? Color(red: 0.6, green: 0.4, blue: 0.4).opacity(0.3) :
                       isFocused ? Color(red: 0.8, green: 0.85, blue: 0.9).opacity(0.2) : Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.1),
                radius: isFocused ? 12 : 6
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCorrect)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isIncorrect)
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
