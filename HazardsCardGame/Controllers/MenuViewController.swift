//
//  MenuViewController.swift
//  HazardsCardGame
//
//  Created by Freddie on 01/02/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import UIKit
import SceneKit

class MenuViewController: UIViewController {

    @IBOutlet weak var gameView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene(named: "Menu.scn")!
        
        gameView.scene = scene
        gameView.showsStatistics = false        
    }
}
