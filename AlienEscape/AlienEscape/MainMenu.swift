//
//  MainMenu.swift
//  AlienEscape
//
//  Created by timofey makhlay on 6/30/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    /* UI Connections */
    var startButton: MSButtonNode!
    var levelSelectButton: MSButtonNode!
    
    var level = 0
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        print(UserDefaults.standard.integer(forKey: "checkpoint"))
        level = Int(UserDefaults.standard.integer(forKey: "checkpoint"))
        print(level)
        
        /* Set UI connections */
        startButton = self.childNode(withName: "startButton") as! MSButtonNode
        levelSelectButton = self.childNode(withName: "levelSelectButton") as! MSButtonNode
        levelSelectButton.isHidden = true
        startButton.position.y = 160
        
        if UserDefaults.standard.integer(forKey: "firstTime") == 1 {
            levelSelectButton.isHidden = false
            startButton.position.y = 200
        }
        
        startButton.selectedHandler = {
            self.lastGame()
            
        }
        levelSelectButton.selectedHandler = {
            self.gameSelect()
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
}
