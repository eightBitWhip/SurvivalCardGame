//
//  Card.swift
//  HazardsCardGame
//
//  Created by Freddie on 11/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import UIKit

class CardView: UIView {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var abilityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .clear
    }
}
