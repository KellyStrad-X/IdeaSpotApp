//
//  OnboardingSignInView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/17/25.
//

import SwiftUI
import AuthenticationServices

struct OnboardingSignInView: View {
    var onSignInComplete: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Sign in prompt
            VStack(spacing: 16) {
                Text("Hi, please")
                    .font(.title)
                    .foregroundColor(.secondary)

                Text("Sign-In to get Started.")
                    .font(.title)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(spacing: 16) {
                // Sign in with Apple button
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            handleAuthorization(authorization)
                        case .failure(let error):
                            print("Sign in failed: \(error.localizedDescription)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 50)

                // Temporary skip button for development
                #if DEBUG
                Button(action: {
                    onSignInComplete()
                }) {
                    Text("Skip for Now (Dev Only)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                #endif
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private func handleAuthorization(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // TODO: Store user credentials in SwiftData User model
            // For now, just continue to next screen
            print("User ID: \(appleIDCredential.user)")
            if let email = appleIDCredential.email {
                print("Email: \(email)")
            }
            if let fullName = appleIDCredential.fullName {
                print("Name: \(fullName.givenName ?? "") \(fullName.familyName ?? "")")
            }

            onSignInComplete()
        }
    }
}

#Preview {
    OnboardingSignInView(onSignInComplete: {})
}
