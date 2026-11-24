import SwiftUI

struct MonthlyTotalsView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    let year: Date
    let manager: WorkoutManager

    var body: some View {
        let totals = WorkoutPeriodTotal.monthly(manager.workouts, in: year, unit: manager.unit, calendar: calendar)
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
                                              distance: total.formattedDistance,
                                              count: Workout.countDescription(total.count))
                        }
                    }
                    .listRowBackground(Color.Theme.appBackground)
                }
                .themedList()
            }
        }
        .navigationTitle(year.formatted(dateFormat.year()))
    }
}

#Preview("Loaded", traits: .app) {
    let manager = WorkoutManager.preview(.loaded)
    NavigationStack { MonthlyTotalsView(year: .now, manager: manager) }
        .monitoring(manager)
}

#Preview("Loading", traits: .app) {
    let manager = WorkoutManager.preview(.firstLaunch)
    NavigationStack { MonthlyTotalsView(year: .now, manager: manager) }
        .monitoring(manager)
}

#Preview("Error with Cache", traits: .app) {
    let manager = WorkoutManager.preview(.failedWithCache)
    NavigationStack { MonthlyTotalsView(year: .now, manager: manager) }
        .monitoring(manager)
}

#Preview("Metric", traits: .app) {
    let manager = WorkoutManager.preview(.loaded, unit: .kilometers)
    NavigationStack { MonthlyTotalsView(year: .now, manager: manager) }
        .monitoring(manager)
}
