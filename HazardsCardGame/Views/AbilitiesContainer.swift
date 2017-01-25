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
    
    private let buttonWidth = 80
    private let buttonSpacing = 4
    private var buttonsCount: Int {
        return subviews.count
    }
    
    func add(ability: Ability) {
        
        let button = AbilityButton(frame: CGRect(x: (buttonsCount * (buttonWidth + buttonSpacing)), y: 0, width: buttonWidth, height: Int(frame.size.height)))
        button.delegate = self
        button.ability = ability
        addSubview(button)
    }
    
    func reset() {
        
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}

extension AbilitiesContainer: AbilityButtonDelegate {
    
    func selected(button: AbilityButton) {
        
        guard let ability = button.ability else { return }
        button.removeFromSuperview()
        delegate?.activateAbility(ability: ability)
    }
}
