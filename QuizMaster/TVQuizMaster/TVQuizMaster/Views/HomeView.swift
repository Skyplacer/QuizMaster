import SwiftUI
import UIKit

// Add notification names for selection changes and move selection
extension Notification.Name {
    static let selectionChanged = Notification.Name("SelectionChanged")
    static let moveSelection = Notification.Name("MoveSelection")
}

struct HomeView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    @State private var selectedCategoryIndex = 0
    @State private var isCategoryFocused = true

    private var focusedCategory: Category? {
        guard !viewModel.categories.isEmpty, selectedCategoryIndex < viewModel.categories.count else {
            return nil
        }
        return viewModel.categories[selectedCategoryIndex]
    }

    var body: some View {
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
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: selectedCategoryIndex)
            
            VStack(spacing: 50) {
                headerView
                
                // Updated to handle direct play action
                CategoriesScrollView(
                    categories: viewModel.categories,
                    selectedIndex: $selectedCategoryIndex,
                    isFocused: $isCategoryFocused,
                    onPlay: { category in
                        viewModel.startGame(with: category)
                    }
                )
                
                selectedCategoryView
                
                Spacer()
            }
            .padding()
        }
    }

    private var headerView: some View {
        VStack(spacing: 15) {
            // App icon with glow effect
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.4, green: 0.6, blue: 0.7), Color(red: 0.5, green: 0.7, blue: 0.8)], // Soft Teal
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 0.4, green: 0.6, blue: 0.7).opacity(0.4), radius: 15)
                .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2) * 0.05)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: selectedCategoryIndex)
            
            Text("TVQuizMaster")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(red: 0.9, green: 0.9, blue: 0.85)], // Warm White
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
            
            Text("Challenge Your Mind")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .italic()
        }
        .padding(.top, 30)
    }

    @ViewBuilder
    private var selectedCategoryView: some View {
        if let selectedCategory = focusedCategory {
            VStack(spacing: 20) {
                Text(selectedCategory.name)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(red: 0.4, green: 0.6, blue: 0.7)], // Soft Teal accent
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 3)

                Button(action: {
                    viewModel.startGame(with: selectedCategory)
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Start Quiz")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.4, green: 0.6, blue: 0.7), Color(red: 0.3, green: 0.5, blue: 0.6)], // Teal gradient
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.8, green: 0.85, blue: 0.9).opacity(0.6), .clear], // Soft gray-white
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(CardButtonStyle())
                .scaleEffect(1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedCategory.id)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 15)
            )
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
        }
    }
}

struct CategoriesScrollView: View {
    let categories: [Category]
    @Binding var selectedIndex: Int
    @Binding var isFocused: Bool
    // Add closure to handle game start
    let onPlay: (Category) -> Void
    
    @State private var scrollToId: UUID?
    @State private var previousSelectedIndex: Int? = nil
    @Namespace private var focusNamespace

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 40) {
                    ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedIndex == index,
                            onFocus: {
                                // Update index when focused (Navigation)
                                selectedIndex = index
                            },
                            onPlay: {
                                // Start game when clicked (Action)
                                onPlay(category)
                            }
                        )
                        .id(category.id)
                    }
                }
                .padding(60)
            }
            .focusSection()
            .coordinateSpace(name: "scroll")
            .onAppear {
                scrollToSelectedItem(proxy: proxy, animated: false)
            }
            .onChange(of: selectedIndex) { oldValue, newValue in
                guard !categories.isEmpty, newValue >= 0, newValue < categories.count else { return }
                
                withAnimation(.spring()) {
                    proxy.scrollTo(categories[newValue].id, anchor: .center)
                }
                
                previousSelectedIndex = newValue
            }
            .onChange(of: isFocused) { oldValue, newValue in
                if newValue {
                    handleFocusChange(newValue)
                    // Ensure the selected item is visible when focus is gained
                    DispatchQueue.main.async {
                        withAnimation(.spring()) {
                            proxy.scrollTo(categories[selectedIndex].id, anchor: .center)
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .moveSelection)) { notification in
                if isFocused {
                    handleMoveSelection(notification)
                }
            }
        }
    }

    private func scrollToSelectedItem(proxy: ScrollViewProxy, animated: Bool = true) {
        guard selectedIndex >= 0, selectedIndex < categories.count else { return }

        if animated {
            withAnimation(.spring()) {
                proxy.scrollTo(categories[selectedIndex].id, anchor: .center)
            }
        } else {
            proxy.scrollTo(categories[selectedIndex].id, anchor: .center)
        }
    }

    private func handleFocusChange(_ newValue: Bool) {
        if newValue && !categories.isEmpty {
            // Only reset to 0 if we don't have a valid selection
            if selectedIndex < 0 || selectedIndex >= categories.count {
                selectedIndex = 0
            }
        }
    }

    private func handleMoveSelection(_ notification: Notification) {
        guard isFocused, let direction = notification.object as? UIFocusHeading else { return }
        
        switch direction {
        case .left:
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
        case .right:
            if selectedIndex < categories.count - 1 {
                selectedIndex += 1
            }
        default:
            return
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    // Separeted actions for cleaner logic
    let onFocus: () -> Void
    let onPlay: () -> Void
    
    @FocusState private var isFocused: Bool

    private var categoryColors: [Color] {
        switch category.name {
        case "General Knowledge":
            return [Color(red: 0.4, green: 0.6, blue: 0.7), Color(red: 0.5, green: 0.7, blue: 0.8)] // Soft Teal
        case "Science":
            return [Color(red: 0.6, green: 0.65, blue: 0.7), Color(red: 0.7, green: 0.75, blue: 0.8)] // Warm Gray
        case "History":
            return [Color(red: 0.25, green: 0.35, blue: 0.5), Color(red: 0.35, green: 0.45, blue: 0.6)] // Deep Navy
        case "Entertainment":
            return [Color(red: 0.45, green: 0.55, blue: 0.65), Color(red: 0.55, green: 0.65, blue: 0.75)] // Medium Blue-Gray
        default:
            return [Color(red: 0.4, green: 0.6, blue: 0.7), Color(red: 0.5, green: 0.7, blue: 0.8)] // Default Teal
        }
    }
    
    private var iconBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: isSelected ? categoryColors : [.gray.opacity(0.3), .gray.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: isSelected ? categoryColors[0].opacity(0.3) : .clear, radius: 12)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? categoryColors + [.white.opacity(0.6)] : [.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isFocused ? 6 : (isSelected ? 4 : 0)
                    )
            )
            .shadow(
                color: isSelected ? categoryColors[0].opacity(0.2) : Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.1),
                radius: isSelected ? 15 : 5,
                x: 0,
                y: isSelected ? 8 : 2
            )
    }

    var body: some View {
        // Build icon and texts as views with enhanced styling
        let icon = Image(systemName: category.iconName)
            .font(.system(size: 70, weight: .medium))
            .foregroundStyle(
                LinearGradient(
                    colors: isSelected ? [.white, .white.opacity(0.8)] : [.gray, .gray.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .padding(25)
            .background(iconBackground)
            .scaleEffect(isSelected ? 1.3 : 1.0)

        let name = Text(category.name)
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .padding(.top, 15)
            .foregroundStyle(
                LinearGradient(
                    colors: isSelected ? [.white, categoryColors[0].opacity(0.8)] : [.secondary, .secondary.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: isSelected ? .black.opacity(0.3) : .clear, radius: 2)

        let questionCount = Text("\(category.questionCount) questions")
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? 
                                [Color.black.opacity(0.6), Color.black.opacity(0.4)] : 
                                [Color.black.opacity(0.4), Color.black.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? 
                                    LinearGradient(colors: [.white.opacity(0.3), .white.opacity(0.1)], startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

        VStack(spacing: 20) {
            icon
            
            VStack(spacing: 8) {
                name
                questionCount
            }
        }
        .padding(25)
        .frame(width: 320, height: 320)
        .background(cardBackground)
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .rotation3DEffect(
            .degrees(isSelected ? 5 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.9), value: isFocused)
        .focusable()
        .focused($isFocused)
        .onChange(of: isFocused) { oldValue, newValue in
            if newValue {
                // Only update the selection index when focused
                onFocus()
            }
        }
        // Use onTapGesture to trigger the actual game play
        .onTapGesture {
            onPlay()
        }
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(QuizViewModel())
    }
}
