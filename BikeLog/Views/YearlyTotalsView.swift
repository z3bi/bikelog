import SwiftUI

struct YearlyTotalsView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    let manager: WorkoutManager

    var body: some View {
        let totals = WorkoutPeriodTotal.yearly(manager.workouts, calendar: calendar)
        let miles = WorkoutPeriodTotal.formatMiles(totals.reduce(0) { $0 + $1.miles }, width: .wide)
        let count = manager.activity.workoutCount(manager.workouts.count)
        let yearFormat = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone).year()

        Group {
            if totals.isEmpty {
                WorkoutListStatus(manager: manager)
            } else {
                List {
                    if manager.refreshState == .failed {
                        WorkoutListStatus(manager: manager)
                    }

                    WorkoutSummaryRow(title: String(localized: "Total"),
                                      distance: miles,
                                      count: count,
                                      isAllTimeHeader: true)

                    ForEach(totals) { total in
                        NavigationLink(value: ExerciseLog.Destination.monthlyTotals(year: total.startDate)) {
                            WorkoutSummaryRow(title: total.startDate.formatted(yearFormat),
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
        .navigationTitle(Text("All \(manager.activity.name) Workouts"))
    }
}
