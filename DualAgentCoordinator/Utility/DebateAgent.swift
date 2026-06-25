//
//  DebateAgent.swift
//  Twin
//
//  Created by iOS on 2026/6/25.
//

import Foundation
import FoundationModels

// MARK: - Agent
@MainActor
final class DebateAgent {
    
    let name: String
    private let session: LanguageModelSession
    
    init(name: String, instructions: String) {
        self.name = name
        self.session = LanguageModelSession(instructions: instructions)
    }
    
    func reply(to prompt: String) async throws -> String {
        let response = try await session.respond(to: prompt)
        return response.content
    }
}
