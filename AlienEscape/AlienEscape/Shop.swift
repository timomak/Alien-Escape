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
private var robotAlien: MSButtonNode!
private var armoredAlien: MSButtonNode!
private var darkAlien: MSButtonNode!
private var greenAlien: MSButtonNode!
private var checkMark1: SKSpriteNode!
private var checkMark2: SKSpriteNode!
private var checkMark3: SKSpriteNode!
private var checkMark4: SKSpriteNode!

enum SelectedSkin {
    case robotAlien, armoredAlien, darkAlien, greenAlien
}

class Shop: SKScene {
    
    var currentSkin: SelectedSkin = .greenAlien {
        didSet {
            switch currentSkin {
            case .greenAlien:
                greenAlienSkinCheck()
            case .darkAlien:
                darkAlienSkinCheck()
            case .armoredAlien:
                armoredAlienSkinCheck()
            case .robotAlien:
                robotAlienSkinCheck()
                
            }
        }
    }
    
    func currentSkinCheck() {
        
        checkMark1.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark2.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark3.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark4.texture = SKTexture(imageNamed: "checkCircle_locked")
        
        if numberOfStars > -1  {
            checkMark4.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 9  {
            checkMark2.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 18  {
            checkMark3.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 30  {
            checkMark1.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
    }
    
    override func didMove(to view: SKView) {
        
        cameraNode3 = childNode(withName: "cameraNode3") as! SKCameraNode
        mainManu = childNode(withName: "//mainMenuButton") as! MSButtonNode
        starCounter = childNode(withName: "//starCounter") as! SKLabelNode
        lifeCounter = childNode(withName: "//lifeCounter") as! SKLabelNode
        leftArrow = childNode(withName: "//leftArrow") as! MSButtonNode
        rightArrow = childNode(withName: "//rightArrow") as! MSButtonNode
        robotAlien = childNode(withName: "robot") as! MSButtonNode
        armoredAlien = childNode(withName: "armored_Alien") as! MSButtonNode
        darkAlien = childNode(withName: "dark_Alien") as! MSButtonNode
        greenAlien = childNode(withName: "green_Alien") as! MSButtonNode
        
        checkMark1 = childNode(withName: "//checkMark1") as! SKSpriteNode
        checkMark2 = childNode(withName: "//checkMark2") as! SKSpriteNode
        checkMark3 = childNode(withName: "//checkMark3") as! SKSpriteNode
        checkMark4 = childNode(withName: "//checkMark4") as! SKSpriteNode
        
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
        
        currentSkinCheck()
        
        robotAlien.selectedHandler = {
            if numberOfStars >= 30  {
                self.currentSkin = .robotAlien
            }
        }
        armoredAlien.selectedHandler = {
            if numberOfStars >= 9  {
                self.currentSkin = .armoredAlien
            }
        }
        greenAlien.selectedHandler = {
            self.currentSkin = .greenAlien
        }
        darkAlien.selectedHandler = {
            if numberOfStars >= 18  {
                self.currentSkin = .darkAlien
            }
        }
        
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
    
    func greenAlienSkinCheck() {
        
        checkMark1.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark2.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark3.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark4.texture = SKTexture(imageNamed: "checkCircle_locked")
        
        if numberOfStars > -1  {
            checkMark4.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 9  {
            checkMark2.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 18  {
            checkMark3.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 30  {
            checkMark1.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        checkMark4.texture = SKTexture(imageNamed: "checkCircle_checked")
    }
    
    func robotAlienSkinCheck() {
        
        checkMark1.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark2.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark3.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark4.texture = SKTexture(imageNamed: "checkCircle_locked")
        
        if numberOfStars > -1  {
            checkMark4.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 9  {
            checkMark2.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 18  {
            checkMark3.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 30  {
            checkMark1.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        checkMark1.texture = SKTexture(imageNamed: "checkCircle_checked")
    }
    
    func armoredAlienSkinCheck() {
        
        checkMark1.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark2.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark3.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark4.texture = SKTexture(imageNamed: "checkCircle_locked")
        
        if numberOfStars > -1  {
            checkMark4.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 9  {
            checkMark2.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 18  {
            checkMark3.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 30  {
            checkMark1.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        checkMark2.texture = SKTexture(imageNamed: "checkCircle_checked")
    }
    
    func darkAlienSkinCheck() {
        
        checkMark1.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark2.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark3.texture = SKTexture(imageNamed: "checkCircle_locked")
        checkMark4.texture = SKTexture(imageNamed: "checkCircle_locked")
        
        if numberOfStars > -1  {
            checkMark4.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 9  {
            checkMark2.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 18  {
            checkMark3.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        if numberOfStars >= 30  {
            checkMark1.texture = SKTexture(imageNamed: "checkCircle_empty")
        }
        
        checkMark3.texture = SKTexture(imageNamed: "checkCircle_checked")
    }
    
}
