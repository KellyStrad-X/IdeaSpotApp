//
//  OnboardingConfigureOutputsView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/17/25.
//

import SwiftUI

struct OnboardingConfigureOutputsView: View {
    var onSave: ([String]) -> Void

    @State private var selectedSections: Set<String> = Set(User.defaultOutputSections)
    @State private var currentPage = 0

    private let maxSelections = 5

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Configure Your Outputs")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("What do you want the AI to source for you?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Don't worry, we've chosen what we recommend.\nYou can change these later.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(.top, 40)
            .padding(.horizontal, 20)

            Spacer()

            // Paged content
            TabView(selection: $currentPage) {
                // First page - Default sections
                sectionListView(
                    sections: User.defaultOutputSections,
                    title: "Recommended Sections"
                )
                .tag(0)

                // Second page - Additional sections
                sectionListView(
                    sections: User.additionalOutputSections,
                    title: "Additional Options"
                )
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Spacer()

            // Counter and Save button
            VStack(spacing: 16) {
                Text("Choose \(selectedSections.count)/\(maxSelections)")
                    .font(.subheadline)
                    .foregroundColor(selectedSections.count > maxSelections ? .red : .secondary)

                Button(action: {
                    onSave(Array(selectedSections))
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedSections.count <= maxSelections ? Color.accent : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(selectedSections.count > maxSelections || selectedSections.isEmpty)
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 50)
        }
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private func sectionListView(sections: [String], title: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sections, id: \.self) { section in
                        sectionRow(section: section)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func sectionRow(section: String) -> some View {
        Button(action: {
            toggleSection(section)
        }) {
            HStack {
                Image(systemName: selectedSections.contains(section) ? "checkmark.square.fill" : "square")
                    .foregroundColor(selectedSections.contains(section) ? .accent : .secondary)
                    .font(.system(size: 20))

                Text(section)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
    }

    private func toggleSection(_ section: String) {
        if selectedSections.contains(section) {
            selectedSections.remove(section)
        } else {
            if selectedSections.count < maxSelections {
                selectedSections.insert(section)
            }
        }
    }
}

#Preview {
    OnboardingConfigureOutputsView(onSave: { _ in })
}
