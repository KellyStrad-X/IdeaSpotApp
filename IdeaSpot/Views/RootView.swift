//
//  RootView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/17/25.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @State private var showOnboarding = false
    @State private var isCheckingOnboarding = true

    var body: some View {
        Group {
            if isCheckingOnboarding {
                // Loading state
                ProgressView()
            } else if showOnboarding {
                // Show onboarding
                OnboardingCoordinator {
                    showOnboarding = false
                }
            } else {
                // Show main app
                ContentView()
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }

    private func checkOnboardingStatus() {
        // Check if user has completed onboarding
        if let user = users.first {
            showOnboarding = !user.hasCompletedOnboarding
        } else {
            // No user found, show onboarding
            showOnboarding = true
        }
        isCheckingOnboarding = false
    }
}

#Preview {
    RootView()
        .modelContainer(for: [User.self, Idea.self, AIExpansion.self], inMemory: true)
}
