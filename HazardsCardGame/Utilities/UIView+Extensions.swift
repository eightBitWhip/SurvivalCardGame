//
//  UIView+Extensions.swift
//  HazardsCardGame
//
//  Created by Freddie on 11/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func asImage() -> UIImage? {
        
        UIGraphicsBeginImageContext(frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
