import SwiftUI

/// FocusFlow Brand Colors
/// Note: Color(hex:) extension is already defined in Theme.swift
/// This enum provides brand colors that match the "Calm Focus" theme
enum Brand {
  /// Primary accent color (cyan-400)
  static let accent = Color(hex:"#22D3EE")
  
  /// Accent color when pressed (cyan-500)
  static let accentPressed = Color(hex:"#06B6D4")
  
  /// Leaf/green color (green-400) - matches short break ring color
  static let leaf = Color(hex:"#34D399")

  /// Brand background gradient - matches Calm Focus theme
  static var background: LinearGradient {
    LinearGradient(colors: [
      Color(hex:"#0E172A"),
      Color(hex:"#132E4B"),
      Color(hex:"#0A2F2E")
    ], startPoint: .topLeading, endPoint: .bottomTrailing)
  }
  
  /// Convenience: Use Theme colors for consistency
  /// Brand colors match Theme.calmFocus colors
  static var themeAccent: Color {
    Theme.accent
  }
  
  static var themeBackground: LinearGradient {
    Theme.backgroundGradient
  }
}
