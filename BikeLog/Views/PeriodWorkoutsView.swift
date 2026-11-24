import SwiftUI

struct PeriodWorkoutsView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    let period: StatisticalPeriod
    let interval: DateInterval
    let manager: WorkoutManager

    private var title: Text {
        let titleFormat = Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
        switch period {
        case .all:
            return Text(period.name)
        case .year:
            return Text(interval.start, format: titleFormat.year())
        case .month:
            return Text(interval.start, format: titleFormat.month(.wide).year())
        case .week:
            return Text("Week of \(interval.start.formatted(titleFormat.month(.abbreviated).day().year()))")
        }
    }

    var body: some View {
        let workouts = WorkoutPeriodTotal.workouts(manager.workouts, in: interval)

        Group {
            if workouts.isEmpty {
                WorkoutListStatus(manager: manager)
            } else {
                List {
                    if manager.refreshState == .failed {
                        WorkoutListStatus(manager: manager)
                            .listRowBackground(Color.Theme.appBackground)
                    }
                    WorkoutRows(workouts: workouts, unit: manager.unit)
                        .listRowBackground(Color.Theme.appBackground)
                }
                .themedList()
            }
        }
        .navigationTitle(title)
    }
}

#Preview("Week", traits: .app) {
    let manager = WorkoutManager.preview(.loaded)
    NavigationStack {
        PeriodWorkoutsView(period: .week, interval: StatisticalPeriod.week.dateInterval(), manager: manager)
    }
    .monitoring(manager)
}

#Preview("Month", traits: .app) {
    let manager = WorkoutManager.preview(.loaded)
    NavigationStack {
        PeriodWorkoutsView(period: .month, interval: StatisticalPeriod.month.dateInterval(), manager: manager)
    }
    .monitoring(manager)
}

#Preview("Empty Period", traits: .app) {
    let manager = WorkoutManager.preview(.loaded)
    let interval = StatisticalPeriod.month.dateInterval(from: .now.addingTimeInterval(-5 * 365 * 86_400))
    NavigationStack {
        PeriodWorkoutsView(period: .month, interval: interval, manager: manager)
    }
    .monitoring(manager)
}

#Preview("Error with Cache", traits: .app) {
    let manager = WorkoutManager.preview(.failedWithCache)
    NavigationStack {
        PeriodWorkoutsView(period: .month, interval: StatisticalPeriod.month.dateInterval(), manager: manager)
    }
    .monitoring(manager)
}
