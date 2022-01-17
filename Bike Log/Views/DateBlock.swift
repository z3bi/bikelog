//
//  DateBlock.swift
//  Bike Log
//
//  Created by Ameir Al-Zoubi on 1/16/22.
//

import SwiftUI

struct DateBlock: View {
    let date: Date
    
    let bottomHeight: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 5) {
            VStack(alignment: .center, spacing: 0) {
                Text(date.formatted(.dateTime.month(.abbreviated)))
                    .textCase(.uppercase)
                    .font(.system(size: 16, weight: .bold))

                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 24, weight: .semibold))
                    .frame(height: bottomHeight)
            }
            .foregroundColor(.Theme.red)

            VStack(alignment: .center, spacing: 0) {
                Text(date.formatted(.dateTime.year()))
                    .font(.system(size: 15, weight: .semibold))
                    
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .textCase(.uppercase)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(height: bottomHeight)
            }
            .foregroundColor(.Theme.darkGreen)
        }
    }
}

struct DateBlock_Previews: PreviewProvider {
    static let jan9: Date = {
        let comps = DateComponents(year: 2022, month: 1, day: 9)
        return Calendar.current.date(from: comps)!
    }()
    
    static let dec1: Date = {
        let comps = DateComponents(year: 2021, month: 12, day: 1)
        return Calendar.current.date(from: comps)!
    }()
    static var previews: some View {
        DateBlock(date: jan9)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("jan 9")
        
        DateBlock(date: dec1)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("dec 1")
    }
}
