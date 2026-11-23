//
//  AppBackground.swift
//  BikeLog
//
//  Created by Ameir Al-Zoubi on 11/22/26.
//

import SwiftUI

struct ThemedListModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(Color.Theme.appBackground)
            .listStyle(.plain)
    }
}

extension View {
    func themedList() -> some View {
        modifier(ThemedListModifier())
    }
}
