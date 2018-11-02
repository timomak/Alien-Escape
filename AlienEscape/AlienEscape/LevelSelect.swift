//
//  LevelScore.swift
//  AlienEscape
//
//  Created by timofey makhlay on 7/10/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameplayKit

var cameraNode2: SKCameraNode!
var background: SKSpriteNode!

var level1: MSButtonNode!
var level2: MSButtonNode!
var level3: MSButtonNode!
var level4: MSButtonNode!
var level5: MSButtonNode!
var level6: MSButtonNode!
var level7: MSButtonNode!
var level8: MSButtonNode!
var level9: MSButtonNode!
var level10: MSButtonNode!
var level11: MSButtonNode!
var level12: MSButtonNode!


private var mainManu: MSButtonNode!
var star_1: SKSpriteNode!
var star_2: SKSpriteNode!
var star_3: SKSpriteNode!

private var starCounter: SKLabelNode!
private var numberOfStars = 0

private var lifeCounter: SKLabelNode!

private var sound: SKAudioNode!

var littleSpaceship: SKSpriteNode!
var littleMars: SKSpriteNode!
var littleSpaceman: SKSpriteNode!

let swipeUpRec = UISwipeGestureRecognizer()
let swipeDownRec = UISwipeGestureRecognizer()
private var swipedUpAlreadyInUse = false
private var swipedDownAlreadyInUse = false

var currentView = String()

var currentChapter = 1

var levelGerator = [1: level1, 2: level2, 3: level3,4: level4, 5: level5,6: level6,7: level7, 8: level8, 9: level9, 10: level10, 11: level11, 12: level12]

class LevelSelect: SKScene {

    override func didMove(to view: SKView) {
        currentView = "levelSelect"
        currentChapter = 1
        littleSpaceship = childNode(withName: "//little_spaceship") as! SKSpriteNode
        littleMars = childNode(withName: "//little_mars") as! SKSpriteNode
        littleSpaceman = childNode(withName: "//little_spaceman") as! SKSpriteNode
        
        cameraNode2 = childNode(withName: "cameraNode2") as! SKCameraNode
        background = childNode(withName: "background") as! SKSpriteNode
        mainManu = childNode(withName: "//mainMenuButton") as! MSButtonNode
        scene?.camera = cameraNode2
        
        littleSpaceship.setScale(0.04)
        littleMars.setScale(0.02)
        littleSpaceman.setScale(0.02)
        
        // MARK: Gesture Swipe Recognizer
        print("Did load functions in level Select")
        
        if swipedUpAlreadyInUse == false {
            swipeUpRec.addTarget(self, action: #selector(LevelSelect.swipedUp) )
            swipeUpRec.direction = .up
            self.view!.addGestureRecognizer(swipeUpRec)
            swipedUpAlreadyInUse = true
        }
        
        if swipedDownAlreadyInUse == false {
            swipeDownRec.addTarget(self, action: #selector(LevelSelect.swipedDown) )
            swipeDownRec.direction = .down
            self.view!.addGestureRecognizer(swipeDownRec)
            swipedUpAlreadyInUse = true
        }
        
        if let musicURL = Bundle.main.url(forResource: "LevelSelectSound", withExtension: "mp3") {
            sound = SKAudioNode(url: musicURL)
            addChild(sound)
        }
        
        starCounter = childNode(withName: "//starCounter") as! SKLabelNode
        lifeCounter = childNode(withName: "//lifeCounter") as! SKLabelNode
        
        print("Your checkpoint in level select: \(UserDefaults.standard.integer(forKey: "checkpoint"))")
        var lastCompletedLevel = 1
        for i in 1...(UserDefaults.standard.integer(forKey: "checkpoint") + 1) {
            let levelNumber = String(i)
            levelGerator[i] = childNode(withName: "//level\(i)") as? MSButtonNode
            
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
                currentView = "not LevelSelect"
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
            currentView = "not LevelSelect"
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
    
    func checkCameraPosition() {
        // Camera Animations
        let cameraMoveToChapterOne = SKAction.moveTo(y: 0, duration: 0.5)
        let cameraMoveToChapterTwo = SKAction.moveTo(y: -365, duration: 0.5)
        let cameraMoveToChapterThree = SKAction.moveTo(y: -650, duration: 0.5)
        // Little Chapters Animation
        let moveSpaceshipUp = SKAction.moveTo(y: 40.5, duration: 0.2)
        let moveSpaceshipToOriginal = SKAction.moveTo(y: 35.5, duration: 0.2)
        let moveMarsUp = SKAction.moveTo(y: 5.5, duration: 0.2)
        let moveMarsDown = SKAction.moveTo(y: -4.5, duration: 0.2)
        let moveMarsToOriginal = SKAction.moveTo(y: 0.5, duration: 0.2)
        let moveSpacemanDown = SKAction.moveTo(y: -39.5, duration: 0.2)
        let moveSpacemanToOriginal = SKAction.moveTo(y: -34.5, duration: 0.2)
        
        if currentChapter == 1 {
            cameraNode2.run(cameraMoveToChapterOne)
            littleSpaceship.setScale(0.04)
            littleMars.setScale(0.02)
            littleSpaceman.setScale(0.02)
            littleSpaceship.run(moveSpaceshipToOriginal)
            littleMars.run(moveMarsDown)
            littleSpaceman.run(moveSpacemanDown)
        } else if currentChapter == 2{
            cameraNode2.run(cameraMoveToChapterTwo)
            littleSpaceship.setScale(0.02)
            littleMars.setScale(0.04)
            littleSpaceman.setScale(0.02)
            littleSpaceship.run(moveSpaceshipUp)
            littleMars.run(moveMarsToOriginal)
            littleSpaceman.run(moveSpacemanDown)
        } else if currentChapter == 3{
            cameraNode2.run(cameraMoveToChapterThree)
            littleSpaceship.setScale(0.02)
            littleMars.setScale(0.02)
            littleSpaceman.setScale(0.04)
            littleSpaceship.run(moveSpaceshipUp)
            littleMars.run(moveMarsUp)
            littleSpaceman.run(moveSpacemanToOriginal)
        }
    }
    @objc private func swipedUp() {
        if currentView == "levelSelect" {
        print("current Chapter: ",currentChapter)
        let targetY = cameraNode2.position.y
        let y = clamp(value: targetY, lower: -620, upper: -10)
        cameraNode2.position.y = y
        
        if currentChapter == 1 {
            currentChapter = 2
        }
        else if currentChapter == 2{
            currentChapter = 3
        }
        else if currentChapter == 3{
            currentChapter = 3
        }
        checkCameraPosition()
        }
    }
    
    @objc private func swipedDown() {
        if currentView == "levelSelect" {
        print("current Chapter: ",currentChapter)
        let targetY = cameraNode2.position.y
        let y = clamp(value: targetY, lower: -620, upper: -10)
        cameraNode2.position.y = y
        
        if currentChapter == 1 {
            currentChapter = 1
        }
        else if currentChapter == 2{
            currentChapter = 1
        }
        else if currentChapter == 3{
            currentChapter = 2
        }
        checkCameraPosition()
        }
    }
}
