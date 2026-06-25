//
//  ViewController.swift
//  DualAgentCoordinator
//
//  Created by William.Weng on 2026/6/23.
//

import UIKit
import WWHUD

final class ViewController: UIViewController {

    @IBOutlet weak var answerTextView: UITextView!
    
    private let maxTurns = 3
    private let gif: URL = Bundle.main.bundleURL.appendingPathComponent("Loading.gif")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await demoDualAgent() }
    }
    
    @MainActor
    func makeCoordinator() -> DualAgentCoordinator {
        
        let agentA = DebateAgent(
            name: "Planner",
            instructions: """
            你是規劃型 agent。
            擅長先提出結構清楚、可落地的方案。
            回答要短、務實、有步驟。
            """
        )
        
        let agentB = DebateAgent(
            name: "Critic",
            instructions: """
            你是審查型 agent。
            擅長找風險、抓漏洞、補邊界條件。
            不要做人身化回應，只談方案品質。
            """
        )
        
        return DualAgentCoordinator(agentA: agentA, agentB: agentB)
    }
    
    @MainActor
    func demoDualAgent() async {
        
        WWHUD.shared.display(effect: .gif(url: gif, options: nil), height: 256)
        defer { WWHUD.shared.dismiss() }

        let coordinator = makeCoordinator()
        var contents: [String] = []
        
        do {
            let result = try await coordinator.runDebate(
                topic: "幫我設計一個 SwiftUI 單字卡 App 的複習流程",
                maxTurns: maxTurns
            )
            
            for turn in result.transcript {
                
                let message = "[\(turn.agentName)] \(turn.message)\n"
                contents.append(message)
                
                print(message)
            }

            let summary = """
            
            \(contents.joined())
            
            Final Answer:
            \(result.summary.finalAnswer)
            
            Key Points:
            \(result.summary.keyPoints)
            
            Risks:
            \(result.summary.unresolvedRisks)
            """
            
            answerTextView.text = summary
            
        } catch {
            
            answerTextView.text = """
            Dual agent failed:
            \(error.localizedDescription)
            """
        }
    }
}


