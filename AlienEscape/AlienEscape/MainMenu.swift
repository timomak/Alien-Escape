//
//  MainMenu.swift
//  AlienEscape
//
//  Created by timofey makhlay on 6/30/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import SpriteKit


class MainMenu: SKScene{
    
    /* UI Connections */
    var startButton: MSButtonNode!
    var levelSelectButton: MSButtonNode!
    var shopButton: MSButtonNode!
    private var robot: SKSpriteNode!
    private var alien: SKSpriteNode!
    var title: SKSpriteNode!

    var justOpened = true
    
    var level = 0
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        print("Your checkpoint: \(UserDefaults.standard.integer(forKey: "checkpoint"))")
        level = Int(UserDefaults.standard.integer(forKey: "checkpoint"))
        
        /* Set UI connections */
        startButton = self.childNode(withName: "startButton") as! MSButtonNode
        levelSelectButton = self.childNode(withName: "levelSelectButton") as! MSButtonNode
        shopButton = self.childNode(withName: "shopButton") as! MSButtonNode
        alien = self.childNode(withName: "alien") as! SKSpriteNode
        robot = self.childNode(withName: "robot") as! SKSpriteNode
        title = self.childNode(withName: "title") as! SKSpriteNode
        
        levelSelectButton.isHidden = true
        shopButton.isHidden = true
        startButton.position.y = 160
        
        if UserDefaults.standard.integer(forKey: "firstTime") == 0 {
            justOpened = true
            UserDefaults.standard.set(justOpened, forKey: "justOpened")
            UserDefaults.standard.synchronize()
        }


        
        if UserDefaults.standard.integer(forKey: "firstTime") == 1 {
            levelSelectButton.isHidden = false
            shopButton.isHidden = false
            startButton.position.y = 205
            justOpened = UserDefaults.standard.bool(forKey: "justOpened")
        }
        
        print("JustOpened: \(justOpened)")
        
        if justOpened == true {
            alien.run(SKAction(named: "Alien")!)
            robot.run(SKAction(named: "Robot")!)
            levelSelectButton.run(SKAction(named: "Buttons")!)
            startButton.run(SKAction(named: "Buttons")!)
            shopButton.run(SKAction(named: "Buttons")!)
            title.run(SKAction(named: "Buttons")!)
            justOpened = false
            UserDefaults.standard.set(justOpened, forKey: "justOpened")
            UserDefaults.standard.synchronize()
        } else {
            levelSelectButton.alpha = 1
            startButton.alpha = 1
            shopButton.alpha = 1
            title.alpha = 1
        }

        startButton.selectedHandler = {
            self.lastGame()
            
        }
        levelSelectButton.selectedHandler = {
            self.gameSelect()
        }
        shopButton.selectedHandler = {
            self.loadShop()
        }
    }
    
    
    func gameSelect() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed: "LevelSelect") else {
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
    
    func lastGame() {
        if UserDefaults.standard.integer(forKey: "firstTime") != 1 {
            guard let scene = GameScene.level(1) else {
                print("Level 1 is missing?")
                return
            }
            let currentAlien = "Default_Alien"
            UserDefaults.standard.set(currentAlien, forKey: "currentAlien")
            UserDefaults.standard.synchronize()
            UserDefaults.standard.set(30, forKey: "numberOfLifes")
            UserDefaults.standard.synchronize()
            UserDefaults.standard.set(1, forKey: "currentLevel")
            UserDefaults.standard.synchronize()
            scene.scaleMode = .aspectFit
            view?.presentScene(scene)
            
            let number = 1
            UserDefaults.standard.set(number, forKey: "firstTime")
            UserDefaults.standard.synchronize()
        } else {
            guard let scene = GameScene.level(level) else {
                print("Level 1 is missing?")
                return
            }
            UserDefaults.standard.set(level, forKey: "currentLevel")
            UserDefaults.standard.synchronize()
            scene.scaleMode = .aspectFit
            view?.presentScene(scene)
            
        }
    }
    func loadShop() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed: "Shop") else {
            print("Could not load Shop")
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
