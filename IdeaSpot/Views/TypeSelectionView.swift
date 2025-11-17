//
//  TypeSelectionView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import SwiftUI
import SwiftData

struct TypeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode

    let transcription: String
    var onComplete: (() -> Void)?

    @State private var ideaName: String = ""
    @State private var isEditingName = false
    @State private var userEditedName = false // Track if user manually edited the name
    @State private var selectedType: IdeaType?
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // AI-suggested name section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Idea Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    HStack {
                        if isEditingName {
                            TextField("Enter idea name", text: $ideaName)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .textFieldStyle(.plain)
                                .onChange(of: ideaName) { _, _ in
                                    userEditedName = true
                                }
                        } else {
                            Text(ideaName.isEmpty ? "My Idea" : ideaName)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }

                        Button(action: {
                            isEditingName.toggle()
                        }) {
                            Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .foregroundColor(.accent)
                                .imageScale(.large)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                // Type selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    VStack(spacing: 12) {
                        TypeOptionRow(
                            type: .app,
                            isSelected: selectedType == .app
                        ) {
                            selectedType = .app
                        }

                        TypeOptionRow(
                            type: .software,
                            isSelected: selectedType == .software
                        ) {
                            selectedType = .software
                        }

                        TypeOptionRow(
                            type: .service,
                            isSelected: selectedType == .service
                        ) {
                            selectedType = .service
                        }

                        TypeOptionRow(
                            type: .businessAlone,
                            isSelected: selectedType == .businessAlone
                        ) {
                            selectedType = .businessAlone
                        }
                    }
                }

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()

                // Analyze button
                Button(action: {
                    Task {
                        await analyzeIdea()
                    }
                }) {
                    if isProcessing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    } else {
                        Text("Analyze")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .background(selectedType == nil ? Color.gray : Color.accent)
                .cornerRadius(12)
                .disabled(selectedType == nil || isProcessing)
            }
            .padding()
            .navigationTitle("Configure Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Use simple placeholder - Claude will generate proper name during analysis
                ideaName = "My Idea"
            }
        }
    }

    private func analyzeIdea() async {
        guard let selectedType else { return }

        isProcessing = true
        errorMessage = nil

        // Create the idea immediately with PROCESSING status
        let idea = Idea(
            originalTranscript: transcription,
            title: ideaName,
            status: .processing,
            ideaType: selectedType
        )

        // Save to SwiftData
        modelContext.insert(idea)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save idea: \(error.localizedDescription)"
            isProcessing = false
            return
        }

        // Dismiss and return to dashboard
        dismiss()

        // Call completion handler to dismiss the entire sheet stack
        onComplete?()

        // Process AI expansion in background
        Task.detached {
            do {
                print("📡 Calling expandIdea Cloud Function...")
                let response = try await FirebaseService.shared.expandIdea(transcript: transcription)
                print("✅ Received response - Title: \(response.title), Expansions: \(response.expansions.count)")

                // Update the idea with AI results on main thread
                await MainActor.run {
                    // Only update title if user didn't manually edit it
                    if !userEditedName {
                        idea.title = response.title
                    }
                    idea.status = .complete
                    idea.updatedAt = Date()

                    // Add AI expansions
                    for expansionData in response.expansions {
                        print("  - Section: \(expansionData.sectionTitle)")
                        // Only "Name Options" starts open, all others start collapsed
                        let isNameOptions = expansionData.sectionTitle == "Name Options"
                        let expansion = AIExpansion(
                            sectionTitle: expansionData.sectionTitle,
                            content: expansionData.content,
                            isCollapsed: !isNameOptions
                        )
                        idea.aiExpansions.append(expansion)
                    }

                    do {
                        try modelContext.save()
                        print("✅ Successfully saved idea with AI expansions")
                    } catch {
                        print("❌ Failed to save AI results: \(error)")
                        idea.status = .failed
                    }
                }
            } catch {
                await MainActor.run {
                    print("❌ Failed to process idea: \(error)")
                    print("   Error details: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                        print("   UserInfo: \(nsError.userInfo)")
                    }
                    idea.status = .failed
                    try? modelContext.save()
                }
            }
        }

        isProcessing = false
    }

}

struct TypeOptionRow: View {
    let type: IdeaType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accent : .gray)
                    .imageScale(.large)

                Text(type.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TypeSelectionView(transcription: "I have an idea for an app that helps people track their daily water intake", onComplete: nil)
        .modelContainer(for: Idea.self, inMemory: true)
}
