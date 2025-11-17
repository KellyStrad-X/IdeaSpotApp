//
//  User.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/17/25.
//

import Foundation
import SwiftData

enum SubscriptionTier: String, Codable {
    case free = "FREE"
    case proMonthly = "PRO_MONTHLY"  // $4.99/mo
    case proYearly = "PRO_YEARLY"    // $49/yr
}

@Model
final class User {
    var id: UUID
    var email: String?
    var fullName: String?
    var createdAt: Date
    var hasCompletedOnboarding: Bool
    var subscriptionTier: SubscriptionTier
    var ideasCount: Int
    var selectedOutputSections: [String] // AI output preferences

    init(
        id: UUID = UUID(),
        email: String? = nil,
        fullName: String? = nil,
        createdAt: Date = Date(),
        hasCompletedOnboarding: Bool = false,
        subscriptionTier: SubscriptionTier = .free,
        ideasCount: Int = 0,
        selectedOutputSections: [String] = []
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.createdAt = createdAt
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.subscriptionTier = subscriptionTier
        self.ideasCount = ideasCount
        self.selectedOutputSections = selectedOutputSections
    }
}

// Default AI output sections
extension User {
    static let defaultOutputSections = [
        "Specify the Problem/Pain Point",
        "Find the Target Customer",
        "Market Size/Opportunity",
        "Validation Plan",
        "First Steps"
    ]

    static let additionalOutputSections = [
        "Source Alternatives/Competitors",
        "Explain the unique value proposition",
        "Minimum Feature Set",
        "Risks & Challenges",
        "Explore revenue models",
        "Key Features"
    ]

    static let allAvailableSections = defaultOutputSections + additionalOutputSections
}
