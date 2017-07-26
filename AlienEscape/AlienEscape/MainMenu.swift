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
    var videoButton: MSButtonNode!
    
    var level = 0
    
    override func didMove(to view: SKView) {
        Chartboost.setDelegate(self)
        /* Setup your scene here */
        print("Your checkpoint: \(UserDefaults.standard.integer(forKey: "checkpoint"))")
        level = Int(UserDefaults.standard.integer(forKey: "checkpoint"))
        
        /* Set UI connections */
        startButton = self.childNode(withName: "startButton") as! MSButtonNode
        levelSelectButton = self.childNode(withName: "levelSelectButton") as! MSButtonNode
        levelSelectButton.isHidden = true
        startButton.position.y = 160
        
        videoButton = self.childNode(withName: "videoButton") as! MSButtonNode
        
        if UserDefaults.standard.integer(forKey: "firstTime") == 1 {
            levelSelectButton.isHidden = false
            startButton.position.y = 200
        }
        videoButton.isHidden = true
        videoButton.selectedHandler = {
            Chartboost.showRewardedVideo(CBLocationMainMenu)
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
            UserDefaults.standard.set(100, forKey: "numberOfLifes")
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
}
extension MainMenu: ChartboostDelegate {
    
    func didPrefetchVideos() {
    }
    
    func shouldDisplayRewardedVideo(location: String!) -> Bool {
        return true
    }
    
    func didDisplayRewardedVideo(location: String!) {
    }
    
    func didCacheRewardedVideo(location: String!) {
    }
    
    func didFailToLoadRewardedVideo(location: String!, withError error: CBLoadError) {
        print("Failed to load rewarded video: \(error)")
    }
    
    func didDismissRewardedVideo(location: String!) {
    }
    
    func didCloseRewardedVideo(location: String!) {
        print("HERE IS WHEN I GIVE YOU LIVES")
    }
    
    func didClickRewardedVideo(location: String!) {
    }
    
    func didCompleteRewardedVideo(location: String!, withReward reward: Int32) {
    }
    
    func willDisplayVideo(location: String!) {
    }
    
}
