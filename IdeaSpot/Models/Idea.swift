//
//  Idea.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import Foundation
import SwiftData

enum IdeaType: String, Codable {
    case app = "App"
    case software = "Software"
    case service = "Service"
    case businessAlone = "Business Alone"
}

enum IdeaStatus: String, Codable {
    case processing = "PROCESSING"
    case complete = "COMPLETE"
    case failed = "FAILED"
}

@Model
final class Idea {
    var id: UUID
    var originalTranscript: String
    var createdAt: Date
    var updatedAt: Date

    // AI-generated content
    var title: String?
    var aiExpansions: [AIExpansion]

    // Metadata
    var isFavorite: Bool
    var tags: [String]
    var status: IdeaStatus
    var ideaType: IdeaType?

    init(
        id: UUID = UUID(),
        originalTranscript: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        title: String? = nil,
        aiExpansions: [AIExpansion] = [],
        isFavorite: Bool = false,
        tags: [String] = [],
        status: IdeaStatus = .processing,
        ideaType: IdeaType? = nil
    ) {
        self.id = id
        self.originalTranscript = originalTranscript
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.aiExpansions = aiExpansions
        self.isFavorite = isFavorite
        self.tags = tags
        self.status = status
        self.ideaType = ideaType
    }
}

@Model
final class AIExpansion {
    var id: UUID
    var sectionTitle: String
    var content: String
    var createdAt: Date
    var isCollapsed: Bool

    init(
        id: UUID = UUID(),
        sectionTitle: String,
        content: String,
        createdAt: Date = Date(),
        isCollapsed: Bool = false
    ) {
        self.id = id
        self.sectionTitle = sectionTitle
        self.content = content
        self.createdAt = createdAt
        self.isCollapsed = isCollapsed
    }
}
