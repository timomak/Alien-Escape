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

class AdPage: MSButtonNode {
    var watchAd: MSButtonNode!
    var mainMenuButton2: MSButtonNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        watchAd = childNode(withName: "//watchAd") as! MSButtonNode
        mainMenuButton2 = childNode(withName: "//mainMenuButton") as! MSButtonNode
    }
}
