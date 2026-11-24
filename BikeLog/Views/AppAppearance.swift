//
//  AppAppearance.swift
//  BikeLog
//

import SwiftUI

enum AppAppearance {
    /// UIKit appearance proxies aren't applied in Xcode previews unless this runs, so previews call it too.
    @MainActor
    static func configure() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(resource: .Theme.primary)]
        navBarAppearance.titleTextAttributes = titleAttributes
        navBarAppearance.largeTitleTextAttributes = titleAttributes

        let navBarProxy = UINavigationBar.appearance()
        navBarProxy.standardAppearance = navBarAppearance
        navBarProxy.scrollEdgeAppearance = navBarAppearance
        navBarProxy.compactAppearance = navBarAppearance
        navBarProxy.compactScrollEdgeAppearance = navBarAppearance
    }
}

extension View {
    func appColorScheme() -> some View {
        preferredColorScheme(.dark)
    }
}
