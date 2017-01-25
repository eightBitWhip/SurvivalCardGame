//
//  Game.swift
//  HazardsCardGame
//
//  Created by Freddie on 14/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import UIKit

enum GameState {
    
    case start
    case pickChallenge
    case playChallenge
    case playFinal
}

enum GamePhase: Int {
    
    case first = 1
    case second = 2
    case third = 3
}

protocol GameDelegate: class {
    
    func present(card: Card)
    func selected(challengeCard: Card, withCompletion completion: @escaping () -> Void)
    func layoutChallengeChoices(cards: [Card], completion: @escaping () -> Void)
    func beginChallenge()
    func layoutInPlayCard(card: Card)
    func removeCard(withName name: String)
    func moraleChanged()
    func phaseChanged(phase: GamePhase)
    func stateChanged()
    func gameOver()
}

class Game: NSObject {
    
    var drawDeck: [Card] = []
    var usedDeck: [Card] = []
    var challengeDeck: [Card] = []
    var challengeChoice: [Card] = []
    var challengeDiscard: [Card] = []
    var ageDeck: [Card] = []
    var inPlay: [Card] = []
    
    var activeChallenge: Card?
    
    var state: GameState = .start {
        didSet {
            
            delegate?.stateChanged()
            
            switch state {
                
            case .start:
                break
                
            case .pickChallenge:
                break
                
            case .playChallenge:
                challengeDrawCount = 0
                delegate?.beginChallenge()
                break
                
            case .playFinal:
                break
            }
        }
    }
    var phase: GamePhase = .first {
        didSet {
            
            delegate?.phaseChanged(phase: phase)
        }
    }
    
    var morale: Int = 20 {
        didSet {
            
            guard morale >= 0 else {
                delegate?.gameOver()
                return
            }
            
            if morale > moraleLimit {
                morale = moraleLimit
            }
            delegate?.moraleChanged()
        }
    }
    var inPlayPoints: Int {
        
        var points = 0
        _ = inPlay.map({ points += $0.pointValue })
        return points
    }
    var challengePoints: Int? {
        
        return activeChallenge?.challenge?.requirement[phase]
    }
    var challengeDrawCount: Int = 0
    
    var delegate: GameDelegate?
    
    private let moraleLimit = 22
    
    init(drawDeck: [Card], challengeDeck: [Card], ageDeck: [Card], startingMorale: Int) {
        super.init()
        
        self.drawDeck = drawDeck
        self.challengeDeck = challengeDeck
        self.ageDeck = ageDeck
        self.morale = startingMorale
    }
    
    func start() {
        
        drawDeck.shuffle(iterations: 3)
        ageDeck.shuffle(iterations: 3)
        challengeDeck.shuffle(iterations: 3)
        
        dealChallenges()
    }
    
    func draw(cost: Int) {
        
        guard state == .playChallenge, morale > 0 else { return }
        
        guard drawDeck.count > 0 else { return }
        let card = drawDeck.removeLast()
        inPlay.append(card)
        
        challengeDrawCount += cost
        
        if let drawAmount = activeChallenge?.challenge?.drawAmount, challengeDrawCount > drawAmount {
            
            morale -= 1
        }
        
        if drawDeck.count == 0 {
            
            replenishDrawDeck()
        }
        
        delegate?.present(card: card)
        
        logStatus()
    }
    
    func completedChallenge() {
        
        if let activeChallenge = activeChallenge {
            
            delegate?.removeCard(withName: activeChallenge.cid)
            usedDeck.append(activeChallenge)
            self.activeChallenge = nil
        }
        
        for card in inPlay {
            
            delegate?.removeCard(withName: card.cid)
            usedDeck.append(card)
        }
        
        inPlay.removeAll()
        dealChallenges()
    }
    
    func binChallenge() {
        
        if let challengePoints = challengePoints, inPlayPoints < challengePoints {
            
            morale += (inPlayPoints - challengePoints)
        }
        
        if let activeChallenge = activeChallenge {
            
            delegate?.removeCard(withName: activeChallenge.cid)
            self.activeChallenge = nil
        }
        
        for card in inPlay {
            
            delegate?.removeCard(withName: card.cid)
        }
        
        inPlay.removeAll()
        dealChallenges()
    }
    
    private func replenishDrawDeck() {
        
        if let card = ageDeck.last {
            
            ageDeck.removeLast()
            drawDeck.append(card)
        }
        
        drawDeck.append(contentsOf: usedDeck)
        usedDeck.removeAll()
        drawDeck.shuffle(iterations: 3)
    }
    
    private func dealChallenges() {
        
        if challengeDeck.count < 2 {
            
            if phase == .third {
                
                // play final
                return
            }
            
            phase = GamePhase(rawValue: (phase.rawValue + 1))!
            
            challengeDeck.append(contentsOf: challengeDiscard)
            challengeDiscard.removeAll()
            challengeDeck.shuffle(iterations: 3)
        }
        
        if challengeDeck.count >= 2 {
            
            let range = (challengeDeck.endIndex - 2)..<challengeDeck.endIndex
            
            challengeChoice = Array(challengeDeck[range])
            challengeDeck.removeSubrange(range)
            
            delegate?.layoutChallengeChoices(cards: challengeChoice, completion: {
            
                self.state = .pickChallenge
            })
        }
    }
    
    private func selectedChallengeCard(withName name: String) {
        
        if let selectedNode = challengeChoice.filter({ $0.cid == name }).first {
            
            activeChallenge = selectedNode
            
            challengeDiscard.append(contentsOf: challengeChoice.filter({ $0.cid != name }))
            delegate?.selected(challengeCard: selectedNode, withCompletion: {
                
                self.state = .playChallenge
            })
            
            guard let rejectedCard = challengeDiscard.last else { return }
            delegate?.removeCard(withName: rejectedCard.cid)
        }
    }
    
    func selectedNode(withName name: String, ability: Ability?) {
        
        logStatus()
        
        switch state {
        
        case .start:
            break
            
        case .pickChallenge:
            selectedChallengeCard(withName: name)
            break
            
        case .playChallenge:
            break
            
        case .playFinal:
            break
        }
    }
    
    private func logStatus() {
        
        print("################\n# dd \(drawDeck.count) | dx \(usedDeck.count) #\n# cd \(challengeDeck.count) | cx \(challengeDiscard.count) #\n# ad \(ageDeck.count)         #\n################")
    }
}
