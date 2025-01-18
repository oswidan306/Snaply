import SwiftUI

struct NavigationHeader: View {
    @Binding var currentState: NavigationState
    
    var body: some View {
        HStack(spacing: 24) {
            // Left-aligned navigation items
            HStack(spacing: 24) {
                NavigationButton(
                    title: "past",
                    isSelected: currentState == .past,
                    action: { currentState = .past }
                )
                
                NavigationButton(
                    title: "links",
                    isSelected: currentState == .links,
                    action: { currentState = .links }
                )
                
                NavigationButton(
                    title: "drafts",
                    isSelected: currentState == .drafts,
                    action: { currentState = .drafts }
                )
            }
            
            Spacer()
            
            // Right-aligned add button
            NavigationButton(
                title: "add",
                isSelected: currentState == .add,
                action: { currentState = .add }
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(hex: "#FBFBFB"))
    }
}

struct NavigationButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(isSelected ? .black : .gray)
        }
    }
} 