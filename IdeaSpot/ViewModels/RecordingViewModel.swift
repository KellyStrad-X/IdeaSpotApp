//
//  RecordingViewModel.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import Foundation
import SwiftData
internal import Speech

@Observable
class RecordingViewModel {
    var speechService = SpeechRecognitionService()
    var isProcessingAI = false
    var errorMessage: String?
    var editableTranscription: String = ""
    var savedTranscription: String = ""

    var transcription: String {
        if !editableTranscription.isEmpty {
            return editableTranscription
        }

        if !speechService.transcription.isEmpty {
            return speechService.transcription
        }

        return savedTranscription
    }

    var isRecording: Bool {
        speechService.isRecording
    }

    func startRecording() async {
        editableTranscription = ""

        // Request authorization if needed
        if speechService.authorizationStatus != .authorized {
            let authorized = await speechService.requestAuthorization()
            guard authorized else {
                errorMessage = "Speech recognition permission denied"
                return
            }
        }

        // Start recording
        do {
            try speechService.startRecording()
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    func stopRecording() {
        savedTranscription = speechService.transcription
        speechService.stopRecording()
    }

    func processWithAI(modelContext: ModelContext) async {
        guard !transcription.isEmpty else {
            errorMessage = "No transcription to process"
            return
        }

        isProcessingAI = true
        errorMessage = nil

        do {
            // Call Firebase Cloud Function to expand the idea
            let response = try await FirebaseService.shared.expandIdea(transcript: transcription)

            // Create new Idea with AI expansions
            let idea = Idea(
                originalTranscript: transcription,
                title: response.title
            )

            // Add AI expansions
            for expansionData in response.expansions {
                let expansion = AIExpansion(
                    sectionTitle: expansionData.sectionTitle,
                    content: expansionData.content
                )
                idea.aiExpansions.append(expansion)
            }

            // Save to SwiftData
            modelContext.insert(idea)
            try modelContext.save()

            // Reset for next recording
            reset()

        } catch {
            errorMessage = "Failed to process idea: \(error.localizedDescription)"
        }

        isProcessingAI = false
    }

    func reset() {
        speechService.reset()
        savedTranscription = ""
        editableTranscription = ""
        errorMessage = nil
    }

    func cancel() {
        if isRecording {
            stopRecording()
        }
        reset()
    }
}
