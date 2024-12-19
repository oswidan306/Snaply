import SwiftUI

struct ResizeHandle: View {
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.5))
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 1)
            )
    }
} 