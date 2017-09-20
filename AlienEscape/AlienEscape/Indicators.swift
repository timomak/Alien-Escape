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

class guiCode: SKSpriteNode {
    var starOne_guiCode :SKSpriteNode!
    var starTwo_guiCode :SKSpriteNode!
    var starThree_guiCode :SKSpriteNode!
    var winMenu_guiCode: SKSpriteNode!
    var nextLevelButton_guiCode: MSButtonNode!
    var pauseMenu_guiCode: SKSpriteNode!
    var resetButton_guiCode: MSButtonNode!
    var resumeButton_guiCode: MSButtonNode!
    var levelSelectButton_guiCode: MSButtonNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        pauseMenu_guiCode = childNode(withName: "//pauseMenu") as! SKSpriteNode
        resumeButton_guiCode = childNode(withName: "//resumeButton") as! MSButtonNode
        resetButton_guiCode = childNode(withName: "//resetButton") as! MSButtonNode
        
        starOne_guiCode = childNode(withName: "//starOne") as! SKSpriteNode
        starTwo_guiCode = childNode(withName: "//starTwo") as! SKSpriteNode
        starThree_guiCode = childNode(withName: "//starThree") as! SKSpriteNode
        
        winMenu_guiCode = childNode(withName: "//winMenu") as! SKSpriteNode
        nextLevelButton_guiCode = childNode(withName: "//nextLevelButton") as! MSButtonNode
        levelSelectButton_guiCode = childNode(withName: "//levelSelectButton") as! MSButtonNode
    }
}

