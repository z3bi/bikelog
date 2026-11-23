import SwiftUI

struct MonthlyTotalsView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    let year: Date
    let manager: WorkoutManager

    var body: some View {
        let totals = WorkoutPeriodTotal.monthly(manager.workouts, in: year, calendar: calendar)
        let dateFormat = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)

        Group {
            if totals.isEmpty {
                WorkoutListStatus(manager: manager)
            } else {
                List {
                    if manager.refreshState == .failed {
                        WorkoutListStatus(manager: manager)
                    }
                    ForEach(totals) { total in
                        let interval = StatisticalPeriod.month.dateInterval(from: total.startDate, calendar: calendar)
                        NavigationLink(value: ExerciseLog.Destination.periodWorkouts(period: .month, interval: interval)) {
                            WorkoutSummaryRow(title: total.startDate.formatted(dateFormat.month(.wide)),
                                              distance: total.formattedMiles,
                                              count: manager.activity.workoutCount(total.count))
                        }
                    }
                    .listRowBackground(Color.Theme.appBackground)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.Theme.appBackground)
            }
        }
        .navigationTitle(year.formatted(dateFormat.year()))
    }
}
