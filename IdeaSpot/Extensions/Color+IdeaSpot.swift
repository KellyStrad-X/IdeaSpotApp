//
//  Color+IdeaSpot.swift
//  IdeaSpot
//
//  IdeaSpot color theme
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors

    /// IdeaSpot Orange - Primary accent color from logo
    static let ideaSpotOrange = Color(
        light: Color(hex: "#FF9500"),
        dark: Color(hex: "#FF9F0A")
    )

    // MARK: - Semantic Colors

    /// Primary accent color (IdeaSpot Orange)
    static let accent = ideaSpotOrange

    /// Processing/analyzing indicator
    static let processing = ideaSpotOrange

    // MARK: - Helper Initializers

    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Initialize Color with light/dark mode variants
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
