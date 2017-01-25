//
//  Buttons.swift
//  HazardsCardGame
//
//  Created by Freddie on 14/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import Foundation
import UIKit

class RoundedCornersButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = (isEnabled) ? 1 : 0.65
        }
    }
}

protocol AbilityButtonDelegate: class {
    
    func selected(button: AbilityButton)
}

class AbilityButton: RoundedCornersButton {
    
    weak var delegate: AbilityButtonDelegate?
    var ability: Ability? {
        didSet {
            setTitle(ability?.description, for: .normal)
        }
    }
    
    @objc private func buttonDidTap() {
        
        delegate?.selected(button: self)
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = .lightGray
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 10)
        
        addTarget(self, action: #selector(AbilityButton.buttonDidTap), for: .touchUpInside)
    }
}
