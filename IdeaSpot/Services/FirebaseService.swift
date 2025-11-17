//
//  FirebaseService.swift
//  IdeaSpot
//
//  Created by Kelly Stradley on 11/14/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFunctions

@Observable
class FirebaseService {
    static let shared = FirebaseService()

    private let functions = Functions.functions()
    var currentUser: User?

    private init() {
        // Firebase will be configured in AppDelegate/App
    }

    // MARK: - Authentication

    func signInWithApple() async throws {
        // Apple Sign-In implementation will go here
        // Using Firebase Auth with Apple provider
    }

    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
    }

    // MARK: - AI Expansion

    func expandIdea(transcript: String) async throws -> AIExpansionResponse {
        let callable = functions.httpsCallable("expandIdea")

        let parameters: [String: Any] = [
            "transcript": transcript
        ]

        let result = try await callable.call(parameters)

        guard let data = result.data as? [String: Any],
              let title = data["title"] as? String,
              let expansions = data["expansions"] as? [[String: Any]] else {
            throw FirebaseError.invalidResponse
        }

        let aiExpansions = expansions.compactMap { dict -> AIExpansionData? in
            guard let sectionTitle = dict["sectionTitle"] as? String,
                  let content = dict["content"] as? String else {
                return nil
            }
            return AIExpansionData(sectionTitle: sectionTitle, content: content)
        }

        return AIExpansionResponse(title: title, expansions: aiExpansions)
    }
}

// MARK: - Response Models

struct AIExpansionResponse {
    let title: String
    let expansions: [AIExpansionData]
}

struct AIExpansionData {
    let sectionTitle: String
    let content: String
}

enum FirebaseError: Error {
    case notAuthenticated
    case invalidResponse
    case functionError(String)
}
