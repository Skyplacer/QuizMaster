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
                isFocused: $isCategoryFocused,
                onSelect: { category in
                    viewModel.startGame(with: category)
                }
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
    let onSelect: (Category) -> Void
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
                            isFocused: Binding(
                                get: { isFocused && selectedIndex == index },
                                set: { _ in /* intentionally ignored: parent manages focus */ }
                            ),
                            action: {
                                selectedIndex = index
                                onSelect(category)
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
                
                // Only trigger onSelect if the index actually changed
                if newValue != oldValue {
                    onSelect(categories[newValue])
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
        
        let previousIndex = selectedIndex
        
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
        
        // Only trigger selection if the index actually changed
        if selectedIndex != previousIndex {
            // Update the view after a short delay to ensure smooth animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                onSelect(categories[selectedIndex])
            }
        }
    }
}

struct CategoryCard: View {
    let category: Category
    @Binding var isFocused: Bool
    let action: () -> Void
    @FocusState private var isFocusedState: Bool

    private var iconColor: Color {
        isFocused ? .blue : .gray
    }

    private var iconBackground: some View {
        Circle()
            .fill(isFocused ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isFocused ? Color.blue.opacity(0.05) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: isFocused ? .blue.opacity(0.5) : .clear, radius: 10, x: 0, y: 5)
    }

    var body: some View {
        // Build icon and texts as views (no explicit type annotation required)
        let icon = Image(systemName: category.iconName)
            .font(.system(size: 60))
            .foregroundColor(iconColor)
            .padding()
            .background(iconBackground)
            .scaleEffect(isFocused ? 1.2 : 1.0)

        let name = Text(category.name)
            .font(.headline)
            .padding(.top, 8)
            .foregroundColor(isFocused ? .primary : .secondary)

        let questionCount = Text("\(category.questionCount) questions")
            .font(.subheadline)
            .foregroundColor(isFocused ? .blue : .gray)

        VStack {
            icon
            name
            questionCount
        }
        .padding()
        .frame(width: 300, height: 300)
        .background(cardBackground)
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
        .focusable()
        .focused($isFocusedState)
        .onChange(of: isFocusedState) { oldValue, newValue in
            if newValue {
                isFocused = true
                action()
            } else {
                isFocused = false
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

