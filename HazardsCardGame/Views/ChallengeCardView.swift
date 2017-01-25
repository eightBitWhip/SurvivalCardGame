//
//  ChallengeCardView.swift
//  HazardsCardGame
//
//  Created by Freddie on 15/01/2017.
//  Copyright © 2017 Freddie. All rights reserved.
//

import UIKit

class ChallengeCardView: UIView {

    @IBOutlet weak var challengeCaption: UILabel!
    @IBOutlet weak var drawAmountLabel: UILabel!
    @IBOutlet weak var firstChallengeLabel: UILabel! {
        didSet {
            firstChallengeLabel.superview?.clipsToBounds = true
            firstChallengeLabel.superview?.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var secondChallengeLabel: UILabel! {
        didSet {
            secondChallengeLabel.superview?.clipsToBounds = true
            secondChallengeLabel.superview?.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var thirdChallengeLabel: UILabel! {
        didSet {
            thirdChallengeLabel.superview?.clipsToBounds = true
            thirdChallengeLabel.superview?.layer.cornerRadius = 6
        }
    }
}
