//
//  IdeasListViewModel.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import Foundation
import SwiftData

@Observable
class IdeasListViewModel {
    var ideas: [Idea] = []
    var searchText = ""
    var isShowingRecordingSheet = false

    var filteredIdeas: [Idea] {
        if searchText.isEmpty {
            return ideas
        }
        return ideas.filter { idea in
            idea.title?.localizedCaseInsensitiveContains(searchText) == true ||
            idea.originalTranscript.localizedCaseInsensitiveContains(searchText)
        }
    }

    var groupedIdeas: [String: [Idea]] {
        Dictionary(grouping: filteredIdeas) { idea in
            formatSectionHeader(for: idea.createdAt)
        }
    }

    private func formatSectionHeader(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            return "This Week"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
            return "This Month"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
    }

    func deleteIdea(_ idea: Idea, modelContext: ModelContext) {
        modelContext.delete(idea)
    }

    func toggleFavorite(_ idea: Idea) {
        idea.isFavorite.toggle()
        idea.updatedAt = Date()
    }
}
