//
//  VoiceAgentOrb.swift
//  IdeaSpot
//
//  Voice Agent orb animation with brand-consistent orange/peach color palette
//

import SwiftUI

struct VoiceAgentOrb: View {
    let isAnimating: Bool
    let audioLevel: Float

    @State private var isRotating = false

    var body: some View {
        ZStack {
            // Dark base shadow
            Image("voice-ellipse-13")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)

            // Main orange orb base
            Image("voice-ellipse-11")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(isRotating ? 360 : 0))

            // Rotating gradient layers for depth
            Image("voice-ellipse-12")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(isRotating ? -360 : 0))
                .blendMode(.screen)
                .opacity(0.7)

            // Animated ray layers - create the flowing starburst effect
            ZStack {
                // First set of rays (LooperGroup_14 variants)
                Image("voice-rays-14")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .blendMode(.plusLighter)

                Image("voice-rays-14-1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(isRotating ? -360 : 0))
                    .blendMode(.plusLighter)

                Image("voice-rays-14-2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .blendMode(.plusLighter)

                // Second set of rays (LooperGroup_18 variants)
                Image("voice-rays-18")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(isRotating ? -360 : 0))
                    .blendMode(.plusLighter)

                Image("voice-rays-18-1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .blendMode(.plusLighter)

                Image("voice-rays-18-2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(isRotating ? -360 : 0))
                    .blendMode(.plusLighter)
            }

            // Bright center glow to match Figma design
            ZStack {
                // Bright peachy-white center core
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.95, blue: 0.85),  // Bright peachy-white center
                                Color(red: 1.0, green: 0.75, blue: 0.55),  // Peachy middle
                                Color.clear                                 // Transparent edge
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .blur(radius: 5)

                // Subtle rotating gradient overlay on center
                Image("voice-ellipse-26")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .blendMode(.screen)
                    .opacity(0.5)
            }
        }
        .drawingGroup()
        .frame(width: 150, height: 150)
        .clipShape(Circle())
        .scaleEffect(1.0 + CGFloat(audioLevel) * 0.25)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioLevel)
        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.4), radius: 20, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .onAppear {
            if isAnimating {
                startAnimation()
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            isRotating.toggle()
        }
    }

    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            isRotating = false
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            Text("Recording")
                .foregroundColor(.white)
            VoiceAgentOrb(isAnimating: true, audioLevel: 0.7)

            Text("Idle")
                .foregroundColor(.white)
            VoiceAgentOrb(isAnimating: false, audioLevel: 0.0)
        }
    }
}
