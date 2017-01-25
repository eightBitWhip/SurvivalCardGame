//
//  EnergyView.swift
//  HazardsCardGame
//
//  Created by Freddie on 14/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import UIKit

class EnergyView: UIView {

    var energy: Int = 20 {
        
        didSet {
            
            energySize = Int(frame.size.height)
            updateEnergyStack()
        }
    }
    
    private var energyOffset = 12
    private var energySize = 24 {
        didSet {
            energyOffset = energySize/2
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateEnergyStack()
    }
    
    private func updateEnergyStack() {
        
        if subviews.count < energy {
            
            push(amount: (energy - subviews.count))
        } else {
            
            pop(amount: (subviews.count - energy))
        }
    }
    
    private func mutate(iterations: Int, function: (() -> Void)) {
        
        for _ in 0..<iterations {
            
            function()
        }
    }
    
    private func push(amount: Int) {
        
        mutate(iterations: amount, function: {
        
            let view = UIImageView(frame: CGRect(x: (subviews.count * energyOffset), y: 0, width: energySize, height: energySize))
            view.image = UIImage(named: "heart")
            addSubview(view)
        })
    }
    
    private func pop(amount: Int) {
        
        mutate(iterations: amount, function: {
        
            guard let view = subviews.last else { return }
            view.removeFromSuperview()
        })
    }
}
