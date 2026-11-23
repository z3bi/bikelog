//
//  AppScreen.swift
//  BikeLog
//
//  Created by Ameir Al-Zoubi on 11/22/26.
//

import SwiftUI

struct AppScreen<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            content
        }
    }
}
