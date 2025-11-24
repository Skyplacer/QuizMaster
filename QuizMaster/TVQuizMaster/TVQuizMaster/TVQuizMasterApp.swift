import SwiftUI

@main
struct TVQuizMasterApp: App {
    @StateObject private var quizViewModel = QuizViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quizViewModel)
                .onAppear {
                    // Load initial data
                    quizViewModel.loadCategories()
                }
        }
    }
}

