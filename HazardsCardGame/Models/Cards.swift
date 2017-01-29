//
//  Cards.swift
//  HazardsCardGame
//
//  Created by Freddie on 11/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

struct Challenge {
    
    var drawAmount: Int
    var requirement: [GamePhase: Int]
}

struct Card {
    
    var cid: String
    var pointValue: Int
    var caption: String
    var ability: Ability? = nil
    var image: UIImage
    var challenge: Challenge?
    var challengeCaption: String?
    
    func abilityText() -> String {
        
        return ability?.description ?? "..."
    }
    
    init(cid: String, pointValue: Int, caption: String, ability: Ability?, backgroundImage: UIImage) {
        
        self.cid = cid
        self.pointValue = pointValue
        self.caption = caption
        self.ability = ability
        self.image = UIImage()
        
        if let cardView = Bundle.main.loadNibNamed("StandardCard", owner: nil, options: nil)?.first as? CardView {
            
            cardView.valueLabel.text = "\(self.pointValue)"
            cardView.captionLabel.text = self.caption
            cardView.abilityLabel.text = self.abilityText()
            cardView.image.image = backgroundImage
            
            if let image = cardView.asImage() {
                
                self.image = image
            }
        }
    }
    
    init(cid: String, pointValue: Int, caption: String, ability: Ability?, backgroundImage: UIImage, challenge: Challenge, challengeCaption: String) {
        
        self.cid = cid
        self.pointValue = pointValue
        self.caption = caption
        self.ability = ability
        self.image = UIImage()
        self.challenge = challenge
        self.challengeCaption = challengeCaption
        
        if let cardView = Bundle.main.loadNibNamed("StandardCard", owner: nil, options: nil)?.first as? CardView, let challengeView = Bundle.main.loadNibNamed("HazardCard", owner: nil, options: nil)?.first as? ChallengeCardView {
            
            cardView.valueLabel.text = "\(self.pointValue)"
            cardView.captionLabel.text = self.caption
            cardView.abilityLabel.text = self.abilityText()
            cardView.image.image = backgroundImage
            
            challengeView.drawAmountLabel.text = "\(challenge.drawAmount)"
            
            if let first = challenge.requirement[.first], let second = challenge.requirement[.second], let third = challenge.requirement[.third], let challengeCaption = self.challengeCaption {
                
                challengeView.firstChallengeLabel.text = "\(first)"
                challengeView.secondChallengeLabel.text = "\(second)"
                challengeView.thirdChallengeLabel.text = "\(third)"
                challengeView.challengeCaption.text = challengeCaption
            }
            
            challengeView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            challengeView.frame = CGRect(x: 0, y: cardView.frame.size.height - challengeView.frame.size.height, width: challengeView.frame.size.width, height: challengeView.frame.size.height)
            
            cardView.addSubview(challengeView)
            
            if let image = cardView.asImage() {
                
                self.image = image
            }
        }
    }
}

extension Card: Equatable {
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.cid == rhs.cid
    }
}

struct CardDecks {
    
    static let basic: [Card] = [
        Card(cid: "A001", pointValue: 1, caption: "focused", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A002", pointValue: 1, caption: "focused", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A003", pointValue: 0, caption: "eating", ability: Ability(description: "+2 life", type: .life, activation: .tap, value: 2), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A004", pointValue: 1, caption: "focused", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A005", pointValue: -1, caption: "distracted", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A006", pointValue: -1, caption: "distracted", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A007", pointValue: 0, caption: "weak", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A008", pointValue: -1, caption: "distracted", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A009", pointValue: 0, caption: "weak", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A010", pointValue: 0, caption: "weak", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A011", pointValue: 0, caption: "weak", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A012", pointValue: 0, caption: "weak", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A013", pointValue: 0, caption: "weak", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A014", pointValue: 0, caption: "weak", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A015", pointValue: 0, caption: "weak", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A016", pointValue: -1, caption: "distracted", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A017", pointValue: -1, caption: "distracted", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "A018", pointValue: 2, caption: "genius", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage())
    ]
    
    // Challenge cards - no special rules apply
    static let challenge: [Card] = [
        Card(cid: "C001", pointValue: 0, caption: "strategy", ability: Ability(description: "2x exchange", type: .swap, activation: .tap, value: 2), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C002", pointValue: 0, caption: "strategy", ability: Ability(description: "2x exchange", type: .swap, activation: .tap, value: 2), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C003", pointValue: 0, caption: "equipment", ability: Ability(description: "+2 cards", type: .draw, activation: .tap, value: 2), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C004", pointValue: 0, caption: "equipment", ability: Ability(description: "+2 cards", type: .draw, activation: .tap, value: 2), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C005", pointValue: 4, caption: "weapon", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 5, requirement: [.first: 5, .second: 9, .third: 14]), challengeCaption: "Cannibals"),
        Card(cid: "C006", pointValue: 4, caption: "weapon", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 5, requirement: [.first: 5, .second: 9, .third: 14]), challengeCaption: "Cannibals"),
        Card(cid: "C007", pointValue: 2, caption: "weapon", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 2, requirement: [.first: 1, .second: 3, .third: 6]), challengeCaption: "Exploring the island"),
        Card(cid: "C008", pointValue: 2, caption: "weapon", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 2, requirement: [.first: 1, .second: 3, .third: 6]), challengeCaption: "Exploring the island"),
        Card(cid: "C009", pointValue: 0, caption: "food", ability: Ability(description: "+1 life", type: .life, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C010", pointValue: 0, caption: "food", ability: Ability(description: "+1 life", type: .life, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C011", pointValue: 1, caption: "food", ability: Ability(description: "+1 life", type: .life, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 2, requirement: [.first: 1, .second: 3, .third: 6]), challengeCaption: "Exploring the island"),
        Card(cid: "C012", pointValue: 1, caption: "food", ability: Ability(description: "+1 life", type: .life, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 2, requirement: [.first: 1, .second: 3, .third: 6]), challengeCaption: "Exploring the island"),
        Card(cid: "C013", pointValue: 2, caption: "food", ability: Ability(description: "+1 life", type: .life, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 3, requirement: [.first: 2, .second: 5, .third: 8]), challengeCaption: "Further exploring the island"),
        Card(cid: "C014", pointValue: 0, caption: "realization", ability: Ability(description: "1x destroy", type: .destroy, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C015", pointValue: 1, caption: "realization", ability: Ability(description: "1x destroy", type: .destroy, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 2, requirement: [.first: 1, .second: 3, .third: 6]), challengeCaption: "Exploring the island"),
        Card(cid: "C016", pointValue: 2, caption: "realization", ability: Ability(description: "1x destroy", type: .destroy, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 3, requirement: [.first: 2, .second: 5, .third: 8]), challengeCaption: "Further exploring the island"),
        Card(cid: "C017", pointValue: 3, caption: "realization", ability: Ability(description: "1x destroy", type: .destroy, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 4, requirement: [.first: 4, .second: 7, .third: 11]), challengeCaption: "Wild animals"),
        Card(cid: "C018", pointValue: 0, caption: "mimicry", ability: Ability(description: "1x copy", type: .copy, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C019", pointValue: 1, caption: "mimicry", ability: Ability(description: "1x copy", type: .copy, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 2, requirement: [.first: 1, .second: 3, .third: 6]), challengeCaption: "Exploring the island"),
        Card(cid: "C020", pointValue: 0, caption: "deception", ability: Ability(description: "1x below the pile", type: .bottomOfDeck, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck"),
        Card(cid: "C021", pointValue: 1, caption: "deception", ability: Ability(description: "1x below the pile", type: .bottomOfDeck, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 2, requirement: [.first: 1, .second: 3, .third: 6]), challengeCaption: "Exploring the island"),
        Card(cid: "C022", pointValue: 2, caption: "experience", ability: Ability(description: "+1 card", type: .draw, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 3, requirement: [.first: 2, .second: 5, .third: 8]), challengeCaption: "Further exploring the island"),
        Card(cid: "C023", pointValue: 3, caption: "experience", ability: Ability(description: "+1 card", type: .draw, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 4, requirement: [.first: 4, .second: 7, .third: 11]), challengeCaption: "Wild animals"),
        Card(cid: "C024", pointValue: 2, caption: "vision", ability: Ability(description: "sort 3 cards", type: .sort, activation: .tap, value: 3), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 3, requirement: [.first: 2, .second: 5, .third: 8]), challengeCaption: "Further exploring the island"),
        Card(cid: "C025", pointValue: 3, caption: "vision", ability: Ability(description: "sort 3 cards", type: .sort, activation: .tap, value: 3), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 4, requirement: [.first: 4, .second: 7, .third: 11]), challengeCaption: "Wild animals"),
        Card(cid: "C026", pointValue: 1, caption: "repeat", ability: Ability(description: "1x double", type: .double, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 2, requirement: [.first: 1, .second: 3, .third: 6]), challengeCaption: "Exploring the island"),
        Card(cid: "C027", pointValue: 2, caption: "repeat", ability: Ability(description: "1x double", type: .double, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 3, requirement: [.first: 2, .second: 5, .third: 8]), challengeCaption: "Further exploring the island"),
        Card(cid: "C028", pointValue: 3, caption: "strategy", ability: Ability(description: "1x exchange", type: .exchange, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 4, requirement: [.first: 4, .second: 7, .third: 11]), challengeCaption: "Wild animals"),
        Card(cid: "C029", pointValue: 2, caption: "strategy", ability: Ability(description: "1x exchange", type: .exchange, activation: .tap, value: 1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 3, requirement: [.first: 2, .second: 5, .third: 8]), challengeCaption: "Further exploring the island"),
        Card(cid: "C030", pointValue: 0, caption: "books", ability: Ability(description: "phase -1", type: .phase, activation: .tap, value: -1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage(), challenge: Challenge(drawAmount: 1, requirement: [.first: 0, .second: 1, .third: 3]), challengeCaption: "With the raft to the wreck")
    ]
    
    // Ages cards - in easy mode: B008 should be removed; B0010 + B0011 should remain at the bottom
    static let age: [Card] = [
        Card(cid: "B001", pointValue: -2, caption: "stupid", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B002", pointValue: 0, caption: "very tired", ability: Ability(description: "stop", type: .stop, activation: .instant, value: nil), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B003", pointValue: 0, caption: "scared", ability: Ability(description: "highest card = 0", type: .highestCardEqual, activation: .instant, value: 0), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B004", pointValue: -2, caption: "stupid", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B005", pointValue: 0, caption: "scared", ability: Ability(description: "highest card = 0", type: .highestCardEqual, activation: .instant, value: 0), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B006", pointValue: -1, caption: "distracted", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B007", pointValue: 0, caption: "hungry", ability: Ability(description: "-1 life", type: .life, activation: .instant, value: -1), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B008", pointValue: -3, caption: "very stupid", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B009", pointValue: 0, caption: "very hungry", ability: Ability(description: "-2 life", type: .life, activation: .instant, value: -2), backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B0010", pointValue: -4, caption: "moronic", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage()),
        Card(cid: "B0011", pointValue: -5, caption: "suicidal", ability: nil, backgroundImage: UIImage(named: "playingCard.jpg") ?? UIImage())
    ]
}
