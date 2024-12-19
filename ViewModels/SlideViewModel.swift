import SwiftUI

class SlideViewModel: ObservableObject {
    @Published var slideOffset: CGFloat = 0
    @Published var isShowingCalendar: Bool = false
    
    func showCalendar() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            slideOffset = -UIScreen.main.bounds.height - 40
            isShowingCalendar = true
        }
    }
    
    func hideCalendar() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            slideOffset = 0
            isShowingCalendar = false
        }
    }
} 