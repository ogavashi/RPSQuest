//
//  ContentView.swift
//  RPSQuest
//
//  Created by Oleg Gavashi on 18.07.2023.
//

import SwiftUI

enum RPSChoice: String, CaseIterable {
    case rock = "🪨"
    case scissors = "✂️"
    case paper = "🧻"
    
    var emoji: String  {
        self.rawValue
    }
}

struct PlayerButtons: View {
    var buttons: [(String, RPSChoice)]
    var action: (String) -> Void
    
    var body: some View {
        HStack {
            ForEach(buttons.shuffled(), id: \.0) { (key, value) in
                Button {
                    action(key)
                } label: {
                    Text(value.emoji)
                        .font(.system(size: 80))
                }
                .padding()
            }
        }
    }
}

struct TaskScreen: View {
    var playerScore: Int
    var aiEmoji: String
    var shouldWin: Bool
    
    var body: some View {
        
        Text("Score: \(playerScore)")
            .padding()
            .font(.largeTitle.weight(.semibold))
        
        Text(aiEmoji)
            .padding()
            .font(.system(size: 200))
        
        HStack {
            Text("Try to \(shouldWin ? "win" : "lose")")
                .font(.largeTitle.weight(.semibold))
        }
        .padding()
    }
}

struct RoundsStats: View {
    let maxRounds: Int
    let count: Int
    var roundsLeft: Int {
        maxRounds - count
    }
    
    var body: some View {
        Text("\(roundsLeft) rounds left")
            .font(.title)
            .font(.subheadline.weight(.heavy))
    }
}

struct ContentView: View {
    @State private var shouldWin = Bool.random()
    @State private var score = 0
    @State private var aiMove = Int.random(in: 0...2)
    @State private var questionsCount = 0
    @State private var showAlert = false
    @State private var alertText = ""
    
    let options = [("rock", RPSChoice.rock), ("paper", RPSChoice.paper), ("sscissors", RPSChoice.scissors)]
    
    var aiOption: (key: String, emoji: String) {
        (options[aiMove].0, options[aiMove].1.emoji)
    }
    
    func checkWinner(playerMove: String) {
        guard let playerPoint = options.firstIndex(where: { $0.0 == playerMove }),
              let aiPoint = options.firstIndex(where: { $0.0 == aiOption.key }) else {
            
            showAlert = true
            alertText = "Something went wrong. Let's try again"
            resetGame()
            
            return
        }
        
        questionsCount += 1
        
        let winner = (playerPoint - aiPoint) % 3
        
        let tie = winner == 0
        
        if (shouldWin && winner == 1) || (!shouldWin && (winner != 1 || !tie))  {
            score += 5
        }
        else if tie {
            score = max(score - 1, 0)
        }
        else {
            score = max(score - 5, 0)
        }
        
        if questionsCount == 10 {
            showAlert = true
            alertText = "Your score is \(score). Good game!"
            resetGame()
        }
        
        generateTurn()
    }
    
    func generateTurn() {
        shouldWin.toggle()
        aiMove = Int.random(in: 0...2)
    }
    
    func resetGame() {
        score = 0
        questionsCount = 0
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                TaskScreen(playerScore: score, aiEmoji: aiOption.emoji, shouldWin: shouldWin)
                Spacer()
                PlayerButtons(buttons: options, action: checkWinner)
                Spacer()
                RoundsStats(maxRounds: 10, count: questionsCount)
            }
            .padding()
            .alert(alertText, isPresented: $showAlert) {
                Button {
                    showAlert = false
                } label: {
                    Text("Ok")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
