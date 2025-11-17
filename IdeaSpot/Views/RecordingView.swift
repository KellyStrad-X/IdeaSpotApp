//
//  RecordingView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import SwiftUI
import SwiftData

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = RecordingViewModel()
    @State private var showingReviewEdit = false
    @State private var shouldDismiss = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()

                // Record button with new layout
                VStack(spacing: viewModel.isRecording ? 28 : 24) {
                    // Status text above orb
                    if viewModel.isRecording {
                        ListeningText()
                            .transition(.opacity)
                    } else {
                        Text("Tap to start recording")
                            .font(.headline)
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }

                    // Voice Agent Orb with same tap behavior as old button
                    RecordButton(
                        isRecording: viewModel.isRecording,
                        audioLevel: viewModel.speechService.audioLevel
                    ) {
                        if viewModel.isRecording {
                            viewModel.stopRecording()
                        } else {
                            Task {
                                await viewModel.startRecording()
                            }
                        }
                    }
                    .offset(y: viewModel.isRecording ? -10 : 0)

                    // Add small spacing when not recording to push helper text slightly lower
                    if !viewModel.isRecording {
                        Spacer()
                            .frame(height: 16)
                    }

                    // Helper text OR spoken transcription below orb
                    if viewModel.transcription.isEmpty {
                        VStack(spacing: 4) {
                            Text("Try saying:")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))

                            Text("I have an idea for an app that...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            Text("I have an idea for a software that does...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            Text("I have an idea for a service that offers...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity)
                    } else {
                        Text(viewModel.transcription)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.horizontal, 32)
                            .transition(.opacity)
                    }
                }

                Spacer()

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.cancel()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        // Copy current transcription (live or saved) to editable version
                        viewModel.editableTranscription = viewModel.transcription
                        showingReviewEdit = true
                    }) {
                        Text("Review")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .background(viewModel.transcription.isEmpty ? Color.gray : Color.accent)
                    .cornerRadius(12)
                    .disabled(viewModel.transcription.isEmpty)
                }
            }
            .padding()
            .animation(.easeInOut(duration: 0.3), value: viewModel.isRecording)
            .navigationTitle("Record Idea")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingReviewEdit) {
                ReviewEditView(transcription: $viewModel.editableTranscription, onComplete: {
                    showingReviewEdit = false
                    shouldDismiss = true
                })
            }
            .onChange(of: shouldDismiss) { _, newValue in
                if newValue {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    RecordingView()
        .modelContainer(for: Idea.self, inMemory: true)
}
