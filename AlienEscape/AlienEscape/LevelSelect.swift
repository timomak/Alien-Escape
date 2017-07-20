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
var level4: MSButtonNode!
var level5: MSButtonNode!
var level6: MSButtonNode!
var level7: MSButtonNode!
var level8: MSButtonNode!

var mainManu: MSButtonNode!
var star_1: SKSpriteNode!
var star_2: SKSpriteNode!
var star_3: SKSpriteNode!

var starCounter: SKLabelNode!
var numberOfStars = 0

var lifeCounter: SKLabelNode!

var levelGerator = [1: level1, 2: level2, 3: level3,4: level4, 5: level5,6: level6,7: level7, 8: level8]

class LevelSelect: SKScene {
    
    //    func createNewLevel(){
    //        i += 1
    //        let newLevel = level1.copy() as! MSButtonNode
    //        newLevel.position.x = level1.position.x + 85
    //        newLevel.position.y = 0
    //        addChild(newLevel)
    //    }
    
    override func didMove(to view: SKView) {
        
        mainManu = childNode(withName: "mainMenuButton") as! MSButtonNode
        
        starCounter = childNode(withName: "//starCounter") as! SKLabelNode
        lifeCounter = childNode(withName: "//lifeCounter") as! SKLabelNode
        
        
        print("Your checkpoint in level select: \(UserDefaults.standard.integer(forKey: "checkpoint"))")
        var lastCompletedLevel = 1
        for i in 1...(UserDefaults.standard.integer(forKey: "checkpoint") + 1) {
            let levelNumber = String(i)
            
            levelGerator[i] = childNode(withName: "level\(i)") as! MSButtonNode
            
            if UserDefaults.standard.integer(forKey: levelNumber) == 0{
                levelGerator[i]!?.childNode(withName: "star_1")?.isHidden = true
                levelGerator[i]!?.childNode(withName: "star_2")?.isHidden = true
                levelGerator[i]!?.childNode(withName: "star_3")?.isHidden = true
            } else {
                if UserDefaults.standard.integer(forKey: levelNumber) > 0 {
                    levelGerator[i]!?.isHidden = false
                    lastCompletedLevel += 1
                    
                    levelGerator[i]!?.childNode(withName: "star_1")?.isHidden = false
                    levelGerator[i]!?.childNode(withName: "star_2")?.isHidden = true
                    levelGerator[i]!?.childNode(withName: "star_3")?.isHidden = true
                    
                    if UserDefaults.standard.integer(forKey: levelNumber) > 1 {
                        levelGerator[i]!?.childNode(withName: "star_2")?.isHidden = false
                        if UserDefaults.standard.integer(forKey: levelNumber) == 3 {
                            levelGerator[i]!?.childNode(withName: "star_3")?.isHidden = false
                        }
                    }
                }
            }
            levelGerator[i]!?.selectedHandler = {
                guard let scene = GameScene.level(i) else {
                    print("Level \(i) is missing?")
                    return
                }
                UserDefaults.standard.set(i, forKey: "currentLevel")
                UserDefaults.standard.synchronize()
                
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }
        levelGerator[lastCompletedLevel]!?.isHidden = false
        
        func countTheNumberOfStars() {
            for x in 0...UserDefaults.standard.integer(forKey: "checkpoint") {
  
                let levelNumber = String(x)
                numberOfStars += UserDefaults.standard.integer(forKey: levelNumber)
            }
        }
        print("Number of total stars: \(numberOfStars)")
        countTheNumberOfStars()
        
//        numberOfStars = UserDefaults.standard.integer(forKey: "1") + UserDefaults.standard.integer(forKey: "2") + UserDefaults.standard.integer(forKey: "3") + UserDefaults.standard.integer(forKey: "4") + UserDefaults.standard.integer(forKey: "5") + UserDefaults.standard.integer(forKey: "6") + UserDefaults.standard.integer(forKey: "7") + UserDefaults.standard.integer(forKey: "8")
//        
        
        let numberOfLifes = UserDefaults.standard.integer(forKey: "numberOfLifes")
        lifeCounter.text = String(numberOfLifes)
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
    }
}
