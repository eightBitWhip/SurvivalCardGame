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
    func action(card: String)
    func resetAction(card: String, ability: Ability?)
    func selected(challengeCard: Card, withCompletion completion: @escaping () -> Void)
    func layoutChallengeChoices(cards: [Card], completion: @escaping () -> Void)
    func beginChallenge()
    func layoutInPlayCard(card: Card)
    func removeCard(withName name: String)
    func moraleChanged()
    func phaseChanged(phase: GamePhase)
    func stateChanged()
    func gameOver()
    func updateChallengeStatus()
    func present(controller: UIViewController)
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
                challengeBonusPoints = 0
                phaseModifier = 0
                highestCardModifier = nil
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
        
        var points = challengeBonusPoints
        inPlay = inPlay.sorted(by: { $0.pointValue > $1.pointValue })
        _ = inPlay.map({ points += $0.pointValue })
        
        guard let highestCardModifier = highestCardModifier else { return points }
        points -= (inPlay.first?.pointValue ?? 0)
        points += highestCardModifier
        return points
    }
    var challengePoints: Int? {
        
        var modifiedPhaseValue = (phase.rawValue + phaseModifier)
        modifiedPhaseValue.clamp(min: 1, max: 3)
        let currentPhase = GamePhase(rawValue: modifiedPhaseValue)
        return activeChallenge?.challenge?.requirement[currentPhase ?? .first]
    }
    var challengeDrawCount: Int = 0
    private var challengeBonusPoints: Int = 0
    var phaseModifier: Int = 0
    private var highestCardModifier: Int?
    
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
    
    private func activate(instantAbility ability: Ability) {
    
        switch ability.type {
            
        case .highestCardEqual:
            highestCardModifier = ability.value
            break
            
        case .stop:
            challengeDrawCount = activeChallenge?.challenge?.drawAmount ?? challengeDrawCount
            break
            
        case .life:
            morale += ability.value ?? 0
            break
            
        default:
            break
        }
    }
    
    func draw(cost: Int) {
        
        guard state == .playChallenge, (morale - cost) >= 0 else { return }
        
        guard drawDeck.count > 0 else { return }
        let card = drawDeck.removeLast()
        inPlay.append(card)
        
        challengeDrawCount += cost
        
        if cost > 0, let drawAmount = activeChallenge?.challenge?.drawAmount, challengeDrawCount > drawAmount {
            
            morale -= 1
        }
        
        if drawDeck.count == 0 {
            
            replenishDrawDeck()
        }
        
        delegate?.present(card: card)
        
        logStatus()
        
        guard let ability = card.ability, ability.activation == .instant else { return }
        activate(instantAbility: ability)
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
    
    private func selectedCard(withName name: String, ability: Ability?) {
        
        if let selectedNode = inPlay.filter({ $0.cid == name }).first, let ability = ability {
            
            delegate?.action(card: selectedNode.cid)
            
            let alertController = UIAlertController(title: "Confirm action", message: "Are you sure you want to '\(ability.type.rawValue)' this card?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                
                self.delegate?.resetAction(card: name, ability: ability)
            })
            alertController.addAction(UIAlertAction(title: "Yes", style: .default) { action in
                
                switch ability.type {
                    
                case .destroy:
                    guard let index = self.inPlay.index(of: selectedNode) else { return }
                    self.inPlay.remove(at: index)
                    self.delegate?.removeCard(withName: selectedNode.cid)
                    break
                    
                case .double:
                    self.challengeBonusPoints += selectedNode.pointValue
                    self.delegate?.resetAction(card: selectedNode.cid, ability: nil)
                    break
                    
                case .exchange, .swap:
                    guard let index = self.inPlay.index(of: selectedNode) else { return }
                    let card = self.inPlay.remove(at: index)
                    self.usedDeck.append(card)
                    self.delegate?.removeCard(withName: selectedNode.cid)
                    self.draw(cost: 0)
                    break
                    
                case .bottomOfDeck:
                    guard let index = self.inPlay.index(of: selectedNode) else { return }
                    let card = self.inPlay.remove(at: index)
                    self.drawDeck.insert(card, at: 0)
                    self.delegate?.removeCard(withName: selectedNode.cid)
                    break
                    
                default:
                    break
                }
                
                self.delegate?.updateChallengeStatus()
            })
            
            delegate?.present(controller: alertController)
            
//            switch ability.type {
//                
//            case .destroy:
//                guard let index = inPlay.index(of: selectedNode) else { return }
//                inPlay.remove(at: index)
//                delegate?.removeCard(withName: selectedNode.cid)
//                break
//                
//            case .double:
//                challengeBonusPoints += selectedNode.pointValue
//                break
//                
//            case .exchange, .swap:
//                guard let index = inPlay.index(of: selectedNode) else { return }
//                let card = inPlay.remove(at: index)
//                usedDeck.append(card)
//                delegate?.removeCard(withName: selectedNode.cid)
//                draw(cost: 0)
//                break
//                
//            case .bottomOfDeck:
//                guard let index = inPlay.index(of: selectedNode) else { return }
//                let card = inPlay.remove(at: index)
//                drawDeck.insert(card, at: 0)
//                delegate?.removeCard(withName: selectedNode.cid)
//                break
//                
//            default:
//                break
//            }
        }
        
        //delegate?.updateChallengeStatus()
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
            selectedCard(withName: name, ability: ability)
            break
            
        case .playFinal:
            break
        }
    }
    
    private func logStatus() {
        
        print("################\n# dd \(drawDeck.count) | dx \(usedDeck.count) #\n# cd \(challengeDeck.count) | cx \(challengeDiscard.count) #\n# ad \(ageDeck.count)         #\n################")
    }
}
