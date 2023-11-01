//
//  NavigationBarModifier.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 31.10.23.
//

import SwiftUI

/// A view modifier to customize the appearance of the navigation bar.
struct NavigationBarModifier: ViewModifier {
    
    // MARK: - Static Properties
    
    /// The background color for the navigation bar.
    private static var backgroundColor = UIColor.clear
    
    /// The foreground color for the navigation bar.
    private static var foregroundColor = UIColor.white

    /// The default appearance for the navigation bar.
    private static var defaultBarAppearance: UINavigationBarAppearance = {
        // Configure appearance for the back button.
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        // Create the main appearance with a transparent background.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: foregroundColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: foregroundColor]
        appearance.shadowImage = UIImage()
        let backButtonImage = UIImage(systemName: "chevron.left")
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        appearance.backButtonAppearance = backButtonAppearance
        
        return appearance
    }()
    
    // MARK: - Initialization
    
    /// Initializes the NavigationBarModifier with a custom appearance.
    init(appearance: UINavigationBarAppearance = NavigationBarModifier.defaultBarAppearance) {
        // Set the appearance for various navigation bar styles.
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        // Set the tint color for bar button items.
        UIBarButtonItem.appearance().tintColor = NavigationBarModifier.foregroundColor
    }
    
    // MARK: - View Modifier Body
    
    /// Modifies the view's body to apply the navigation bar appearance.
    func body(content: Content) -> some View {
        ZStack {
            content
        }
    }
}

extension View {
    
    /// Applies the default navigation bar appearance to the view.
    func defaultNavigationBar() -> some View {
        self.modifier(NavigationBarModifier())
    }
}
