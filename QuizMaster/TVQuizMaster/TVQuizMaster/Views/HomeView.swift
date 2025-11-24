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
        VStack(spacing: 40) {
            headerView
            CategoriesScrollView(
                categories: viewModel.categories,
                selectedIndex: $selectedCategoryIndex,
                isFocused: $isCategoryFocused
            )
            selectedCategoryView
        }
        .padding()
    }

    private var headerView: some View {
        Text("TVQuizMaster")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top, 20)
    }

    @ViewBuilder
    private var selectedCategoryView: some View {
        if let selectedCategory = focusedCategory {
            VStack {
                Text(selectedCategory.name)
                    .font(.title2)
                    .padding(.bottom, 8)

                Button(action: {
                    viewModel.startGame(with: selectedCategory)
                }) {
                    Text("Play Now")
                        .font(.headline)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(CardButtonStyle())
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
}

struct CategoriesScrollView: View {
    let categories: [Category]
    @Binding var selectedIndex: Int
    @Binding var isFocused: Bool
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
                            action: {
                                selectedIndex = index
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
    let action: () -> Void
    @FocusState private var isFocused: Bool

    private var iconColor: Color {
        isSelected ? .blue : .gray
    }

    private var iconBackground: some View {
        Circle()
            .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isSelected ? Color.blue.opacity(0.05) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: isFocused ? 4 : 2)
            )
            .shadow(color: isSelected ? .blue.opacity(0.5) : .clear, radius: 10, x: 0, y: 5)
    }

    var body: some View {
        // Build icon and texts as views (no explicit type annotation required)
        let icon = Image(systemName: category.iconName)
            .font(.system(size: 60))
            .foregroundColor(iconColor)
            .padding()
            .background(iconBackground)
            .scaleEffect(isSelected ? 1.2 : 1.0)

        let name = Text(category.name)
            .font(.headline)
            .padding(.top, 8)
            .foregroundColor(isSelected ? .primary : .secondary)

        let questionCount = Text("\(category.questionCount) questions")
            .font(.subheadline)
            .foregroundColor(isSelected ? .blue : .gray)

        VStack {
            icon
            name
            questionCount
        }
        .padding()
        .frame(width: 300, height: 300)
        .background(cardBackground)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
        .focusable()
        .focused($isFocused)
        .onChange(of: isFocused) { oldValue, newValue in
            if newValue {
                action()
            }
        }
        .onTapGesture(perform: action)
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(QuizViewModel())
    }
}

