//
//  ListeningText.swift
//  IdeaSpot
//
//  "Listening" text with slow pulse effect
//

import SwiftUI

struct ListeningText: View {
    @State private var isPulsing = false

    var body: some View {
        HStack {
            Spacer()
            Text("Listening")
                .font(.headline)
                .foregroundColor(.white)
                .opacity(isPulsing ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
                .onAppear {
                    isPulsing = true
                }
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ListeningText()
    }
}
