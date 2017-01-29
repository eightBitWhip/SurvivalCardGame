//
//  Misc+Extensions.swift
//  HazardsCardGame
//
//  Created by Freddie on 29/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import Foundation

extension Int {

    mutating func clamp(min: Int, max: Int) {
        
        guard self < min, self > max else { return }
        self = (self < min) ? min : max
    }
}
