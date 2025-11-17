//
//  SettingsView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @State private var isSigningOut = false

    var body: some View {
        NavigationStack {
            Form {
                // Account section
                Section("Account") {
                    if let user = Auth.auth().currentUser {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email ?? "Unknown")
                                .foregroundColor(.secondary)
                        }

                        Button(role: .destructive, action: signOut) {
                            if isSigningOut {
                                ProgressView()
                            } else {
                                Text("Sign Out")
                            }
                        }
                        .disabled(isSigningOut)
                    } else {
                        Text("Not signed in")
                            .foregroundColor(.secondary)
                    }
                }

                // Debug section (only in DEBUG builds)
                #if DEBUG
                Section("Developer") {
                    Button(role: .destructive, action: resetOnboarding) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset Onboarding")
                        }
                    }

                    Button(role: .destructive, action: clearAllData) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All Data")
                        }
                    }
                }
                #endif

                // App info
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.buildNumber)
                            .foregroundColor(.secondary)
                    }
                }

                // Privacy
                Section {
                    Link(destination: URL(string: "https://yourwebsite.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://yourwebsite.com/terms")!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func signOut() {
        isSigningOut = true
        do {
            try FirebaseService.shared.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
        isSigningOut = false
    }

    #if DEBUG
    private func resetOnboarding() {
        // Delete all users to trigger onboarding again
        for user in users {
            modelContext.delete(user)
        }
        try? modelContext.save()

        // Force app to restart by exiting
        exit(0)
    }

    private func clearAllData() {
        // Delete all data
        for user in users {
            modelContext.delete(user)
        }
        try? modelContext.save()

        // Force app to restart
        exit(0)
    }
    #endif
}

// Helper extension for app version
extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

#Preview {
    SettingsView()
}
