//
//  OnboardingWelcomeView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/17/25.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    var onContinue: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Animated Dictate Bubble
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color.accent.opacity(0.1))
                    .frame(width: 220, height: 220)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0.3 : 0.6)

                // Main circle
                Circle()
                    .fill(Color.accent.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .overlay(
                        Circle()
                            .stroke(Color.accent, lineWidth: 3)
                    )

                // Microphone icon
                Image(systemName: "mic.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.accent)
            }
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }

            Spacer()

            // Get Started button
            Button(action: onContinue) {
                Text("Get Started")
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
}

#Preview {
    OnboardingWelcomeView(onContinue: {})
}
