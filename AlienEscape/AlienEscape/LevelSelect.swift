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

var mainManu: MSButtonNode!
var star_1: SKSpriteNode!


class LevelSelect: SKScene {
    override func didMove(to view: SKView) {
        level1 = childNode(withName: "level1") as! MSButtonNode
        level2 = childNode(withName: "level2") as! MSButtonNode
        level3 = childNode(withName: "level3") as! MSButtonNode
        
        if UserDefaults.standard.integer(forKey: "1") > 1 {
            
        }
        
        mainManu = childNode(withName: "mainMenuButton") as! MSButtonNode
        
        mainManu.selectedHandler = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            /* 2) Load Game scene */
            guard let scene = SKScene(fileNamed: "MainMenu") else {
                print("Could not load GameScene with level 1")
                return
            }
            
            /* 3) Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = true
            skView.showsFPS = true
            
            /* 4) Start game scene */
            skView.presentScene(scene)

        }
        
        level1.selectedHandler = {
        guard let scene = GameScene.level(1) else {
                print("Level 1 is missing?")
                return
            }
            UserDefaults.standard.set(1, forKey: "currentLevel")
            UserDefaults.standard.synchronize()
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }

        level2.selectedHandler = {
            guard let scene = GameScene.level(2) else {
                print("Level 1 is missing?")
                return
            }
            UserDefaults.standard.set(2, forKey: "currentLevel")
            UserDefaults.standard.synchronize()

            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
        level3.selectedHandler = {
            guard let scene = GameScene.level(3) else {
                print("Level 1 is missing?")
                return
            }
            UserDefaults.standard.set(3, forKey: "currentLevel")
            UserDefaults.standard.synchronize()
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
    }
}
