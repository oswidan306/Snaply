import SwiftUI
import UIKit

public struct MonthCalendarView: View {
    @StateObject private var viewModel: DiaryViewModel
    
    public init() {
        _viewModel = StateObject(wrappedValue: DiaryViewModel(containerWidth: UIScreen.main.bounds.width - 32))
    }
    
    public var body: some View {
        VStack {
            CalendarView(
                viewModel: viewModel,
                isShowingCalendar: .constant(true),
                containerWidth: UIScreen.main.bounds.width - 32
            )
        }
    }
} 