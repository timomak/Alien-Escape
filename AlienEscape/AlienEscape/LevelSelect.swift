//
//  LevelScore.swift
//  AlienEscape
//
//  Created by timofey makhlay on 7/10/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import SpriteKit

var level1: MSButtonNode!
var level2: MSButtonNode!
var level3: MSButtonNode!

class LevelSelect: SKScene {
    override func didMove(to view: SKView) {
        level1 = childNode(withName: "level1") as! MSButtonNode
        level2 = childNode(withName: "level2") as! MSButtonNode
        level3 = childNode(withName: "level3") as! MSButtonNode
        
        level1.selectedHandler = {
        guard let scene = GameScene.level(1) else {
                print("Level 1 is missing?")
                return
            }
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }

        level2.selectedHandler = {
            guard let scene = GameScene.level(2) else {
                print("Level 1 is missing?")
                return
            }
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
        level3.selectedHandler = {
            guard let scene = GameScene.level(3) else {
                print("Level 1 is missing?")
                return
            }
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
    }
    
}
