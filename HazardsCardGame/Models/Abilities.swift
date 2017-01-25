//
//  Abilities.swift
//  HazardsCardGame
//
//  Created by Freddie on 11/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import Foundation

enum ActivationType {
    
    case instant
    case tap
}

enum AbilityType {
    
    case draw
    case swap
    case exchange
    case destroy
    case copy
    case bottomOfDeck
    case sort
    case life
    case double
    case phase
    case stop
    case highestCardEqual
}

struct Ability {
    
    var description: String
    var type: AbilityType
    var activation: ActivationType
    var value: Int? = nil
}
