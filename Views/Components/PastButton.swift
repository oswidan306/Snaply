import SwiftUI

struct PastButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("PAST")
                .font(.system(size: 14, weight: .regular))
                .tracking(2)
                .foregroundColor(.gray)
        }
        .padding(.top, -18)
    }
} 