//
//  SiriBlob.swift
//  IdeaSpot
//
//  Siri-style flowing blob animation with audio reactivity using Figma assets
//

import SwiftUI

struct SiriBlob: View {
    let isAnimating: Bool
    let audioLevel: Float

    @State private var isRotating = false

    var body: some View {
        ZStack {
            // Static background elements
            Image("shadow")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Image("icon-bg")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .scaleEffect(0.5)

            // Animated blob layers with IdeaSpot brand colors (reds/oranges + blue accents)
            ZStack {
                Image("blue-right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(isRotating ? -359 : 420))
                    .hueRotation(.degrees(isRotating ? 220 : 200)) // Blue accent
                    .rotation3DEffect(.degrees(75), axis: (x: 1, y: 0, z: isRotating ? -5 : 15))
                    .scaleEffect(0.5 + CGFloat(audioLevel) * 0.15)
                    .blendMode(.colorBurn)

                Image("blue-middle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(isRotating ? -359 : 420))
                    .hueRotation(.degrees(isRotating ? 210 : 230)) // Blue accent
                    .rotation3DEffect(.degrees(75), axis: (x: isRotating ? 1 : 5, y: 0, z: 0))
                    .blur(radius: 25)
                    .scaleEffect(0.5 + CGFloat(audioLevel) * 0.12)

                Image("pink-top")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(isRotating ? 320 : -359))
                    .hueRotation(.degrees(isRotating ? -20 : 15)) // Red/orange range
                    .scaleEffect(0.5 + CGFloat(audioLevel) * 0.1)

                Image("pink-left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(isRotating ? -359 : 179))
                    .hueRotation(.degrees(isRotating ? -10 : 25)) // Red/orange range
                    .scaleEffect(0.5 + CGFloat(audioLevel) * 0.13)

                Image("Intersect")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(isRotating ? 30 : -420))
                    .hueRotation(.degrees(isRotating ? 5 : 35)) // Orange range
                    .rotation3DEffect(.degrees(-360), axis: (x: 1, y: 5, z: 1))
                    .scaleEffect(0.5 + CGFloat(audioLevel) * 0.14)

                Image("green-left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(isRotating ? 359 : -358))
                    .hueRotation(.degrees(isRotating ? 20 : 40)) // Orange range
                    .rotation3DEffect(.degrees(330), axis: (x: 1, y: isRotating ? -5 : 15, z: 0))
                    .scaleEffect(0.5 + CGFloat(audioLevel) * 0.11)
                    .blur(radius: 25)

                Image("bottom-pink")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(isRotating ? 400 : -359))
                    .hueRotation(.degrees(isRotating ? -15 : 10)) // Red/orange range
                    .opacity(0.25)
                    .blendMode(.multiply)
                    .rotation3DEffect(.degrees(75), axis: (x: 5, y: isRotating ? 1 : -45, z: 0))
                    .scaleEffect(0.5 + CGFloat(audioLevel) * 0.16)
            }
            .blendMode(isRotating ? .hardLight : .difference)

            Image("highlight")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(isRotating ? 359 : 250))
                .hueRotation(.degrees(isRotating ? 15 : 30)) // Orange highlight
                .scaleEffect(0.5 + CGFloat(audioLevel) * 0.09)
        }
        .frame(width: 200, height: 200)
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
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: false)) {
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
            SiriBlob(isAnimating: true, audioLevel: 0.7)

            Text("Idle")
                .foregroundColor(.white)
            SiriBlob(isAnimating: false, audioLevel: 0.0)
        }
    }
}
