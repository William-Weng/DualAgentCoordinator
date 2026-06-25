//
//  DualAgentCoordinator.swift
//  Twin
//
//  Created by iOS on 2026/6/25.
//

import Foundation
import FoundationModels

// MARK: - Coordinator
@MainActor
final class DualAgentCoordinator {
    
    private let agentA: DebateAgent
    private let agentB: DebateAgent
    
    init(agentA: DebateAgent, agentB: DebateAgent) {
        self.agentA = agentA
        self.agentB = agentB
    }
    
    func runDebate(
        topic: String,
        maxTurns: Int = 4
    ) async throws -> (transcript: [AgentTurn], summary: DebateSummary) {
        
        var transcript: [AgentTurn] = []
        
        var currentPrompt = """
        題目：\(topic)
        
        請先提出你的第一版看法。
        內容請簡潔、具體、可執行。
        """
        
        for turn in 0..<maxTurns {
            
            if turn % 2 == 0 {
                let reply = try await agentA.reply(to: currentPrompt)
                transcript.append(.init(agentName: agentA.name, message: reply))
                
                currentPrompt = """
                以下是 \(agentA.name) 的觀點：
                \(reply)
                
                請你扮演 \(agentB.name)，做這三件事：
                1. 指出盲點
                2. 補充更好的做法
                3. 不要重複原文
                """
            } else {
                let reply = try await agentB.reply(to: currentPrompt)
                transcript.append(.init(agentName: agentB.name, message: reply))
                
                currentPrompt = """
                以下是 \(agentB.name) 對你上一輪的評論：
                \(reply)
                
                請你扮演 \(agentA.name)，
                只針對被質疑的點提出修正版方案，
                避免寒暄，避免重複前文。
                """
            }
        }
        
        let summarySession = LanguageModelSession(
            instructions: """
            你是一位中立的總結者。
            你要根據兩位 agent 的逐輪對話，
            整理出最終答案、重點摘要、以及尚未解決的風險。
            """
        )
        
        let transcriptText = transcript
            .map { "[\($0.agentName)] \($0.message)" }
            .joined(separator: "\n\n")
        
        let summary = try await summarySession.respond(
            to: """
            主題：\(topic)
            
            以下是對話紀錄：
            \(transcriptText)
            """,
            generating: DebateSummary.self
        )
        
        return (transcript, summary.content)
    }
}
