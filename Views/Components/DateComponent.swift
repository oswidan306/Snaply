import SwiftUI

struct DateComponent: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("PRESENT")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .monospaced()
                .tracking(2)
            
            Text("November 18th, 2024")
                .font(.custom("Times New Roman", size: 32))
                .italic()
                .foregroundColor(.black)
        }
    }
} 