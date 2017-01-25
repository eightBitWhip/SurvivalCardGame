//
//  Array+Extensions.swift
//  HazardsCardGame
//
//  Created by Freddie on 17/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func shuffle(iterations: Int = 1) {
        
        for _ in 0...iterations {
            
            self = self.sorted(by: { _, _ in (arc4random_uniform(3) < 2)})
        }
    }
    
    /*
     fileprivate func shuffle<T>(cards: [T]) -> [T] {
     
        return cards.sorted(by: { _, _ in (arc4random_uniform(3) < 2)})
     }
     */
}
