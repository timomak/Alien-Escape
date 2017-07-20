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

//func level( i: Int) {
//    var level(i): MSButtonNode!
//    level(i) = childNode(withName: "level\(i)") as! MSButtonNode}
//}

var levelGerator = [2: level2, 3: level3,4: level4, 5: level5,6: level6,7: level7, 8: level8]

class LevelSelect: SKScene {
    
    //    func createNewLevel(){
    //        i += 1
    //        let newLevel = level1.copy() as! MSButtonNode
    //        newLevel.position.x = level1.position.x + 85
    //        newLevel.position.y = 0
    //        addChild(newLevel)
    //    }
    
    override func didMove(to view: SKView) {
        
        level1 = childNode(withName: "level1") as! MSButtonNode
        level2 = childNode(withName: "level2") as! MSButtonNode
        level3 = childNode(withName: "level3") as! MSButtonNode
        level4 = childNode(withName: "level4") as! MSButtonNode
        level5 = childNode(withName: "level5") as! MSButtonNode
        level6 = childNode(withName: "level6") as! MSButtonNode
        level7 = childNode(withName: "level7") as! MSButtonNode
        level8 = childNode(withName: "level8") as! MSButtonNode
        
        
        
        mainManu = childNode(withName: "mainMenuButton") as! MSButtonNode
        star_1 = childNode(withName: "//star_1_1") as! SKSpriteNode
        star_2 = childNode(withName: "//star_1_2") as! SKSpriteNode
        star_3 = childNode(withName: "//star_1_3") as! SKSpriteNode
        starCounter = childNode(withName: "//starCounter") as! SKLabelNode
        lifeCounter = childNode(withName: "//lifeCounter") as! SKLabelNode
        
        level2.isHidden = true
        level3.isHidden = true
        level4.isHidden = true
        level5.isHidden = true
        level6.isHidden = true
        level7.isHidden = true
        level8.isHidden = true
        
        
        if UserDefaults.standard.integer(forKey: "1") == 0 {
            star_1.isHidden = true
            star_2.isHidden = true
            star_3.isHidden = true
        } else {
            if UserDefaults.standard.integer(forKey: "1") > 0 {
                star_1.isHidden = false
                star_2.isHidden = true
                star_3.isHidden = true
                
                level2.isHidden = false
                if UserDefaults.standard.integer(forKey: "1") > 1 {
                    star_2.isHidden = false
                    star_3.isHidden = true
                    if UserDefaults.standard.integer(forKey: "1") == 3 {
                        star_3.isHidden = false
                    }
                }
            }
        }

        func createLevelsUntilReachesCheckpoint() {
            var i = 1
            for _ in 1...UserDefaults.standard.integer(forKey: "checkpoint") {
                i += 1
                
                let levelNumber = String(i)
                
                if UserDefaults.standard.integer(forKey: levelNumber) == 0{
                    let starLeft = star_1.copy() as! SKSpriteNode
                    let starMiddle = star_2.copy() as! SKSpriteNode
                    let starRight = star_3.copy() as! SKSpriteNode
                    
                    levelGerator[i]!?.addChild(starLeft)
                    levelGerator[i]!?.addChild(starMiddle)
                    levelGerator[i]!?.addChild(starRight)
                    starLeft.isHidden = true
                    starMiddle.isHidden = true
                    starRight.isHidden = true
                } else {
                    if UserDefaults.standard.integer(forKey: levelNumber) > 0 {
                        levelGerator[i + 1]!?.isHidden = false
                        let starLeft = star_1.copy() as! SKSpriteNode
                        let starMiddle = star_2.copy() as! SKSpriteNode
                        let starRight = star_3.copy() as! SKSpriteNode
                        levelGerator[i]!?.addChild(starLeft)
                        levelGerator[i]!?.addChild(starMiddle)
                        levelGerator[i]!?.addChild(starRight)
                        starLeft.isHidden = false
                        starMiddle.isHidden = true
                        starRight.isHidden = true
                        if UserDefaults.standard.integer(forKey: levelNumber) > 1 {
                            starMiddle.isHidden = false
                            starRight.isHidden = true
                            if UserDefaults.standard.integer(forKey: levelNumber) == 3 {
                                starRight.isHidden = false
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
        }
        createLevelsUntilReachesCheckpoint()
        
//                if UserDefaults.standard.integer(forKey: "2") == 0 {
//                    let starLeft = star_1.copy() as! SKSpriteNode
//                    let starMiddle = star_2.copy() as! SKSpriteNode
//                    let starRight = star_3.copy() as! SKSpriteNode
//                    level2.addChild(starLeft)
//                    level2.addChild(starMiddle)
//                    level2.addChild(starRight)
//                    starLeft.isHidden = true
//                    starMiddle.isHidden = true
//                    starRight.isHidden = true
//                } else {
//                    if UserDefaults.standard.integer(forKey: "2") > 0 {
//                        level3.isHidden = false
//                        let starLeft = star_1.copy() as! SKSpriteNode
//                        let starMiddle = star_2.copy() as! SKSpriteNode
//                        let starRight = star_3.copy() as! SKSpriteNode
//                        level2.addChild(starLeft)
//                        level2.addChild(starMiddle)
//                        level2.addChild(starRight)
//                        starLeft.isHidden = false
//                        starMiddle.isHidden = true
//                        starRight.isHidden = true
//                        if UserDefaults.standard.integer(forKey: "2") > 1 {
//                            starMiddle.isHidden = false
//                            starRight.isHidden = true
//                            if UserDefaults.standard.integer(forKey: "2") == 3 {
//                                starRight.isHidden = false
//                            }
//                        }
//                    }
//                }
//        
//        
//                if UserDefaults.standard.integer(forKey: "3") == 0 {
//                    let starLeft = star_1.copy() as! SKSpriteNode
//                    let starMiddle = star_2.copy() as! SKSpriteNode
//                    let starRight = star_3.copy() as! SKSpriteNode
//                    level3.addChild(starLeft)
//                    level3.addChild(starMiddle)
//                    level3.addChild(starRight)
//                    starLeft.isHidden = true
//                    starMiddle.isHidden = true
//                    starRight.isHidden = true
//                } else {
//                    if UserDefaults.standard.integer(forKey: "3") > 0 {
//                        level4.isHidden = false
//                        let starLeft = star_1.copy() as! SKSpriteNode
//                        let starMiddle = star_2.copy() as! SKSpriteNode
//                        let starRight = star_3.copy() as! SKSpriteNode
//                        level3.addChild(starLeft)
//                        level3.addChild(starMiddle)
//                        level3.addChild(starRight)
//                        starLeft.isHidden = false
//                        starMiddle.isHidden = true
//                        starRight.isHidden = true
//                        if UserDefaults.standard.integer(forKey: "3") > 1 {
//                            starMiddle.isHidden = false
//                            starRight.isHidden = true
//                            if UserDefaults.standard.integer(forKey: "3") == 3 {
//                                starRight.isHidden = false
//                            }
//                        }
//                    }
//                }
//        
//                if UserDefaults.standard.integer(forKey: "4") == 0 {
//                    let starLeft = star_1.copy() as! SKSpriteNode
//                    let starMiddle = star_2.copy() as! SKSpriteNode
//                    let starRight = star_3.copy() as! SKSpriteNode
//                    level4.addChild(starLeft)
//                    level4.addChild(starMiddle)
//                    level4.addChild(starRight)
//                    starLeft.isHidden = true
//                    starMiddle.isHidden = true
//                    starRight.isHidden = true
//                } else {
//                    if UserDefaults.standard.integer(forKey: "4") > 0 {
//                        level5.isHidden = false
//                        let starLeft = star_1.copy() as! SKSpriteNode
//                        let starMiddle = star_2.copy() as! SKSpriteNode
//                        let starRight = star_3.copy() as! SKSpriteNode
//                        level4.addChild(starLeft)
//                        level4.addChild(starMiddle)
//                        level4.addChild(starRight)
//                        starLeft.isHidden = false
//                        starMiddle.isHidden = true
//                        starRight.isHidden = true
//                        if UserDefaults.standard.integer(forKey: "4") > 1 {
//                            starMiddle.isHidden = false
//                            starRight.isHidden = true
//                            if UserDefaults.standard.integer(forKey: "4") == 3 {
//                                starRight.isHidden = false
//                            }
//                        }
//                    }
//                }
//                if UserDefaults.standard.integer(forKey: "5") == 0 {
//                    let starLeft = star_1.copy() as! SKSpriteNode
//                    let starMiddle = star_2.copy() as! SKSpriteNode
//                    let starRight = star_3.copy() as! SKSpriteNode
//                    level5.addChild(starLeft)
//                    level5.addChild(starMiddle)
//                    level5.addChild(starRight)
//                    starLeft.isHidden = true
//                    starMiddle.isHidden = true
//                    starRight.isHidden = true
//                } else {
//                    if UserDefaults.standard.integer(forKey: "5") > 0 {
//                        level6.isHidden = false
//                        let starLeft = star_1.copy() as! SKSpriteNode
//                        let starMiddle = star_2.copy() as! SKSpriteNode
//                        let starRight = star_3.copy() as! SKSpriteNode
//                        level5.addChild(starLeft)
//                        level5.addChild(starMiddle)
//                        level5.addChild(starRight)
//                        starLeft.isHidden = false
//                        starMiddle.isHidden = true
//                        starRight.isHidden = true
//                        if UserDefaults.standard.integer(forKey: "5") > 1 {
//                            starMiddle.isHidden = false
//                            starRight.isHidden = true
//                            if UserDefaults.standard.integer(forKey: "5") == 3 {
//                                starRight.isHidden = false
//                            }
//                        }
//                    }
//                }
//        
//                if UserDefaults.standard.integer(forKey: "6") == 0 {
//                    let starLeft = star_1.copy() as! SKSpriteNode
//                    let starMiddle = star_2.copy() as! SKSpriteNode
//                    let starRight = star_3.copy() as! SKSpriteNode
//                    level6.addChild(starLeft)
//                    level6.addChild(starMiddle)
//                    level6.addChild(starRight)
//                    starLeft.isHidden = true
//                    starMiddle.isHidden = true
//                    starRight.isHidden = true
//                } else {
//                    if UserDefaults.standard.integer(forKey: "6") > 0 {
//                        level7.isHidden = false
//                        let starLeft = star_1.copy() as! SKSpriteNode
//                        let starMiddle = star_2.copy() as! SKSpriteNode
//                        let starRight = star_3.copy() as! SKSpriteNode
//                        level6.addChild(starLeft)
//                        level6.addChild(starMiddle)
//                        level6.addChild(starRight)
//                        starLeft.isHidden = false
//                        starMiddle.isHidden = true
//                        starRight.isHidden = true
//                        if UserDefaults.standard.integer(forKey: "6") > 1 {
//                            starMiddle.isHidden = false
//                            starRight.isHidden = true
//                            if UserDefaults.standard.integer(forKey: "6") == 3 {
//                                starRight.isHidden = false
//                            }
//                        }
//                    }
//                }
//                if UserDefaults.standard.integer(forKey: "7") == 0 {
//                    let starLeft = star_1.copy() as! SKSpriteNode
//                    let starMiddle = star_2.copy() as! SKSpriteNode
//                    let starRight = star_3.copy() as! SKSpriteNode
//                    level7.addChild(starLeft)
//                    level7.addChild(starMiddle)
//                    level7.addChild(starRight)
//                    starLeft.isHidden = true
//                    starMiddle.isHidden = true
//                    starRight.isHidden = true
//                } else {
//                    if UserDefaults.standard.integer(forKey: "7") > 0 {
//                        level8.isHidden = false
//                        let starLeft = star_1.copy() as! SKSpriteNode
//                        let starMiddle = star_2.copy() as! SKSpriteNode
//                        let starRight = star_3.copy() as! SKSpriteNode
//                        level7.addChild(starLeft)
//                        level7.addChild(starMiddle)
//                        level7.addChild(starRight)
//                        starLeft.isHidden = false
//                        starMiddle.isHidden = true
//                        starRight.isHidden = true
//                        if UserDefaults.standard.integer(forKey: "7") > 1 {
//                            starMiddle.isHidden = false
//                            starRight.isHidden = true
//                            if UserDefaults.standard.integer(forKey: "7") == 3 {
//                                starRight.isHidden = false
//                            }
//                        }
//                    }
//                }
//                if UserDefaults.standard.integer(forKey: "8") == 0 {
//                    let starLeft = star_1.copy() as! SKSpriteNode
//                    let starMiddle = star_2.copy() as! SKSpriteNode
//                    let starRight = star_3.copy() as! SKSpriteNode
//                    level8.addChild(starLeft)
//                    level8.addChild(starMiddle)
//                    level8.addChild(starRight)
//                    starLeft.isHidden = true
//                    starMiddle.isHidden = true
//                    starRight.isHidden = true
//                } else {
//                    if UserDefaults.standard.integer(forKey: "8") > 0 {
//                        //level9.isHidden = false
//                        let starLeft = star_1.copy() as! SKSpriteNode
//                        let starMiddle = star_2.copy() as! SKSpriteNode
//                        let starRight = star_3.copy() as! SKSpriteNode
//                        level8.addChild(starLeft)
//                        level8.addChild(starMiddle)
//                        level8.addChild(starRight)
//                        starLeft.isHidden = false
//                        starMiddle.isHidden = true
//                        starRight.isHidden = true
//                        if UserDefaults.standard.integer(forKey: "8") > 1 {
//                            starMiddle.isHidden = false
//                            starRight.isHidden = true
//                            if UserDefaults.standard.integer(forKey: "8") == 3 {
//                                starRight.isHidden = false
//                            }
//                        }
//                    }
//                }
//        
        
        numberOfStars = UserDefaults.standard.integer(forKey: "1") + UserDefaults.standard.integer(forKey: "2") + UserDefaults.standard.integer(forKey: "3") + UserDefaults.standard.integer(forKey: "4") + UserDefaults.standard.integer(forKey: "5") + UserDefaults.standard.integer(forKey: "6") + UserDefaults.standard.integer(forKey: "7") + UserDefaults.standard.integer(forKey: "8")
        
        
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
        
//        level2.selectedHandler = {
//            guard let scene = GameScene.level(2) else {
//                print("Level 1 is missing?")
//                return
//            }
//            UserDefaults.standard.set(2, forKey: "currentLevel")
//            UserDefaults.standard.synchronize()
//            
//            scene.scaleMode = .aspectFit
//            view.presentScene(scene)
//        }
//        
//        level3.selectedHandler = {
//            guard let scene = GameScene.level(3) else {
//                print("Level 1 is missing?")
//                return
//            }
//            UserDefaults.standard.set(3, forKey: "currentLevel")
//            UserDefaults.standard.synchronize()
//            scene.scaleMode = .aspectFit
//            view.presentScene(scene)
//        }
//        level4.selectedHandler = {
//            guard let scene = GameScene.level(4) else {
//                print("Level 1 is missing?")
//                return
//            }
//            UserDefaults.standard.set(4, forKey: "currentLevel")
//            UserDefaults.standard.synchronize()
//            scene.scaleMode = .aspectFit
//            view.presentScene(scene)
//        }
//        level5.selectedHandler = {
//            guard let scene = GameScene.level(5) else {
//                print("Level 1 is missing?")
//                return
//            }
//            UserDefaults.standard.set(5, forKey: "currentLevel")
//            UserDefaults.standard.synchronize()
//            scene.scaleMode = .aspectFit
//            view.presentScene(scene)
//        }
//        level6.selectedHandler = {
//            guard let scene = GameScene.level(6) else {
//                print("Level 1 is missing?")
//                return
//            }
//            UserDefaults.standard.set(6, forKey: "currentLevel")
//            UserDefaults.standard.synchronize()
//            scene.scaleMode = .aspectFit
//            view.presentScene(scene)
//        }
//        level7.selectedHandler = {
//            guard let scene = GameScene.level(7) else {
//                print("Level 1 is missing?")
//                return
//            }
//            UserDefaults.standard.set(7, forKey: "currentLevel")
//            UserDefaults.standard.synchronize()
//            scene.scaleMode = .aspectFit
//            view.presentScene(scene)
//        }
//        level8.selectedHandler = {
//            guard let scene = GameScene.level(8) else {
//                print("Level 1 is missing?")
//                return
//            }
//            UserDefaults.standard.set(8, forKey: "currentLevel")
//            UserDefaults.standard.synchronize()
//            scene.scaleMode = .aspectFit
//            view.presentScene(scene)
//        }
    }
}
