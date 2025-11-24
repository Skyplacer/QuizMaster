import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @State private var isAnimating = false
    
    private var scorePercentage: Int {
        guard !viewModel.currentQuestions.isEmpty else { return 0 }
        return Int((Double(viewModel.score) / Double(viewModel.currentQuestions.count)) * 100)
    }
    
    private var resultTitle: String {
        switch scorePercentage {
        case 0..<40: return "Keep Practicing!"
        case 40..<70: return "Good Job!"
        case 70..<90: return "Great Work!"
        default: return "Perfect Score!"
        }
    }
    
    private var resultColor: Color {
        switch scorePercentage {
        case 0..<40: return .red
        case 40..<70: return .orange
        case 70..<90: return .green
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Result header
            VStack(spacing: 15) {
                Text("Quiz Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(resultTitle)
                    .font(.title2)
                    .foregroundColor(resultColor)
                
                // Score circle
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: min(CGFloat(scorePercentage) / 100.0, 1.0))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(resultColor)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut(duration: 1.0), value: scorePercentage)
                    
                    VStack {
                        Text("\(scorePercentage)%")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(resultColor)
                        
                        Text("\(viewModel.score) out of \(viewModel.currentQuestions.count) correct")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 250, height: 250)
                .padding(.vertical, 20)
                .scaleEffect(isAnimating ? 1.0 : 0.7)
                .opacity(isAnimating ? 1.0 : 0.0)
            }
            
            // Stats
            VStack(spacing: 15) {
                StatRow(icon: "checkmark.circle.fill", 
                       label: "Correct Answers", 
                       value: "\(viewModel.score)", 
                       color: .green)
                
                StatRow(icon: "xmark.circle.fill", 
                       label: "Wrong Answers", 
                       value: "\(viewModel.currentQuestions.count - viewModel.score)", 
                       color: .red)
                
                if let category = viewModel.selectedCategory {
                    let highScores = viewModel.getHighScores()
                    let highScore = highScores[category.name] ?? 0
                    
                    StatRow(icon: "trophy.fill", 
                           label: "High Score", 
                           value: "\(highScore)", 
                           color: .yellow)
                }
            }
            .padding(.horizontal, 40)
            .frame(maxWidth: 600)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 20)
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 30) {
                Button(action: {
                    // Play again
                    if let category = viewModel.selectedCategory {
                        viewModel.startGame(with: category)
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Play Again")
                    }
                    .frame(width: 200)
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button(action: {
                    // Back to menu
                    viewModel.restartGame()
                }) {
                    HStack {
                        Image(systemName: "house")
                        Text("Main Menu")
                    }
                    .frame(width: 200)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.bottom, 40)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                Text(label)
                    .foregroundColor(.primary)
                Spacer()
                Text(value)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            .padding()
            .background(Color(white: 0.9, opacity: 0.3))
            .cornerRadius(12)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : isFocused ? 1.05 : 1.0)
            .shadow(color: isFocused ? .blue.opacity(0.5) : .clear, 
                   radius: 10, x: 0, y: 5)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), 
                      value: isFocused || configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(height: 50)
            .background(Color(white: 0.9, opacity: 0.3))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.blue : Color.gray, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : isFocused ? 1.05 : 1.0)
            .shadow(color: isFocused ? .blue.opacity(0.3) : .clear, 
                   radius: 10, x: 0, y: 5)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), 
                      value: isFocused || configuration.isPressed)
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = QuizViewModel()
        viewModel.currentQuestions = Question.sample
        viewModel.score = 7
        
        return ResultsView()
            .environmentObject(viewModel)
    }
}
