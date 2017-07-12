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
var star_2: SKSpriteNode!
var star_3: SKSpriteNode!

var starCounter: SKLabelNode!
var numberOfStars = 0

class LevelSelect: SKScene {
    override func didMove(to view: SKView) {
        
        level1 = childNode(withName: "level1") as! MSButtonNode
        level2 = childNode(withName: "level2") as! MSButtonNode
        level3 = childNode(withName: "level3") as! MSButtonNode
        mainManu = childNode(withName: "mainMenuButton") as! MSButtonNode
        star_1 = childNode(withName: "//star_1_1") as! SKSpriteNode
        star_2 = childNode(withName: "//star_1_2") as! SKSpriteNode
        star_3 = childNode(withName: "//star_1_3") as! SKSpriteNode
        starCounter = childNode(withName: "//starCounter") as! SKLabelNode
        
        if UserDefaults.standard.integer(forKey: "1") == 0 {
            star_1.isHidden = true
            star_2.isHidden = true
            star_3.isHidden = true
        } else {
            if UserDefaults.standard.integer(forKey: "1") > 0 {
                star_1.isHidden = false
                star_2.isHidden = true
                star_3.isHidden = true
                numberOfStars += 1
                if UserDefaults.standard.integer(forKey: "1") > 1 {
                    star_2.isHidden = false
                    star_3.isHidden = true
                    numberOfStars += 1
                    if UserDefaults.standard.integer(forKey: "1") == 3 {
                        star_3.isHidden = false
                        numberOfStars += 1
                    }
                }
            }
        }
        
        if UserDefaults.standard.integer(forKey: "2") == 0 {
            let starLeft = star_1.copy() as! SKSpriteNode
            let starMiddle = star_2.copy() as! SKSpriteNode
            let starRight = star_3.copy() as! SKSpriteNode
            level2.addChild(starLeft)
            level2.addChild(starMiddle)
            level2.addChild(starRight)
            level2.isHidden = true
        } else {
            if UserDefaults.standard.integer(forKey: "2") > 0 {
                let starLeft = star_1.copy() as! SKSpriteNode
                let starMiddle = star_2.copy() as! SKSpriteNode
                let starRight = star_3.copy() as! SKSpriteNode
                level2.addChild(starLeft)
                level2.addChild(starMiddle)
                level2.addChild(starRight)
                starLeft.isHidden = false
                starMiddle.isHidden = true
                starRight.isHidden = true
                numberOfStars += 1
                if UserDefaults.standard.integer(forKey: "2") > 1 {
                    starMiddle.isHidden = false
                    starRight.isHidden = true
                    numberOfStars += 1
                    if UserDefaults.standard.integer(forKey: "2") == 3 {
                        starRight.isHidden = false
                        numberOfStars += 1
                    }
                }
            }
        }
        
        
        if UserDefaults.standard.integer(forKey: "3") == 0 {
            let starLeft = star_1.copy() as! SKSpriteNode
            let starMiddle = star_2.copy() as! SKSpriteNode
            let starRight = star_3.copy() as! SKSpriteNode
            level3.addChild(starLeft)
            level3.addChild(starMiddle)
            level3.addChild(starRight)
            level3.isHidden = true
        } else {
            if UserDefaults.standard.integer(forKey: "3") > 0 {
                let starLeft = star_1.copy() as! SKSpriteNode
                let starMiddle = star_2.copy() as! SKSpriteNode
                let starRight = star_3.copy() as! SKSpriteNode
                level3.addChild(starLeft)
                level3.addChild(starMiddle)
                level3.addChild(starRight)
                starLeft.isHidden = false
                starMiddle.isHidden = true
                starRight.isHidden = true
                numberOfStars += 1
                if UserDefaults.standard.integer(forKey: "3") > 1 {
                    starMiddle.isHidden = false
                    starRight.isHidden = true
                    numberOfStars += 1
                    if UserDefaults.standard.integer(forKey: "3") == 3 {
                        starRight.isHidden = false
                        numberOfStars += 1
                    }
                }
            }
        }
        
        starCounter.text = String(numberOfStars)
        
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
