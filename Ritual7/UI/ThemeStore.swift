import SwiftUI

/// App-wide theme model supporting color themes and appearance.
final class ThemeStore: ObservableObject {
    /// Optional override for system appearance. Keep `nil` to follow system.
    @Published var colorScheme: ColorScheme? = nil
    
    /// Current color theme (feminine or masculine)
    @AppStorage("colorTheme") var colorTheme: Theme.ColorTheme = .feminine {
        didSet {
            Theme.currentTheme = colorTheme
            // Trigger UI refresh
            objectWillChange.send()
        }
    }
    
    /// Example accent you can expose to views if you want to theme chips/buttons.
    @AppStorage("accentHue") var accentHue: Double = 0.72
    var accentColor: Color { Color(hue: accentHue, saturation: 0.95, brightness: 1.0) }
    
    init() {
        // Set the current theme when ThemeStore is initialized
        Theme.currentTheme = colorTheme
    }
}
//
//  ThemeStore.swift
//  Ritual7
//
//  Created by William Alston on 9/15/25.
//

