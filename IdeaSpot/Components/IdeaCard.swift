//
//  IdeaCard.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import SwiftUI

struct IdeaCard: View {
    let idea: Idea

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(idea.title ?? "Untitled Idea")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Spacer()

                // Status indicator
                if idea.status == .processing {
                    ProgressView()
                        .tint(.orange)
                        .scaleEffect(0.8)
                } else if idea.status == .complete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                if idea.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }

            // Show processing text or transcript
            if idea.status == .processing {
                Text("Analyzing your idea...")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .italic()
            } else {
                Text(idea.originalTranscript)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            HStack {
                // Date
                Text(idea.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Idea type
                if let ideaType = idea.ideaType {
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(ideaType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Tags
                if !idea.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(idea.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accent.opacity(0.1))
                                .foregroundColor(.accent)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .opacity(idea.status == .processing ? 0.7 : 1.0)
    }
}

#Preview {
    IdeaCard(idea: Idea(
        originalTranscript: "Create a mobile app that helps people capture and organize their creative ideas using voice notes",
        title: "Creative Ideas App",
        isFavorite: true,
        tags: ["App", "Voice"]
    ))
    .padding()
}
