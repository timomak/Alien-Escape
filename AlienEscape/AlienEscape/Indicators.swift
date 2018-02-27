//
//  Indicators.swift
//  AlienEscape
//
//  Created by timofey makhlay on 8/2/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import SpriteKit

class Indicators: SKSpriteNode {
//    var labelIndicator: SKSpriteNode!
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
    var gameOverSign_guiCode: SKSpriteNode!
    
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
        gameOverSign_guiCode = childNode(withName: "//gameOverSign") as! SKSpriteNode
    }
}
class CircularProgressNode : SKShapeNode
{
    private var radius: CGFloat!
    private var startAngle: CGFloat!
    
    init(radius: CGFloat, color: SKColor, width: CGFloat, startAngle: CGFloat = CGFloat(Double.pi / 2)) {
        super.init()
        
        self.radius = radius
        self.strokeColor = color
        self.lineWidth = width
        self.startAngle = startAngle
        
        self.updateProgress(percentageCompleted: 0.0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress(percentageCompleted: CGFloat) {
        let progress = percentageCompleted <= 0.0 ? 1.0 : (percentageCompleted >= 1.0 ? 0.0 : 1.0 - percentageCompleted)
        let endAngle = self.startAngle + progress * CGFloat(2.0 * .pi)

        self.path = UIBezierPath(arcCenter: position, radius: self.radius, startAngle: self.startAngle, endAngle: endAngle, clockwise: true).cgPath
    }
}

