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

enum AbilityType: String {
    
    case draw = "Draw"
    case swap = "Swap"
    case exchange = "Exchange"
    case destroy = "Destroy"
    case copy = "Copy"
    case bottomOfDeck = "Bottom of the draw deck"
    case sort = "sort"
    case life = "life"
    case double = "Double"
    case phase = "phase"
    case stop = "stop"
    case highestCardEqual = "highest"
}

struct Ability {
    
    var description: String
    var type: AbilityType
    var activation: ActivationType
    var value: Int? = nil
}
