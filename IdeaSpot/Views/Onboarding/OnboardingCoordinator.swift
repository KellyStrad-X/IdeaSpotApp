//
//  OnboardingCoordinator.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/17/25.
//

import SwiftUI
import SwiftData

struct OnboardingCoordinator: View {
    @Environment(\.modelContext) private var modelContext
    var onComplete: () -> Void

    @State private var currentStep = 0
    @State private var selectedOutputSections: [String] = []

    var body: some View {
        ZStack {
            switch currentStep {
            case 0:
                OnboardingWelcomeView {
                    withAnimation {
                        currentStep = 1
                    }
                }
                .transition(.opacity)

            case 1:
                OnboardingSignInView {
                    withAnimation {
                        currentStep = 2
                    }
                }
                .transition(.opacity)

            case 2:
                OnboardingConfigureOutputsView { sections in
                    selectedOutputSections = sections
                    withAnimation {
                        currentStep = 3
                    }
                }
                .transition(.opacity)

            case 3:
                OnboardingWelcomeMessageView {
                    completeOnboarding()
                }
                .transition(.opacity)

            default:
                EmptyView()
            }
        }
    }

    private func completeOnboarding() {
        // Create user with onboarding completed
        let user = User(
            hasCompletedOnboarding: true,
            selectedOutputSections: selectedOutputSections.isEmpty ? User.defaultOutputSections : selectedOutputSections
        )

        modelContext.insert(user)

        do {
            try modelContext.save()
            onComplete()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
}

#Preview {
    OnboardingCoordinator(onComplete: {})
        .modelContainer(for: [User.self], inMemory: true)
}
