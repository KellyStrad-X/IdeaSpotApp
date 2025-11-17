//
//  IdeaDetailView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import SwiftUI
import SwiftData

struct IdeaDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var idea: Idea
    @State private var showingDeleteAlert = false
    @State private var isEditingTitle = false
    @State private var editedTitle: String = ""

    // Define section hierarchy for consistent ordering
    private let sectionOrder = [
        "Problem/Pain Point",
        "Target Customer",
        "Market Size/Opportunity",
        "Validation Plan",
        "First Steps",
        "Name Options"  // Always on, always at bottom
    ]

    // Computed property to return expansions in hierarchical order
    private var orderedExpansions: [AIExpansion] {
        idea.aiExpansions.sorted { expansion1, expansion2 in
            let index1 = sectionOrder.firstIndex(of: expansion1.sectionTitle) ?? Int.max
            let index2 = sectionOrder.firstIndex(of: expansion2.sectionTitle) ?? Int.max
            return index1 < index2
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Original prompt section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Original Idea")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(idea.originalTranscript)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // AI expansions (in hierarchical order)
                if !idea.aiExpansions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(orderedExpansions) { expansion in
                            AIExpansionCard(expansion: expansion)
                                .padding(.bottom, expansion.sectionTitle == "Name Options" ? 24 : (expansion.isCollapsed ? 12 : 24))
                        }
                    }
                }

                // Logo at bottom
                Image("ideaspot-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .opacity(0.3)
                    .padding(.top, 32)

                // Tags section
                if !idea.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        FlowLayout(spacing: 8) {
                            ForEach(idea.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accent.opacity(0.1))
                                    .foregroundColor(.accent)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(isEditingTitle ? "" : (idea.title ?? "Idea"))
        .navigationBarTitleDisplayMode(isEditingTitle ? .inline : .large)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if isEditingTitle {
                    HStack {
                        TextField("Idea Name", text: $editedTitle)
                            .font(.headline)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    idea.title = editedTitle
                                    isEditingTitle = false
                                }
                            }

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                idea.title = editedTitle
                                isEditingTitle = false
                            }
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accent)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    if !isEditingTitle {
                        Button(action: {
                            editedTitle = idea.title ?? "Idea"
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isEditingTitle = true
                            }
                        }) {
                            Image(systemName: "pencil.circle")
                                .foregroundColor(.accent)
                        }
                    }

                    Menu {
                    Button(action: {
                        idea.isFavorite.toggle()
                    }) {
                        Label(
                            idea.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: idea.isFavorite ? "star.fill" : "star"
                        )
                    }

                    Button(action: shareIdea) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Divider()

                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                }
            }
        }
        .alert("Delete Idea", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteIdea()
            }
        } message: {
            Text("Are you sure you want to delete this idea? This action cannot be undone.")
        }
    }

    private func shareIdea() {
        var shareText = "\(idea.title ?? "Idea")\n\n"
        shareText += "Original: \(idea.originalTranscript)\n\n"

        for expansion in idea.aiExpansions {
            shareText += "\(expansion.sectionTitle):\n\(expansion.content)\n\n"
        }

        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    private func deleteIdea() {
        modelContext.delete(idea)
    }
}

struct AIExpansionCard: View {
    @Bindable var expansion: AIExpansion
    @State private var isEditing = false
    @State private var editedContent = ""

    // Name Options is never collapsible
    private var isNameOptions: Bool {
        expansion.sectionTitle == "Name Options"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isNameOptions {
                // Name Options: no collapse UI, no edit button
                Text(expansion.sectionTitle)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(expansion.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.top, 4)
            } else {
                // Other sections: collapsible with edit button
                HStack {
                    Button(action: {
                        expansion.isCollapsed.toggle()
                    }) {
                        HStack {
                            Text(expansion.sectionTitle)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            if !expansion.isCollapsed {
                                if !isEditing {
                                    Button(action: {
                                        editedContent = expansion.content
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isEditing = true
                                        }
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 12))
                                            .foregroundColor(.accent)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            expansion.content = editedContent
                                            isEditing = false
                                        }
                                    }) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12))
                                            .foregroundColor(.accent)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Image(systemName: expansion.isCollapsed ? "chevron.right" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }

                if !expansion.isCollapsed {
                    if isEditing {
                        TextEditor(text: $editedContent)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accent.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.top, 4)
                    } else {
                        Text(expansion.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        IdeaDetailView(idea: Idea(
            originalTranscript: "Create an app for capturing creative ideas",
            title: "Creative Ideas App",
            aiExpansions: [
                AIExpansion(sectionTitle: "Problem Statement", content: "Many creative individuals struggle to capture and organize their fleeting ideas before they forget them."),
                AIExpansion(sectionTitle: "Solution", content: "A simple, fast mobile app that uses voice recording and AI to help capture, transcribe, and expand on creative ideas."),
                AIExpansion(sectionTitle: "Next Steps", content: "1. Build MVP with voice recording\n2. Integrate AI expansion\n3. Test with creative professionals")
            ],
            tags: ["App", "Voice", "Creativity"]
        ))
    }
    .modelContainer(for: Idea.self, inMemory: true)
}
