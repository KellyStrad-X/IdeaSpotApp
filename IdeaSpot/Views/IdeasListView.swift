//
//  IdeasListView.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import SwiftUI
import SwiftData

struct IdeasListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Idea.createdAt, order: .reverse) private var ideas: [Idea]

    @State private var viewModel = IdeasListViewModel()
    @State private var isShowingRecordingSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                if ideas.isEmpty {
                    emptyStateView
                } else {
                    ideasListContent
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        newIdeaButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search ideas")
            .sheet(isPresented: $isShowingRecordingSheet) {
                RecordingView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Ideas Yet")
                .font(.title2)
                .foregroundColor(.primary)

            Text("Tap the button below to record your first idea")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var ideasListContent: some View {
        List {
            ForEach(sortedSections, id: \.0) { sectionTitle, sectionIdeas in
                Section(header: Text(sectionTitle)) {
                    ForEach(sectionIdeas) { idea in
                        NavigationLink(destination: IdeaDetailView(idea: idea)) {
                            IdeaCard(idea: idea)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.clear)
                        }
                    }
                    .onDelete { indexSet in
                        deleteIdeas(at: indexSet, in: sectionIdeas)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private var newIdeaButton: some View {
        Button(action: {
            isShowingRecordingSheet = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.accent)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }

    private var sortedSections: [(String, [Idea])] {
        viewModel.ideas = ideas
        return viewModel.groupedIdeas.sorted { first, second in
            let order: [String] = ["Today", "Yesterday", "This Week", "This Month"]
            if let firstIndex = order.firstIndex(of: first.key),
               let secondIndex = order.firstIndex(of: second.key) {
                return firstIndex < secondIndex
            }
            return first.key > second.key
        }
    }

    private func deleteIdeas(at offsets: IndexSet, in sectionIdeas: [Idea]) {
        for index in offsets {
            let idea = sectionIdeas[index]
            modelContext.delete(idea)
        }
    }
}

#Preview {
    IdeasListView()
        .modelContainer(for: Idea.self, inMemory: true)
}
