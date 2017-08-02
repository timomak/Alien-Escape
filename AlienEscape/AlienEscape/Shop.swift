//
//  Shop.swift
//  AlienEscape
//
//  Created by timofey makhlay on 8/2/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import SpriteKit

private var cameraNode3: SKCameraNode!
private var starCounter: SKLabelNode!
private var numberOfStars = 0
private var lifeCounter: SKLabelNode!
private var mainManu: MSButtonNode!
private var leftArrow: MSButtonNode!
private var rightArrow: MSButtonNode!

class Shop: SKScene {
    
    override func didMove(to view: SKView) {
        
        cameraNode3 = childNode(withName: "cameraNode3") as! SKCameraNode
        mainManu = childNode(withName: "//mainMenuButton") as! MSButtonNode
        starCounter = childNode(withName: "//starCounter") as! SKLabelNode
        lifeCounter = childNode(withName: "//lifeCounter") as! SKLabelNode
        leftArrow = childNode(withName: "//leftArrow") as! MSButtonNode
        rightArrow = childNode(withName: "//rightArrow") as! MSButtonNode
        scene?.camera = cameraNode3
        
        
        func countTheNumberOfStars() {
            var numberOfStarz = 0
            for x in 0...UserDefaults.standard.integer(forKey: "checkpoint") {
                
                let levelNumber = String(x)
                numberOfStarz += UserDefaults.standard.integer(forKey: levelNumber)
            }
            numberOfStars = numberOfStarz
        }
        countTheNumberOfStars()
        
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
        
        leftArrow.selectedHandler = {
            if cameraNode3.position.x != 285 {
                cameraNode3.position.x -= 600
            } else {
                cameraNode3.position.x = 2085
            }
        }
        
        rightArrow.selectedHandler = {
            if cameraNode3.position.x != 2085 {
                cameraNode3.position.x += 600
            } else {
                cameraNode3.position.x = 285
            }
        }
    }
    
    
    
}
