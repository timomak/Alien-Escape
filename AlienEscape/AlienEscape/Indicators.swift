//
//  Indicators.swift
//  AlienEscape
//
//  Created by timofey makhlay on 8/2/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import SpriteKit

class Indicators: SKSpriteNode {
    var labelIndicator: SKSpriteNode!
    var powerIndicator: SKLabelNode!
    var angleIndicator: SKLabelNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        angleIndicator = childNode(withName: "//angleLabel") as! SKLabelNode
        powerIndicator = childNode(withName: "//powerLabel") as! SKLabelNode
    }
}
