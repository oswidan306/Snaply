import SwiftUI
import UIKit

public struct CalendarView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var isShowingCalendar: Bool
    let containerWidth: CGFloat
    
    public init(viewModel: DiaryViewModel, isShowingCalendar: Binding<Bool>, containerWidth: CGFloat) {
        self.viewModel = viewModel
        self._isShowingCalendar = isShowingCalendar
        self.containerWidth = containerWidth
    }
    
    public var body: some View {
        VStack(spacing: 32) {
            // Month selector
            HStack {
                Button(action: { viewModel.previousMonth() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .imageScale(.large)
                }
                
                Spacer()
                
                Text(viewModel.currentMonthYear)
                    .font(.custom("Times New Roman", size: 24))
                    .italic()
                
                Spacer()
                
                Button(action: { viewModel.nextMonth() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .imageScale(.large)
                }
            }
            .padding(.horizontal, 16)
            
            // Photo grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
                spacing: 16
            ) {
                ForEach(viewModel.entriesForCurrentMonth, id: \.id) { entry in
                    Image(uiImage: entry.photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 120)
                        .clipped()
                        .shadow(radius: 8)
                        .onTapGesture {
                            viewModel.selectDate(entry.date)
                        }
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .onAppear {
            viewModel.generateCalendarDays()
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEntry: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .black)
                
                if hasEntry {
                    Circle()
                        .fill(isSelected ? .white : .blue)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(isSelected ? Color.black : Color.clear)
            .clipShape(Circle())
        }
    }
}
