//
//  GameScene.swift
//  AlienEscape
//
//  Created by timofey makhlay on 6/30/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import SpriteKit
import GoogleMobileAds
import AudioToolbox

/* LARGE TODO LIST:
     * Fix gamestate. Doesn't let menu open once game is not .playing
     * Fix Ads. They sometimes don't open properly
     * Fix Camera borders.
*/

// Sets the outer bouderies of the level (it will stop the camera from looking outside of the scope).
func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

extension CGVector {
    
    // Calculate lenght using pythagorian theory
    public func length() -> CGFloat {
        return CGFloat(sqrt(dx*dx + dy*dy))
    }
}

/// Slingshot settingss
/**
 Will set parameters for the Slingshot such as:
    * How big the projectile radius is (its invisible size)
    * Where the rest position of the projectile is on screen.
    * Threshold (to check how far the minumum drag or pull of the projectile is)
    * Force multiplier (how fast the projectile is gonna be launched.)
    * Not sure what the rLimit is :)
 
 And it will set the gravity indiviadually for the projectile so it's unaffected by the physics world.
*/
struct Settings {
    struct Metrics {
        static let projectileRadius = CGFloat(16)
        static let projectileRestPosition = CGPoint(x: -100, y: 40)
        static let projectileTouchThreshold = CGFloat(30)
        static let projectileSnapLimit = CGFloat(10)
        static let forceMultiplier = CGFloat(0.7)
        static let rLimit = CGFloat(80)
    }
    struct Game {
        static let gravity = CGVector(dx: 0,dy: -9.8)
    }
}

// Game States (pause, playing, over and won are the game modes).
enum GameState {
    case paused, playing, gameOver, won
}

class GameScene: SKScene, SKPhysicsContactDelegate, GADRewardBasedVideoAdDelegate{

    // Calling a function when the game state changes. The level starts at .playing mode.
    var gameState: GameState = .playing {
        didSet {
            switch gameState {
            case .gameOver:
                GameOver()
            case .paused:
                break
            case .won:
                win()
            case .playing:
                break
            }
        }
    }
    
    // Adds Menus, but they're not visible in .playing mode.
    var GUI: SKReferenceNode!
    var menus: guiCode!
    
    // Timer Bar
    var timerBarContainer: SKSpriteNode!
    var timerBarIndicator :SKSpriteNode!
    
    // Visual timer that shrinks in size as time goes on.
    var timerBar: CGFloat = 1.0 {
        didSet {
            // Bar health between 0.0 -> 100.0
            timerBarIndicator.xScale = timerBar
        }
    }
    
    // Stars that appear after winning or losing on a level. Signify how fast they passed the level.
    var starOne :SKSpriteNode!
    var starTwo :SKSpriteNode!
    var starThree :SKSpriteNode!
    
    // Individual GUI Menus
    var winMenu: SKSpriteNode!
    var nextLevelButton: MSButtonNode!
    var pauseMenu: SKSpriteNode!
    var resetButton: MSButtonNode!
    var resumeButton: MSButtonNode!
    var levelSelectButton: MSButtonNode!
    var gameOverSign: SKSpriteNode!
    
    // Main timer count. 1 per frame. (The game is 60 Frames Per Second).
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    
    // Timer for the game
    var gameStart: CFTimeInterval = 0
    var timer: CFTimeInterval = 0
    
    // TODO: Find out more about how these timers are used and how to fix it.
    var trajectoryTimeOut: CFTimeInterval = 1
    
    // Background Sprite used to know when it makes contact with the projectile (it's game over if the projectile touches the ground).
    var background: SKSpriteNode!
    
    // Portal Sprites to teleport ball. Not used on all levels, but physically present on all (just outside of the frame)
    var portal1: SKSpriteNode!
    var portal2: SKSpriteNode!
    var portalA: SKSpriteNode!
    var portalB: SKSpriteNode!
    
    // Alien Sprite
    var alien: SKSpriteNode!
    
    // TODO: Check what this does
    var inGameMenu: MSButtonNode!
    
    // Projectile Class
    var projectile: spear!
    
    /// Touch dragging variables
    var projectileIsDragged = false
    var touchCurrentPoint: CGPoint!
    var touchStartingPoint: CGPoint!
    
    // Setting up camera
    var cameraNode:SKCameraNode!
    var cameraTarget:SKSpriteNode!
    
    // Sets the current level value (this changes when a level is loaded, 1 is the default level for the first time user).
    var currentLevel = 1
    
    // Tracks the [ Current Level : Number of stars (out of 3) ]
    var levelScore = [ 0: 0]
    
    // Tracks the highest level reached by the player.
    var lastLevel = 1
    
    // TODO: Check what you do with this.
    var winCount = 1
    
    // Sprite to visually track the number of lives left.
    var lifeCounter: SKLabelNode!
    
    // Check if the projectile has been launched.
    var released = false
    
    // Class to launch the projectile before it's launched.
    var projectileBox: Projectile!
    
    // Default Portals ( Blue & Yellow )
    var bluePortalDrag: SKSpriteNode!
    var yellowPortalDrag: SKSpriteNode!
    
    // Variables to track the dragging of portals.
    var currentMovingPortal = SKSpriteNode()
    var bluePortalHasBeenPlaced = false
    var yellowPortalHasBeenPlaced = false
    
    /*
        MARK: This decides what tools for completion of the level the user has access to.
        This is where to decide if the player will have access to portals or vortexes etc...
        Within the array, is the number of the levels that use those tools.
        Very easy to scale the same tools on different levels wihtout re-writing code.
    */
    
    // More than 2 portals
    var levelWithExtraPortals = [9,10]
    
    // Draggable portals
    var levelWithDraggablePortals = [5,10]
    
    // Being able to move the camera ( Teleport ).
    var levelWithMovingCameraFromAtoB = [7]
    
    // Can move the camera ( LEFT & RIGHT )
    var levelWithMovableCameraInXAxis = [8,9,10]
    
    // Can move the camera ( UP & DOWN )
    var levelWithMovableCameraInYAxis = [8,9,10]
    
    // TODO: Figure out how they're used.
    var topBorder: SKSpriteNode!
    var rightBorder: SKSpriteNode!
    
    // Track where the first point of dragging the projectile is. ( used to calculate the distace and everything else )
    var projectileFirstPosition = CGPoint()
    
    // Label Indicator Sprites
    var labelReferenceNode: SKReferenceNode!
    var labelIndicators: Indicators!
    var powerLabel: SKLabelNode!
    var angleLabel: SKLabelNode!
    
    // Ads Logic
    private var adPopUp: SKReferenceNode!
    private var adScreen: AdPage!
    private var mainMenuButton: MSButtonNode!
    private var watchAd: MSButtonNode!
    
    // The four dots to show the prediction line for the projectile
    var projectilePredictionPoint1: SKSpriteNode!
    var projectilePredictionPoint2: SKSpriteNode!
    var projectilePredictionPoint3: SKSpriteNode!
    var projectilePredictionPoint4: SKSpriteNode!
    var projectilePredictionPoint5: SKSpriteNode!
    
    // TODO: Figure out what this code does. Number of lives
    var numberOfLives = 0
    var watchedAdGiveLives = false
    
    // Set the bounderies for the camera. (The camera will follow
    func cameraMove() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 240, upper: rightBorder.position.x - 550)
        cameraNode.position.x = x
        
        // MARK: Chapter 3
        let targetY = cameraTarget.position.y
        let y = clamp(value: targetY, lower: 128, upper: topBorder.position.y - 320)
        cameraNode.position.y = y
    }
    
    // MARK: Loading Levels the level depending on the currentLevel Integer
    class func level(_ currentLevel: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(currentLevel)") else {
            return nil
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    // TODO: Check what this does.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        
        print("number of lifes is: \(numberOfLives)")
        print("number of lifes is: \(UserDefaults.standard.integer(forKey: "numberOfLifes"))")
    }
    
    // TODO: Check if it works.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        /*
            Actions once the ad has been displayed.
        */
        print("\n---------- SOMETHING AD ----------/n")
        if watchedAdGiveLives == true {
            print("\n---------- Getting $ AD ----------/n")
            // Pulls the number of lifes the player has left and adds 30 to it. Saves it again.
            numberOfLives = UserDefaults.standard.integer(forKey: "numberOfLifes") + 30
            UserDefaults.standard.set(numberOfLives, forKey: "numberOfLifes")
            UserDefaults.standard.synchronize()
            
            // Ad slides off screen
            adScreen.run(SKAction.moveTo(y: 1600, duration: 1))
            
            // Updating the life counter text
            lifeCounter.text = String(numberOfLives)
            
            // Changing game state
            gameState = .playing
            
            // Making the request for the AD
            let request = GADRequest()
            
            // MARK: Uncomment before pushing to the app store
            request.testDevices = [ kGADSimulatorID ];
            GADRewardBasedVideoAd.sharedInstance().load(request,
                                                        withAdUnitID: "ca-app-pub-6454574712655895/9250778455")
            print("number of lifes after ad is: \(UserDefaults.standard.integer(forKey: "numberOfLifes"))")
            
            // Make sure it only happens once
            watchedAdGiveLives = false
        }
            // TODO: Check if the else is needed
        else {
            return
        }
    }
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        // TODO: CHeck if this one is running of the function above.
        
        print("\n---------- CLOSING AD ----------/n")
        
        numberOfLives = UserDefaults.standard.integer(forKey: "numberOfLifes") + 30
        UserDefaults.standard.set(numberOfLives, forKey: "numberOfLifes")
        UserDefaults.standard.synchronize()
        adScreen.run(SKAction.moveTo(y: 1600, duration: 1))
        lifeCounter.text = String(numberOfLives)
        gameState = .playing
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID ];
        GADRewardBasedVideoAd.sharedInstance().load(request,
                                                    withAdUnitID: "ca-app-pub-6454574712655895/9250778455")
        print("number of lifes after ad is: \(UserDefaults.standard.integer(forKey: "numberOfLifes"))")
    }
    
    override func didMove(to view: SKView) {
        /*
            This is the first / main function that runs and puts everything in view, in place.
        */
        
        // Sets the current level to what was previously saved.
        currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        
        // Alien Sprite
        alien = childNode(withName: "//alien") as? SKSpriteNode
        
        // If the current alien is Robot, it will unfortunately have a slighly different size.
        if UserDefaults.standard.object(forKey: "currentAlien") as! String ==  "Robot_Alien" {
            alien.size = CGSize(width: 255, height: 430)
        }
        
        // Starts animation depending on which skin is currenly selected.
        alien.run(SKAction(named: UserDefaults.standard.object(forKey: "currentAlien") as! String)!)
        
        // Connects what is on the level to variable through their names.
        inGameMenu = childNode(withName: "//inGameMenu") as? MSButtonNode
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode
        
        // Connecting portals
        portal1 = childNode(withName: "portal_1") as? SKSpriteNode
        portal2 = childNode(withName: "portal_2") as? SKSpriteNode
        
        
        // MARK: SK Reference link
        // Connecting similarly to how you would add a XIB file to a storyboard.
        labelReferenceNode = SKReferenceNode(fileNamed: "Indicator")
        labelReferenceNode.physicsBody = nil
        self.addChild(labelReferenceNode!)
        
        labelIndicators = labelReferenceNode.childNode(withName: "//labelIndicators") as? Indicators
        angleLabel = labelIndicators.angleIndicator!
        powerLabel = labelIndicators.powerIndicator!
        labelIndicators.position = CGPoint(x: 40, y: 20)
        
        // MARK: GUI Setup
        GUI = SKReferenceNode(fileNamed: "GUI_Menus")
        GUI.physicsBody = nil
        self.addChild(GUI!)
        
        // Init
        menus = GUI.childNode(withName: "//parentGUI") as? guiCode
        winMenu = menus.winMenu_guiCode!
        starOne = menus.starOne_guiCode!
        starTwo = menus.starTwo_guiCode!
        starThree = menus.starThree_guiCode!
        pauseMenu = menus.pauseMenu_guiCode!
        nextLevelButton = menus.nextLevelButton_guiCode!
        levelSelectButton = menus.levelSelectButton_guiCode!
        resetButton = menus.resetButton_guiCode!
        resumeButton = menus.resumeButton_guiCode!
        gameOverSign = menus.gameOverSign_guiCode!
        timerBarContainer = menus.timerContainer_guiCode!
        timerBarIndicator = menus.timerBars_guiCode!
        
        timerBarContainer.removeFromParent()
        cameraNode.addChild(timerBarContainer)
        timerBarContainer.position = CGPoint(x: 0, y: -135)
        
        menus.position = CGPoint(x: cameraNode.position.x, y: -446.994)
        winMenu.childNode(withName: "cameraNode")
 
        // MARK: AD by ADMOB: https://developers.google.com/admob/ios/rewarded-video
        GADRewardBasedVideoAd.sharedInstance().delegate = (self as GADRewardBasedVideoAdDelegate)
        
        // Giving a View to display the ad
        // TODO: Figure out the differences between these.
        adPopUp = SKReferenceNode(fileNamed: "adPage")
        adPopUp.physicsBody = nil
        self.addChild(adPopUp!)
        adScreen = adPopUp.childNode(withName: "//adScreen") as? AdPage
        mainMenuButton = adScreen.mainMenuButton2!
        watchAd = adScreen.watchAd!
        
        adScreen.position = CGPoint(x: cameraNode.position.x, y: 1600)
        
        // MARK: Extra Portals
        if levelWithExtraPortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            portalA = childNode(withName: "portal_A") as? SKSpriteNode
            portalB = childNode(withName: "portal_B") as? SKSpriteNode
        }
        
        // MARK: Draggable Portals
        if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            
            bluePortalDrag = childNode(withName: "//bluePortalDrag") as? SKSpriteNode
            yellowPortalDrag = childNode(withName: "//yellowPortalDrag") as? SKSpriteNode
            
            bluePortalDrag.isHidden = true
            yellowPortalDrag.isHidden = true
        }
        
        // MARK: Larger Levels Borders
        if levelWithMovableCameraInXAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) || levelWithMovableCameraInYAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            topBorder = childNode(withName: "topBorder") as? SKSpriteNode
            rightBorder = childNode(withName: "rightBorder") as? SKSpriteNode
        }
        
        background = childNode(withName: "background") as? SKSpriteNode
        lifeCounter = childNode(withName: "//lifeCounter") as? SKLabelNode
        numberOfLives = UserDefaults.standard.integer(forKey: "numberOfLifes")
        
        // MARK: Loading add if no lifes to begin with.
        // As the level loads, if the user already has less than or equal to 0 lives, it will prompt to watch the add.
        if UserDefaults.standard.integer(forKey: "numberOfLifes") <= 0 {
            adScreen.zPosition = 10
            cameraNode.childNode(withName: "life_counter")?.zPosition = 11
            lifeCounter.zPosition = 11
            adScreen.run(SKAction.moveTo(y: cameraNode.position.y + 37, duration: 1))
            gameState = .paused
        }
        
        // Updating life counter label
        lifeCounter.text = String(numberOfLives)
        
        // Turning on Physics and checking for contact between sprites with a physical body.
        self.physicsWorld.contactDelegate = self
        
        // Camera itself
        self.camera = cameraNode
        
        // Adding the original projectile prediction line dots to hidden until the projectile is moved.
        projectilePredictionPoint1 = SKSpriteNode(imageNamed: "Circle_small")
        addChild(projectilePredictionPoint1)
        projectilePredictionPoint2 = SKSpriteNode(imageNamed: "Circle_small")
        addChild(projectilePredictionPoint2)
        projectilePredictionPoint3 = SKSpriteNode(imageNamed: "Circle_small")
        addChild(projectilePredictionPoint3)
        projectilePredictionPoint4 = SKSpriteNode(imageNamed: "Circle_small")
        addChild(projectilePredictionPoint4)
        projectilePredictionPoint5 = SKSpriteNode(imageNamed: "Circle_small")
        addChild(projectilePredictionPoint5)
        
        projectilePredictionPoint1.isHidden = true
        projectilePredictionPoint2.isHidden = true
        projectilePredictionPoint3.isHidden = true
        projectilePredictionPoint4.isHidden = true
        projectilePredictionPoint5.isHidden = true
        
        // Adding functions to buttons.
        
        // Button to go to the main Menu
        mainMenuButton.selectedHandler = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view else {
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
        
        // Button to start watching the add.
        watchAd.selectedHandler = {
            print("Ad button pressed")
            print("reward video is: ", GADRewardBasedVideoAd.sharedInstance().isReady)
//            if GADRewardBasedVideoAd.sharedInstance().isReady == true {
                print("adbutton returns true")
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: (self.view?.window?.rootViewController)!)
//            }
        }
        
        // Go to Level select Button.
        levelSelectButton.selectedHandler = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view else {
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
        
        // Restart the level.
        resetButton.selectedHandler = {
            guard let scene = GameScene.level(self.currentLevel) else {
                print("Level 1 is missing?")
                return
            }
            scene.currentLevel = self.currentLevel
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
        // Go to the next Level.
        nextLevelButton.selectedHandler = {
            self.lastLevel = UserDefaults.standard.integer(forKey: "checkpoint") + 1
            UserDefaults.standard.set(self.currentLevel + 1, forKey: "currentLevel")
            UserDefaults.standard.synchronize()
            print("current level is ", UserDefaults.standard.integer(forKey: "currentLevel"))
            guard let scene = GameScene.level(UserDefaults.standard.integer(forKey: "currentLevel")) else {
                print("Level 1 is missing?")
                return
            }
            scene.lastLevel = self.lastLevel
            scene.currentLevel = self.currentLevel
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
        // Open the in game pause menu.
        inGameMenu.selectedHandler = {[unowned self] in
//            if self.gameState == .playing {
                self.physicsWorld.speed = 0
                self.menus.position.x = self.cameraNode.position.x
                self.menus.position.y = self.cameraNode.position.y - 25
                self.winMenu.position.y -= 200
                self.gameOverSign.position.y -= 200
                self.nextLevelButton.position.y -= 200
                
                
                self.inGameMenu.isHidden = true
                self.gameState = .paused
//            }
        }
        
        // Resume the game after it was paused.
        resumeButton.selectedHandler = {
            self.physicsWorld.speed = 0.5
            
            self.winMenu.position.y += 200
            self.nextLevelButton.position.y += 200
            self.gameOverSign.position.y += 200
            self.menus.position.y = self.cameraNode.position.y - 700
            
            self.gameState = .playing
            self.inGameMenu.isHidden = false
        }
        setupSlingshot()
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /*
            Called before each frame is rendered
        */
        
        // Give the camera a starting point
        func cameraToCenter() {
            let cameraReset = SKAction.move(to: CGPoint(x: 239, y:camera!.position.y), duration: 1.5)
            let cameraDelay = SKAction.wait(forDuration: 0.5)
            let cameraSequence = SKAction.sequence([cameraDelay,cameraReset])
            cameraNode.run(cameraSequence)
            cameraTarget = nil
        }
        // MARK: End of Chapter 1
        if levelWithMovingCameraFromAtoB.contains(UserDefaults.standard.integer(forKey: "currentLevel")) || levelWithMovableCameraInXAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) || levelWithMovableCameraInYAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            background.position.x = cameraNode.position.x
        }
        // MARK: End of chapter 2
        if levelWithMovableCameraInXAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) || levelWithMovableCameraInYAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            cameraMove()
        }
        
        /*
            Weird way I set the game over. It calls game over ones the background image has slid all the way down.
        */
        if physicsWorld.speed == 1 {
            if background.position.y > -1000 && gameState == .playing{
                background.position.y -= 5
                timerBar -= 0.0022
            } else if gameState == .playing{
                gameState = .gameOver
            }
        } else {
            if background.position.y > -1000 && gameState == .playing{
                background.position.y -= physicsWorld.speed * 5
                timerBar -= physicsWorld.speed * 0.0022
            } else if gameState == .playing{
                gameState = .gameOver
            }
        }
        
        // Increases the timers.
        gameStart += fixedDelta
        timer += fixedDelta
    }
    
    // Radians to degrees function. just because I like it more.
    func radToDeg(_ radian: Double) -> CGFloat {
        return CGFloat(radian * 180.0 / .pi)
    }
    
    /// Function to check which portal is being touched.
    /**
     Steps:
        * Sets the first touch location
        * Checks if the node in that location is a portal
        * if it is, it will set that portal to be draggable
     */
    /// - parameter touchLocation: Just the user's current touch location.
    func selectPortalForTouch(_ touchLocation : CGPoint) {
        // TODO: Maybe update the code to return the current touched portal.
        let touchedNode = self.atPoint(touchLocation)
        if touchedNode is SKSpriteNode {
            
            // TODO: Check if conditional is needed.
            if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                if touchedNode == bluePortalDrag || touchedNode == portal1{
                    portal1.position = touchLocation
                    currentMovingPortal = portal1
                    bluePortalDrag.texture = SKTexture(imageNamed: "Portal_drag_Empty")
                    bluePortalHasBeenPlaced = true
                }
                else if touchedNode == yellowPortalDrag || touchedNode == portal2{
                    portal2.position = touchLocation
                    currentMovingPortal = portal2
                    yellowPortalDrag.texture = SKTexture(imageNamed: "Portal_drag_Empty")
                    yellowPortalHasBeenPlaced = true
                }
            }
        }
    }
    
    // MARK: PROBABLY unused function
//    func boundLayerPos(_ aNewPosition : CGPoint) -> CGPoint {
//        let winSize = self.size
//        var retval = aNewPosition
//        retval.x = CGFloat(min(retval.x, 0))
//        retval.x = CGFloat(max(retval.x, -(background.size.width) + winSize.width))
//        retval.y = self.position.y
//
//        return retval
//    }
    
    /// Pan to move portal.
    func panForPortalTranslation(_ translation : CGPoint) {
        if gameState == .playing {
            if currentMovingPortal == portal1 {
                let position = portal1.position
                portal1.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            }
            else if currentMovingPortal == portal2 {
                let position = portal2.position
                portal2.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Making things draggable when touches begins on the node's location.
        // MARK: Draggable objects setup
        if gameState == .playing {
            if  levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                // When touches begins on a portal, that portal will become selected to later be dragged.
                let touch = touches.first!
                let positionInScene = touch.location(in: self)
                selectPortalForTouch(positionInScene)
            }
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                // Checking if the projectile is being dragged.
                if !projectileIsDragged && shouldStartDragging(touchLocation: touchLocation, threshold: Settings.Metrics.projectileTouchThreshold)  {
                    touchStartingPoint = touchLocation
                    touchCurrentPoint = touchLocation
                    projectileIsDragged = true
                    projectileFirstPosition = projectile.position
                    print("projectile first position: \(projectileFirstPosition)")
                }
            }
        }
    }
    
    /// Code that checks if the player has dragged the projectile far enough.
    func shouldStartDragging(touchLocation:CGPoint, threshold: CGFloat) -> Bool {
        let distance = fingerDistanceFromProjectileRestPosition(
            projectileRestPosition: Settings.Metrics.projectileRestPosition,
            fingerPosition: touchLocation
        )
        // True if distance is big enougn. False otherwise.
        return distance < Settings.Metrics.projectileRadius + threshold
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: Make this function more modular you stupid ass!
        if gameState == .playing {
            if projectileIsDragged {
                if let touch = touches.first {
                    let touchLocation = touch.location(in: self)
                    updateTheIndicators(touch: touch, touchLocation: touchLocation)
                }
                projectile.position = touchCurrentPoint
            }
            // If projectile hasn't been dragged but touches moved. Means they might be trying to move the camera or portal or (lost vortex)
            else {
                // MARK: Code to move the camera on X-Axis by panning
                if levelWithMovableCameraInXAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) && gameState == .playing && released == false {
                    // Calculates the distance between the start pan point and the current. Will Move camera by that difference as you pan.
                    let touch = touches.first
                    let location = touch?.location(in: self)
                    let previousLocation = touch?.previousLocation(in: self)
                    let targetX = cameraNode.position.x
                    let x = clamp(value: targetX, lower: 240, upper: rightBorder.position.x - 550)
                    cameraNode.position.x = x
                    let targetY = cameraNode.position.y
                    let y = clamp(value: targetY, lower: 128, upper: topBorder.position.y - 320)
                    cameraNode.position.y = y
                    camera?.position.x += ((location?.x)! - (previousLocation?.x)!) * -1
                    camera?.position.y += ((location?.y)! - (previousLocation?.y)!) * -1
                }
                if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")){
                    let touch = touches.first!
                    let positionInScene = touch.location(in: self)
                    let previousPosition = touch.previousLocation(in: self)
                    let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
                    
                    panForPortalTranslation(translation)
                }
            }
        }
    }
    
    /// Updates the indicator labels and prediction line on screen depending on projectile drag.
    func updateTheIndicators(touch : UITouch, touchLocation : CGPoint) {
        let distance = fingerDistanceFromProjectileRestPosition(projectileRestPosition: touchLocation, fingerPosition: touchStartingPoint)
        // Hypotenuse calculation for power
        // TODO: Figure out why you used "75" and "100" as units here.
        var power = ( distance / 75 ) * 100
        if power > 100 {
            power = 100
        }
        // Calculate change in vectors when dragging
        let vectorX = touchStartingPoint.x - touchCurrentPoint.x
        let vectorY = touchStartingPoint.y - touchCurrentPoint.y
        
        // Calculating hypotenuse by using tan(opposite / adjacent) or tan( y / x ) = h
        let angleRad = atan(vectorY / vectorX)
        
        // Swift works with radians, but I like degrees, so I convert them
        let angleDeg = radToDeg(Double(angleRad))
        
        // I know this looks weird, but angle will change, while angleDeg will need to stay the same.
        var angle = angleDeg
        
        /*
            Since I'm using triangles to calculate power, but the projectile can shoot anywhere in a circle.
         
            A triangle logic, can only work if the player is shooting in a degree between 0º-90º
            If the aims above 90º but not more than 180º, I will need to flip the tringle horizontally so that the height (y) of the triangle is opposite and the lenght (x) is adjacent for the formula to work.
        */
        var reverseAngle = angleDeg
        if touchCurrentPoint.x > touchStartingPoint.x {
            angle = angle + 180
            if touchCurrentPoint.y < touchStartingPoint.y {
            } else if touchCurrentPoint.y > touchStartingPoint.y {
            }
        } else if touchCurrentPoint.x < touchStartingPoint.x {
            if touchCurrentPoint.y > touchStartingPoint.y {
                angle = angle + 360
            }
        }
        
        // If the projectile has been dragged, pretty much.
        if angle > -1 {
            // It will update the labels.
            let intAngle: Int = Int(angle)
            powerLabel.text = "\(String(Int(power)))%"
            angleLabel.text = "\(String(describing: intAngle))°"
        }
        
        // Calculates the initial velocity at which the projectile is going to be released.
        // (meters / second)
        let initialVelocity = sqrt(pow((vectorX * Settings.Metrics.forceMultiplier) / 0.5, 2) + pow((vectorY * Settings.Metrics.forceMultiplier) / 0.5, 2))
        
        // TODO: Check if there's a need to convert insead of using angleRad variable.
        let angleRadians = angle * CGFloat(Double.pi) / 180
        
        // MARK: Money Making code
        /// Checkout the Description at: https://github.com/timomak/Swift-Projectile-Prediction-Trajectory
        /**
         This code will return the poistion of the projectile at any moment you want after release.
         Not factoring in if anything gets into the projectile's way.
         */
        /// - parameter initialPosition: (meters) Initial Position of the projectile.
        /// - parameter time: (seconds) How long from the moment it was released.
        /// - parameter angle1: (Degrees) The angle at which the projectile was released.
        /// - parameter gravity: (meters/seconds) The current gravity within the game.
        /// - parameter initialVelocity: (meters / seconds) Initial Velocity at which the projectile was released.
        func projectilePredictionPath (initialPosition: CGPoint, time: CGFloat, angle1: CGFloat, gravity: CGFloat = 9.8, initialVelocity: CGFloat) -> CGPoint {
            // Find the Y coordiate position.
            let YpointPosition = initialPosition.y + initialVelocity * time * sin(angle1) - (0.5 * gravity) * pow(time,2)
            // Find the X coordinate position.
            let XpointPosition = initialPosition.x + initialVelocity * time * cos(angle1)
            // Creates a (x, y) coordinate point.
            let predictionPoint = CGPoint(x: XpointPosition, y: YpointPosition)
            // Returns the coordinate (x, y) at a point in time.
            return predictionPoint
        }
        // Unhide the projectiles
        projectilePredictionPoint1.isHidden = false
        projectilePredictionPoint2.isHidden = false
        projectilePredictionPoint3.isHidden = false
        projectilePredictionPoint4.isHidden = false
        projectilePredictionPoint5.isHidden = false
        
        // Place the projectiles 0.3 seconds apart from each other.
        projectilePredictionPoint1.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 0.3, angle1: angleRadians, initialVelocity: initialVelocity)
        projectilePredictionPoint2.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 0.6, angle1: angleRadians, initialVelocity: initialVelocity)
        projectilePredictionPoint3.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 0.9, angle1: angleRadians, initialVelocity: initialVelocity)
        projectilePredictionPoint4.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 1.2, angle1: angleRadians, initialVelocity: initialVelocity)
        projectilePredictionPoint5.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 1.5, angle1: angleRadians, initialVelocity: initialVelocity)
        
        // TODO: Check how this code affect the game.
        if distance < Settings.Metrics.rLimit  {
            touchCurrentPoint = touchLocation
        } else {
            touchCurrentPoint = projectilePositionForFingerPosition(
                fingerPosition: touchLocation,
                projectileRestPosition: touchStartingPoint,
                rLimit: Settings.Metrics.rLimit
            )
        }
    }
    
    // What will happen once the projectile has been released.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .playing {
            if projectileIsDragged {
                // Setting the camera to follow the projectile once the ball is released.
                cameraTarget = projectile
                
                // Making sure the user won't be able to drag the projectile again after release
                projectileIsDragged = false
                
                // Calculates the distace between the drag start point and end point.
                let distance = fingerDistanceFromProjectileRestPosition(projectileRestPosition: touchCurrentPoint, fingerPosition: touchStartingPoint)
                
                // If that distance is large enough, it be released
                if distance > Settings.Metrics.projectileSnapLimit {
                    // Getting height and lenght vectors
                    let vectorX = touchStartingPoint.x - touchCurrentPoint.x
                    let vectorY = touchStartingPoint.y - touchCurrentPoint.y
                    
                    // Giving the projectile a physical body to be affected by the in game physics.
                    projectile.physicsBody = SKPhysicsBody(circleOfRadius: 15)
                    projectile.physicsBody?.categoryBitMask = 1
                    projectile.physicsBody?.contactTestBitMask = 6
                    projectile.physicsBody?.collisionBitMask = 9
                    physicsBody?.friction = 0.6
                    physicsBody?.mass = 0.5
                    
                    // Apply a force to launch the projectile.
                    projectile.physicsBody?.applyImpulse(
                        CGVector(
                            dx: vectorX * Settings.Metrics.forceMultiplier,
                            dy: vectorY * Settings.Metrics.forceMultiplier
                        )
                    )
                    
                    // Start the timer
                    trajectoryTimeOut = 0
                    
                    // Makes sure to record to avoid bugs with all these conditionals.
                    released = true
                    
                    // Play projectile release sound
                    let sound = SKAction.playSoundFileNamed("BallReleasedSound", waitForCompletion: false)
                    self.run(sound)
                    
                    // If it has portals, the game will be slightly in slow-motion
                    if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                        self.physicsWorld.speed = 0.37
                    } else {
                        self.physicsWorld.speed = 0.5
                    }
                    
                    // Dragging Portals made visible
                    if  levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                        bluePortalDrag.isHidden = false
                        yellowPortalDrag.isHidden = false
                    }
                } else {
                    // If the drag wasn't successful, the projectile doesn't get launched.
                    projectile.physicsBody = nil
                    projectile.position = Settings.Metrics.projectileRestPosition
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Physics contact delegate implementation.
        // Get references to the bodies involved in the collision.
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        // Get references to the physics body parent SKSpriteNode.
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        
        // Check if the node collision is with a portal.
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4{
            if contactA.categoryBitMask != 4{
                // If the contact was not the alien, it was probably the ball making contact with a portal. From portal1 to portal2.
                teleportBallA(node: nodeA)
                
                if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                    /*
                     If the level had draggable portals and they weren't place, it will be gameover.
                    */
                    if yellowPortalHasBeenPlaced == false {
                        gameState = .gameOver
                    }
                }
            }
            if contactB.categoryBitMask != 4 {
                // TODO: Clean this up. Repetetive code.
                // If the other physics body was a portal, do the same thing as above.
                teleportBallA(node: nodeB)
                if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                    if yellowPortalHasBeenPlaced == false {
                        gameState = .gameOver
                    }
                }
            }
        }
        // From portal2 to portal1.
        if contactA.categoryBitMask == 16 || contactB.categoryBitMask == 16{
            if contactA.categoryBitMask != 16{
                teleportBallB(node: nodeA)
            }
            if contactB.categoryBitMask != 16{
                teleportBallB(node: nodeB)
            }
        }
        // If the game state is either .playing or .paused, check if the ball made contact with the ground.
        if gameState != .gameOver && gameState != .won && released == true{
            if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8{
                // The ball made contact with the ground
                if contactA.categoryBitMask != 8{
                    removeBall(node: nodeA)
                }
                if contactB.categoryBitMask != 8{
                    removeBall(node: nodeB)
                }
                gameState = .gameOver
            }
        }
        
        // Check if either physics bodies was the alien. The categoty bitmask of the alien is 4.
        if contactA.categoryBitMask == 0 || contactB.categoryBitMask == 0 {
            if contactA.categoryBitMask == 0{
                
                // Animate Alien Explosion and remove alien.
                animateExplosion(node: nodeA)
                alien.removeFromParent()
                
                // MARK: Update winning gamestate.
                if winCount == 1 && gameState != .gameOver{
                    gameState = .won
                    winCount += 1
                }
                
            }
            if contactB.categoryBitMask == 0 {
                // TODO: Clean up repetetive code.
                animateExplosion(node: nodeB)
                alien.removeFromParent()
                if winCount == 1 && gameState != .gameOver{
                    gameState = .won
                    winCount += 1
                }
                
            }
        }
        
        // TODO: Check if this code is needed. The code above can also just delete the alien.
        if contactA.categoryBitMask == 2 && contactB.categoryBitMask == 1 {
            /* Was the collision more than a gentle nudge? */
            
            /* Kill Alien */
            if contactA.categoryBitMask == 2 {
                removeAlien(node: nodeA)
            }
            if contactB.categoryBitMask == 2 {
                removeAlien(node: nodeB)
            }
        }
        if contactB.categoryBitMask == 2 && contactA.categoryBitMask == 1 {
            /* Kill Alien */
            if contactA.categoryBitMask == 2 {
                removeAlien(node: nodeA)
            }
            if contactB.categoryBitMask == 2 {
                removeAlien(node: nodeB)
            }
        }
        
    }
    
    /// Teleport ball from portalA to portalB
    func teleportBallB(node: SKNode) {
        let sound = SKAction.playSoundFileNamed("Portal_Sound", waitForCompletion: false)
        self.run(sound)
        let moveBall = SKAction.move(to: portalB.position, duration:0)
        node.run(moveBall)
        if levelWithMovingCameraFromAtoB.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            cameraNode.position.x = 1764.218
            cameraNode.position.y = 123.14
        }
    }
    
    /// Teleport ball from portal1 to portal2
    func teleportBallA(node: SKNode) {
        let sound = SKAction.playSoundFileNamed("Portal_Sound", waitForCompletion: false)
        self.run(sound)
        let moveBall = SKAction.move(to: portal2.position, duration:0)
        node.run(moveBall)
        if levelWithMovingCameraFromAtoB.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            cameraNode.position.x = 1764.218
            cameraNode.position.y = 123.14
        }
    }
    
    /// Animate alien explosion death
    func animateExplosion(node: SKNode) {
        node.run(SKAction(named: "Boom")!)
        // MARK: Sound Effect
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let sound = SKAction.playSoundFileNamed("granade", waitForCompletion: false)
        self.run(sound)
        
    }
    
    /// Remove the ball from the game once it has hit the alien.
    func removeBall(node: SKNode) {
        projectile.physicsBody?.angularDamping = 1
        projectile.physicsBody?.allowsRotation = false
        projectile.physicsBody?.angularVelocity = 0
        projectile.physicsBody?.pinned = true
        let removingBall = SKAction.run({
            /* Remove seal node from scene */
            self.animateExplosion(node: node)
            // node.removeFromParent()
        })
        run(removingBall)
    }
    
    /// Remove Alien
    func removeAlien(node: SKNode) {
        
        /* Create our alien death action */
        let alienDeath = SKAction.run({
            /* Remove alien node from scene */
            node.removeFromParent()
            
        })
        
        // TODO: Check if this code is necessary or repetetive.
        // MARK: Change game state to won
        if winCount == 1 && gameState != .gameOver{
            gameState = .won
            winCount += 1
        }
        // Start the animation.
        self.run(alienDeath)
    }
    
    /// Slingshot initial force or velocity calculation
    func fingerDistanceFromProjectileRestPosition(projectileRestPosition: CGPoint, fingerPosition: CGPoint) -> CGFloat {
        return sqrt(pow(projectileRestPosition.x - fingerPosition.x,2) + pow(projectileRestPosition.y - fingerPosition.y,2))
    }
    
    /// Return the projectile to its initial position (i think).
    func projectilePositionForFingerPosition(fingerPosition: CGPoint, projectileRestPosition:CGPoint, rLimit:CGFloat) -> CGPoint {
        let θ = atan2(fingerPosition.x - projectileRestPosition.x, fingerPosition.y - projectileRestPosition.y)
        let cX = sin(θ) * rLimit
        let cY = cos(θ) * rLimit
        return CGPoint(x: cX + projectileRestPosition.x, y: cY + projectileRestPosition.y)
    }
    
    /// Code that will put the slingshot image and projectile in place.
    func setupSlingshot() {
        /*
         The Slingshot image is split into 2. The trunk and left arm, and the right arm.
         Hasn't been useful yet, but it will make it easier when updating the sprites in the future.
        */
        let slingshot_1 = SKSpriteNode(imageNamed: "slingshot_1")
        slingshot_1.position = CGPoint(x: -100, y: -10)
        addChild(slingshot_1)
        slingshot_1.isHidden = false
        slingshot_1.zPosition = 2
        
        projectile = spear()
        projectile.zPosition = 3
        projectile.position = Settings.Metrics.projectileRestPosition
        addChild(projectile)
        
        let slingshot_2 = SKSpriteNode(imageNamed: "slingshot_2")
        slingshot_2.position = CGPoint(x: -100, y: -10)
        addChild(slingshot_2)
        slingshot_2.isHidden = false
        slingshot_2.zPosition = 2
        
        
    }
    
    // MARK: Currently unused function. For emitters on stars later.
//    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            completion()
//        }
//    }
    
    /// Function to run the game over stuff.
    /**
     This funciton will:
     * 33% chance to start a fullscreen AD
     * Update Camera position
     * Update life count
     * Bring up the menu
     */
    func GameOver() {
        // TODO: Check if this code is breaking the game rn
        // I set a 33% chance of getting an ad when you lose.
        let possibilityToGetAd = arc4random_uniform(2)
        print("Possibility to get ad: \(possibilityToGetAd)")
        if possibilityToGetAd == 1 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAndShow"), object: nil)
        }
        
        // Remove the projectile from being the camera's target.
        cameraTarget = nil
        // Rest camera position to center.
        cameraNode.position.y = 123.14
        print("game Over is called")
        
        // Update the life counter in memory.
        let numberOfLifes = UserDefaults.standard.integer(forKey: "numberOfLifes") - 1
        UserDefaults.standard.set(numberOfLifes, forKey: "numberOfLifes")
        UserDefaults.standard.synchronize()
        
        // TODO: Check what this does.
        if numberOfLifes == 0 {
            watchedAdGiveLives = true
        }
        
        // When the GUI is pulled up, show 0 stars.
        starOne.alpha = 0
        starTwo.alpha = 0
        starThree.alpha = 0
        
        // Center menus with the camera
        menus.position.x = cameraNode.position.x
        
        // Animations for the menu.
        let moveMenu = SKAction.move(to: CGPoint(x: menus.position.x, y: 180 ), duration: 1)
        let moveDelay = SKAction.wait(forDuration: 0.5)
        let menuSequence = SKAction.sequence([moveDelay,moveMenu])
        
        menus.isPaused = false
        
        menus.run(menuSequence)
//        menus.position.y = 180
        pauseMenu.position.y = -200
        resumeButton.position.y = -200
        nextLevelButton.position.y = -200

        // Pause button.
        inGameMenu.isHidden = true
        
    }
    
    // MARK: Code for future star emitter implemenation.
//    func starEmitterNode(node: SKNode) {
//
//        node.addChild(starEmitter)
//
//    }
    
    /// Function that will run the Winning stuff.
    /**
     This function will:
     * Reset camera position.
     * Run Menu animations to bring them in-view
     * Give a number of starts correlating to the duration of the game.
     * Update the checkpoint if it's the first time you surpass the level.
     * Save the number of stars received on the current level.
    */
    func win() {
        // Reset Camera
        cameraTarget = nil
        cameraNode.position.y = 123.14
        
        // Hide stars for later animation
        starOne.alpha = 0
        starTwo.alpha = 0
        starThree.alpha = 0
        
        // Bring the menus in view.
        menus.position.x = cameraNode.position.x
        
        // MARK: Star emitter code
        
//        let starEmitterPath = Bundle.main.path(forResource: "starEmitterScene", ofType: "sks")
//        let starEmitter = SKReferenceNode (url: URL (fileURLWithPath: starEmitterPath!))
//        let moveMenu5 = SKAction.move(to: starOne.position, duration: 1)
//        let moveDelay5 = SKAction.wait(forDuration: 0.5)
//        let starActionSequence = SKAction.sequence([moveDelay5,moveMenu5])
//        starEmitter.run(starActionSequence)
        
        // Animations
        let moveMenu = SKAction.move(to: CGPoint(x: menus.position.x, y: 180 ), duration: 1)
        let moveDelay = SKAction.wait(forDuration: 0.5)
        let menuSequence = SKAction.sequence([moveDelay,moveMenu])
        
        menus.isPaused = false
        
        menus.run(menuSequence)
        pauseMenu.position.y = -200
        resumeButton.position.y = -200
        gameOverSign.position.y -= 200
        
        var stars = 0
        
        inGameMenu.isHidden = true
        
        // Check the score depending on how much the screen has moved.
        if background.position.y > -1000 {
            stars = 1
            if background.position.y > -232{
                stars = 2
                if background.position.y > 538 {
                    stars = 3
                }
            }
        }
        
        // Animate stars
        print("The number of stars in level.\(currentLevel) is: \(stars)")
        let fadeStar = SKAction.fadeAlpha(by: 1, duration: 0.6)
        let fadeDelay = SKAction.wait(forDuration: 1.5)
        let starSequence = SKAction.sequence([fadeDelay,fadeStar])
        
        let fadeStar2 = SKAction.fadeAlpha(by: 1, duration: 0.6)
        let fadeDelay2 = SKAction.wait(forDuration: 2.1)
        let starSequence2 = SKAction.sequence([fadeDelay2,fadeStar2])
        
        let fadeStar3 = SKAction.fadeAlpha(by: 1, duration: 0.6)
        let fadeDelay3 = SKAction.wait(forDuration: 2.7)
        let starSequence3 = SKAction.sequence([fadeDelay3,fadeStar3])
        
        let starEmitterPath = Bundle.main.path(forResource: "starEmitterScene", ofType: "sks")
        let starEmitter1 = SKReferenceNode (url: URL (fileURLWithPath: starEmitterPath!))
        let starEmitter2 = SKReferenceNode (url: URL (fileURLWithPath: starEmitterPath!))
        let starEmitter3 = SKReferenceNode (url: URL (fileURLWithPath: starEmitterPath!))
        
        // MARK: Also for future implementaiton of emitters on stars.
        if stars == 1 {
            starOne.run(starSequence)
//            delayWithSeconds(3.3) {
//                starEmitter1.position = self.starOne.position
//                self.addChild(starEmitter1)
//            }

        } else if stars == 2 {
            starOne.run(starSequence)
            starTwo.run(starSequence2)
//            delayWithSeconds(3.3) {
//                starEmitter1.position = self.starOne.position
//                self.addChild(starEmitter1)
//                self.delayWithSeconds(3.3) {
//                    starEmitter2.position = self.starTwo.position
//                    self.addChild(starEmitter2)
//                }
//            }
            
        } else if stars == 3 {
            starOne.run(starSequence)
            starTwo.run(starSequence2)
            starThree.run(starSequence3)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                starEmitter1.position = self.starOne.position
                self.addChild(starEmitter1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    starEmitter2.position = self.starTwo.position
                    self.addChild(starEmitter2)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        starEmitter3.position = self.starThree.position
                        self.addChild(starEmitter3)
                    })
                })
            })
        }
        
        // TODO: Check what this is for.
        if UserDefaults.standard.integer(forKey: "checkpoint") < 2 {
            lastLevel = 2
            UserDefaults.standard.set(lastLevel, forKey: "checkpoint")
            UserDefaults.standard.synchronize()
            print("Checkpoint set to two: ", UserDefaults.standard.integer(forKey: "checkpoint"))
        }
        if UserDefaults.standard.integer(forKey: "checkpoint") > 1{
            if UserDefaults.standard.integer(forKey: "currentLevel") > UserDefaults.standard.integer(forKey: "checkpoint") {
                UserDefaults.standard.set(currentLevel, forKey: "checkpoint")
                UserDefaults.standard.synchronize()
                print("At won checkpoint is: ",UserDefaults.standard.integer(forKey: "checkpoint"))
            }
        }
        // TODO: Figure out how this part works
        let name = String(currentLevel)
        if stars > UserDefaults.standard.integer(forKey: name){
            levelScore[currentLevel] = stars
            UserDefaults.standard.set(levelScore[currentLevel], forKey: name)
            UserDefaults.standard.synchronize()
        }
    }
}
