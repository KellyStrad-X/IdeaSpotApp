//
//  OnboardingWelcomeMessageView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/17/25.
//

import SwiftUI

struct OnboardingWelcomeMessageView: View {
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Welcome message
            VStack(spacing: 20) {
                Text("Welcome to")
                    .font(.title)
                    .foregroundColor(.secondary)

                Text("IdeaSpot!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accent)

                VStack(spacing: 12) {
                    Text("We want to turn your fleeting ideas into projects that...")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

                    VStack(spacing: 8) {
                        inspirationalText("Align with your PASSION...")
                        inspirationalText("EXCITE you...")
                        inspirationalText("Help you QUIT your job")
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 30)

            Spacer()

            // Generate first idea button
            Button(action: onComplete) {
                Text("Generate your First Idea!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accent)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private func inspirationalText(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.accent)

            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    OnboardingWelcomeMessageView(onComplete: {})
}
