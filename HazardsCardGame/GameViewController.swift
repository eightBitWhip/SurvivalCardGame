//
//  GameViewController.swift
//  HazardsCardGame
//
//  Created by Freddie on 10/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var gameView: SCNView!
    @IBOutlet weak var moraleContainer: EnergyView!
    @IBOutlet weak var drawButton: RoundedCornersButton! {
        didSet {
            drawButton.isEnabled = true
        }
    }
    @IBOutlet weak var destroyButton: RoundedCornersButton! {
        didSet {
            destroyButton.isEnabled = false
        }
    }
    @IBOutlet weak var takeButton: RoundedCornersButton! {
        didSet {
            takeButton.isEnabled = false
        }
    }
    @IBOutlet weak var challengePointsLabel: UILabel!
    @IBOutlet weak var abilitiesContainer: AbilitiesContainer! {
        didSet {
            abilitiesContainer.delegate = self
        }
    }
    
    fileprivate var game: Game?
    fileprivate let inPlayZStart: Float = -0.5
    fileprivate let inPlayYStart: Float = 0.5
    
    fileprivate weak var gameOverLabel: UILabel?
    fileprivate var phaseLight: SCNNode?
    fileprivate var activeAbility: Ability?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetGame()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gameView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startGame()
    }
    
    fileprivate func resetGame() {
        
        game = Game(drawDeck: CardDecks.basic, challengeDeck: CardDecks.challenge, ageDeck: CardDecks.age, startingMorale: 20)
        game?.delegate = self
        
        moraleChanged()
        
        let scene = SCNScene(named: "CardGameplay.scn")!
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        gameView.scene = scene
        gameView.showsStatistics = false
        
        phaseLight = gameView.scene?.rootNode.childNode(withName: "phaseSpot", recursively: true)
    }
    
    fileprivate func startGame() {
        
        game?.start()
    }
    
    fileprivate func move(card: SCNNode, toZPosition position: Float, afterDelay delay: TimeInterval) {
        
        let animation = CABasicAnimation(keyPath: "position.z")
        animation.fromValue = card.position.z
        animation.toValue = position
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        card.addAnimation(animation, forKey: "move")
        
        card.position.z = position
    }
    
    fileprivate func move(card: SCNNode, toZPosition position: Float, xPosition: Float, completion: @escaping () -> Void) {
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        SCNTransaction.completionBlock = completion
        card.position.z = position
        card.position.x = xPosition
        SCNTransaction.commit()
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        let p = gestureRecognize.location(in: gameView)
        let hitResults = gameView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            
            let result: AnyObject = hitResults[0]
            if let nodeName = result.node.name {
                
                game?.selectedNode(withName: nodeName, ability: activeAbility)
            }
        }
    }
    
    private func selected(card: Card, withNode node: SCNNode) {
        
        move(card: node, toZPosition: 1.0, afterDelay: 0)
    }
    
    fileprivate func carNode(forCard card: Card) -> SCNNode {
        
        let cardNode = SCNNode(geometry: SCNBox(width: 0.25, height: 0.02, length: 0.35, chamferRadius: 2))
        cardNode.name = card.cid
        cardNode.position = SCNVector3(x: 0, y: 0.5, z: 0)
        cardNode.geometry?.materials.first?.diffuse.contents = card.image
        
        return cardNode
    }
    
    @IBAction func shuffleCardsButtonDidTap(_ sender: Any) {
        
        game?.completedChallenge()
    }
    
    @IBAction func drawButtonDidTap(_ sender: Any) {
        
        game?.draw(cost: 1)
    }
    
    @IBAction func binButtonDidTap(_ sender: Any) {
        
        game?.binChallenge()
        destroyButton.isEnabled = false
    }
    
    @IBAction func homeButtonDidTap(_ sender: Any) {
        
        resetGame()
        startGame()
    }
    
    override var shouldAutorotate: Bool {
        
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return .portrait
    }
}

extension GameViewController: GameDelegate {
    
    func present(card: Card) {
        
        if let ability = card.ability, ability.activation == .tap {
            
            abilitiesContainer.add(ability: ability)
        }
        
        let cardCount = game?.inPlay.count ?? 0
        
        let node = carNode(forCard: card)
        node.position.x = -1.0
        node.position.z = (inPlayZStart + (0.1 * Float(cardCount)))
        node.position.y = (inPlayYStart + (0.01 * Float(cardCount)))
        gameView.scene?.rootNode.addChildNode(node)
        
        move(card: node, toZPosition: node.position.z, xPosition: -0.2) {}
        
        destroyButton.isEnabled = true
        
        guard let points = game?.inPlayPoints, let challengePoints = game?.challengePoints else { return }
        challengePointsLabel.text = "\(points)/\(challengePoints)"
        takeButton.isEnabled = (points >= challengePoints)
    }
    
    func selected(challengeCard: Card, withCompletion completion: @escaping () -> Void) {
        
        guard let node = gameView.scene?.rootNode.childNode(withName: challengeCard.cid, recursively: true) else { return }
        move(card: node, toZPosition: -0.1, xPosition: 0.2, completion: {
        
            self.drawButton.isEnabled = true
            completion()
        })
    }
    
    func layoutChallengeChoices(cards: [Card], completion: @escaping () -> Void) {
        
        takeButton.isEnabled = false
        challengePointsLabel.text = "0/0"
        
        guard let card = cards.first else { return }
        let cardOneNode = self.carNode(forCard: card)
        cardOneNode.position.x = -0.2
        cardOneNode.eulerAngles.y = Float(M_PI)
        gameView.scene?.rootNode.addChildNode(cardOneNode)
        
        move(card: cardOneNode, toZPosition: 0, xPosition: cardOneNode.position.x, completion: {
        
            completion()
        })
        
        if cards.count == 2, let cardTwo = cards.last {
            
            let cardTwoNode = self.carNode(forCard: cardTwo)
            cardTwoNode.position.x = 0.2
            cardTwoNode.eulerAngles.y = Float(M_PI)
            gameView.scene?.rootNode.addChildNode(cardTwoNode)
            move(card: cardTwoNode, toZPosition: 0, xPosition: cardTwoNode.position.x, completion: {})
        }
    }
    
    func beginChallenge() {
        
    }
    
    func layoutInPlayCard(card: Card) {
        
    }
    
    func removeCard(withName name: String) {
        
        if let node = gameView.scene?.rootNode.childNode(withName: name, recursively: true) {
            
            move(card: node, toZPosition: 1, xPosition: node.position.x, completion: {
            
                node.removeFromParentNode()
            })
        }
    }
    
    func moraleChanged() {
        
        moraleContainer.energy = game?.morale ?? 0
    }
    
    func phaseChanged(phase: GamePhase) {
        
        switch phase {
            
        case .first:
            phaseLight?.light?.color = UIColor.green
            break
            
        case .second:
            phaseLight?.light?.color = UIColor.yellow
            break
            
        case .third:
            phaseLight?.light?.color = UIColor.red
            break
        }
    }
    
    func stateChanged() {
        
        abilitiesContainer.reset()
    }
    
    func gameOver() {
        
        gameOverLabel = UILabel(frame: CGRect(x: 0, y: moraleContainer.superview?.frame.size.height ?? 0, width: view.frame.size.width, height: view.frame.size.height - (moraleContainer.superview?.frame.size.height ?? 0)))
        gameOverLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        gameOverLabel?.textColor = .white
        gameOverLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        gameOverLabel?.text = "GAME OVER"
        
        guard let label = gameOverLabel else { return }
        view.addSubview(label)
    }
}

extension GameViewController: AbilitiesContainerDelegate {
    
    func activateAbility(ability: Ability) {
        
        switch ability.type {
            
        case .bottomOfDeck:
            break
        case .copy:
            break
        case .destroy:
            break
        case .draw:
            game?.draw(cost: 0)
            guard ability.value == 2 else { return }
            game?.draw(cost: 0)
            break
        case .life:
            game?.morale += ability.value ?? 0
            break
        default:
            break
        }
    }
}
