//
//  RecordButton.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let audioLevel: Float
    let action: () -> Void

    var body: some View {
        // Voice Agent Orb - always animating, tappable
        VoiceAgentOrb(
            isAnimating: true, // Always animate
            audioLevel: isRecording ? audioLevel : 0.0 // Only pulse when recording
        )
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        RecordButton(isRecording: false, audioLevel: 0.0, action: {})
        RecordButton(isRecording: true, audioLevel: 0.5, action: {})
    }
}
