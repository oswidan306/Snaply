import SwiftUI

struct MonthCalendarView: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    @State private var days: [Date] = []
    
    var body: some View {
        VStack(spacing: 16) {
            Text("November 2024")
                .font(.system(size: 20, weight: .medium))
                .padding(.top)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days, id: \.self) { date in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .aspectRatio(1.0, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .onAppear {
            days = generateDaysInMonth()
        }
    }
    
    private func generateDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        let interval = calendar.dateInterval(of: .month, for: now)!
        
        var days: [Date] = []
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        
        // Add empty spaces for days before the first of the month
        for _ in 1..<firstWeekday {
            days.append(Date(timeIntervalSince1970: 0))
        }
        
        // Add all days in the month
        var currentDate = interval.start
        while currentDate <= interval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
} 