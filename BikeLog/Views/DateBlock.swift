//
//  DateBlock.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/16/22.
//

import SwiftUI

struct DateBlock: View {
    let date: Date

    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 5, verticalSpacing: 0) {
            GridRow {
                Text(date.formatted(.dateTime.month(.abbreviated)))
                    .textCase(.uppercase)
                    .font(.callout.bold())
                    .foregroundStyle(Color.Theme.red)
                Text(date.formatted(.dateTime.year()))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.Theme.darkGreen)
            }

            GridRow {
                Text(date.formatted(.dateTime.day()))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.Theme.red)
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .textCase(.uppercase)
                    .font(.headline)
                    .foregroundStyle(Color.Theme.darkGreen)
            }
        }
    }
}

#Preview("January 9", traits: .sizeThatFitsLayout) {
    let date = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2022, month: 1, day: 9)
    DateBlock(date: date.date ?? .now)
        .padding()
}

#Preview("December 1", traits: .sizeThatFitsLayout) {
    let date = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2021, month: 12, day: 1)
    DateBlock(date: date.date ?? .now)
        .padding()
}
