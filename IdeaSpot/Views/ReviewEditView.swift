//
//  ReviewEditView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import SwiftUI

struct ReviewEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var transcription: String
    var onComplete: (() -> Void)?
    @State private var showingTypeSelection = false
    @State private var shouldDismiss = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Instructions
                Text("Review and edit your idea")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Editable text area
                TextEditor(text: $transcription)
                    .font(.body)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)

                Spacer()

                // Save button
                Button(action: {
                    showingTypeSelection = true
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .background(transcription.isEmpty ? Color.gray : Color.accent)
                .cornerRadius(12)
                .disabled(transcription.isEmpty)
            }
            .padding()
            .navigationTitle("New Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingTypeSelection) {
                TypeSelectionView(transcription: transcription, onComplete: {
                    showingTypeSelection = false
                    shouldDismiss = true
                })
            }
            .onChange(of: shouldDismiss) { _, newValue in
                if newValue {
                    dismiss()
                    // After dismissing this view, trigger parent to dismiss too
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onComplete?()
                    }
                }
            }
        }
    }
}

#Preview {
    ReviewEditView(transcription: .constant("I have an idea for an app that helps people track their daily water intake"))
}
