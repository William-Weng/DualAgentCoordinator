//
//  Model.swift
//  Twin
//
//  Created by William.Weng on 2026/6/25.
//

import Foundation
import FoundationModels

// MARK: - Models
struct AgentTurn: Identifiable, Hashable {
    let id = UUID()
    let agentName: String
    let message: String
}

@Generable
struct DebateSummary {
    let finalAnswer: String
    let keyPoints: [String]
    let unresolvedRisks: [String]
}
