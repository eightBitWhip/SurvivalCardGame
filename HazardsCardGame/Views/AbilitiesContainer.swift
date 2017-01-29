//
//  AbilitiesContainer.swift
//  HazardsCardGame
//
//  Created by Freddie on 21/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import UIKit

protocol AbilitiesContainerDelegate: class {
    
    func activateAbility(ability: Ability)
}

class AbilitiesContainer: UIView {
    
    weak var delegate: AbilitiesContainerDelegate?
    
    fileprivate let buttonWidth = 80
    fileprivate let buttonSpacing = 4
    private var buttonsCount: Int {
        return subviews.count
    }
    fileprivate var copyEnabled = false
    
    func add(ability: Ability) {
        
        let button = AbilityButton(frame: CGRect(x: (buttonsCount * (buttonWidth + buttonSpacing)), y: 0, width: buttonWidth, height: Int(frame.size.height)))
        button.delegate = self
        button.ability = ability
        addSubview(button)
    }
    
    func selectedCopy() {
        
        copyEnabled = true
    }
    
    func reset() {
        
        copyEnabled = false
        
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}

extension AbilitiesContainer: AbilityButtonDelegate {
    
    func selected(button: AbilityButton) {
        
        guard let ability = button.ability else { return }
        guard copyEnabled == false else {
            
            copyEnabled = false
            add(ability: ability)
            return
        }
        
        button.removeFromSuperview()
        delegate?.activateAbility(ability: ability)
    }
    
    func layoutButtons() {
        
        for (index, view) in subviews.enumerated() {
            
            UIView.animate(withDuration: 0.2, delay: (0.02 * Double(index)), usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [.curveLinear], animations: {
                
                let originX = (Int(index) * (self.buttonWidth + self.buttonSpacing))
                view.frame.origin.x = CGFloat(originX)
            }, completion: nil)
        }
    }
}
