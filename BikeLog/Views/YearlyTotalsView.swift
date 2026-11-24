import SwiftUI

struct YearlyTotalsView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    let manager: WorkoutManager

    var body: some View {
        let totals = WorkoutPeriodTotal.yearly(manager.workouts, unit: manager.unit, calendar: calendar)
        let allTimeDistance = WorkoutPeriodTotal.format(
            WorkoutPeriodTotal.distance(of: manager.workouts, in: manager.unit), width: .wide)
        let count = Workout.countDescription(manager.workouts.count)
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
                                      distance: allTimeDistance,
                                      count: count,
                                      isAllTimeHeader: true)

                    ForEach(totals) { total in
                        NavigationLink(value: ExerciseLog.Destination.monthlyTotals(year: total.startDate)) {
                            WorkoutSummaryRow(title: total.startDate.formatted(yearFormat),
                                              distance: total.formattedDistance,
                                              count: Workout.countDescription(total.count))
                        }
                    }
                    .listRowBackground(Color.Theme.appBackground)
                }
                .themedList()
            }
        }
        .navigationTitle(Text("All Cycling Workouts"))
    }
}

#Preview("Loaded", traits: .app) {
    let manager = WorkoutManager.preview(.loaded)
    NavigationStack { YearlyTotalsView(manager: manager) }
        .monitoring(manager)
}

#Preview("Loading", traits: .app) {
    let manager = WorkoutManager.preview(.firstLaunch)
    NavigationStack { YearlyTotalsView(manager: manager) }
        .monitoring(manager)
}

#Preview("Empty", traits: .app) {
    let manager = WorkoutManager.preview(.empty)
    NavigationStack { YearlyTotalsView(manager: manager) }
        .monitoring(manager)
}

#Preview("Error", traits: .app) {
    let manager = WorkoutManager.preview(.failed)
    NavigationStack { YearlyTotalsView(manager: manager) }
        .monitoring(manager)
}

#Preview("Error with Cache", traits: .app) {
    let manager = WorkoutManager.preview(.failedWithCache)
    NavigationStack { YearlyTotalsView(manager: manager) }
        .monitoring(manager)
}

#Preview("Metric", traits: .app) {
    let manager = WorkoutManager.preview(.loaded, unit: .kilometers)
    NavigationStack { YearlyTotalsView(manager: manager) }
        .monitoring(manager)
}
