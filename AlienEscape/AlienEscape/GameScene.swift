//
//  GameScene.swift
//  AlienEscape
//
//  Created by timofey makhlay on 6/30/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

// print(#file, #function, #line)
import SpriteKit
import GoogleMobileAds
import AudioToolbox

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

extension CGVector {
    public func length() -> CGFloat {
        return CGFloat(sqrt(dx*dx + dy*dy))
    }
}

enum GameState {
    case paused, playing, gameOver, won
}

class GameScene: SKScene, SKPhysicsContactDelegate, GADRewardBasedVideoAdDelegate{
    
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
    var GUI: SKReferenceNode!
    var menus: guiCode!
    
    var starOne :SKSpriteNode!
    var starTwo :SKSpriteNode!
    var starThree :SKSpriteNode!
    var winMenu: SKSpriteNode!
    var nextLevelButton: MSButtonNode!
    var pauseMenu: SKSpriteNode!
    var resetButton: MSButtonNode!
    var resumeButton: MSButtonNode!
    var levelSelectButton: MSButtonNode!
    var gameOverSign: SKSpriteNode!
    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var gameStart: CFTimeInterval = 0
    var timer: CFTimeInterval = 0
    var trajectoryTimeOut: CFTimeInterval = 1
    
    var background: SKSpriteNode!
    var portal1: SKSpriteNode!
    var portal2: SKSpriteNode!
    var portalA: SKSpriteNode!
    var portalB: SKSpriteNode!
    
    var alien: SKSpriteNode!
    var inGameMenu: MSButtonNode!
    var projectile: spear!
    
    //Touch dragging vars
    var projectileIsDragged = false
    var touchCurrentPoint: CGPoint!
    var touchStartingPoint: CGPoint!
    
    // Setting up camera
    var cameraNode:SKCameraNode!
    var cameraTarget:SKSpriteNode!
    
    var currentLevel = 1
    
    var levelScore = [ 0: 0]
    
    var lastLevel = 1
    var winCount = 1
    
    var lifeCounter: SKLabelNode!
    
    var released = false
    
    var projectileBox: Projectile!
    
    var bluePortalDrag: SKSpriteNode!
    var yellowPortalDrag: SKSpriteNode!
    var currentMovingPortal = SKSpriteNode()
    var bluePortalHasBeenPlaced = false
    var yellowPortalHasBeenPlaced = false
    
    
    var levelWithExtraPortals = [6]
    var levelWithDraggablePortals = [3]
    var levelWithMovingCameraFromAtoB = [4]
    var levelWithMovableCameraInXAxis = [5,6]
    var levelWithMovableCameraInYAxis = [5]
    
    var topBorder: SKSpriteNode!
    var rightBorder: SKSpriteNode!
    
    var projectileFirstPosition = CGPoint()
    
    var labelReferenceNode: SKReferenceNode!
    var labelIndicators: Indicators!
    var powerLabel: SKLabelNode!
    var angleLabel: SKLabelNode!
    
    private var adPopUp: SKReferenceNode!
    private var adScreen: AdPage!
    private var mainMenuButton: MSButtonNode!
    private var watchAd: MSButtonNode!
    
    var projectilePredictionPoint1: SKSpriteNode!
    var projectilePredictionPoint2: SKSpriteNode!
    var projectilePredictionPoint3: SKSpriteNode!
    var projectilePredictionPoint4: SKSpriteNode!
    var projectilePredictionPoint5: SKSpriteNode!
    
    var numberOfLives = 0
    
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
    
    // MARK: Loading Levels
    class func level(_ currentLevel: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(currentLevel)") else {
            return nil
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        
        print("number of lifes is: \(numberOfLives)")
        print("number of lifes is: \(UserDefaults.standard.integer(forKey: "numberOfLifes"))")
    }
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        numberOfLives = UserDefaults.standard.integer(forKey: "numberOfLifes") + 30
        UserDefaults.standard.set(numberOfLives, forKey: "numberOfLifes")
        UserDefaults.standard.synchronize()
        adScreen.run(SKAction.moveTo(y: 1600, duration: 1))
        lifeCounter.text = String(numberOfLives)
        gameState = .playing
        let request = GADRequest()
        GADRewardBasedVideoAd.sharedInstance().load(request,
                                                    withAdUnitID: "ca-app-pub-6454574712655895/9250778455")
        print("number of lifes after ad is: \(UserDefaults.standard.integer(forKey: "numberOfLifes"))")
    }
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        numberOfLives = UserDefaults.standard.integer(forKey: "numberOfLifes") + 30
        UserDefaults.standard.set(numberOfLives, forKey: "numberOfLifes")
        UserDefaults.standard.synchronize()
        adScreen.run(SKAction.moveTo(y: 1600, duration: 1))
        lifeCounter.text = String(numberOfLives)
        gameState = .playing
        let request = GADRequest()
        GADRewardBasedVideoAd.sharedInstance().load(request,
                                                    withAdUnitID: "ca-app-pub-6454574712655895/9250778455")
        print("number of lifes after ad is: \(UserDefaults.standard.integer(forKey: "numberOfLifes"))")
    }
    
    override func didMove(to view: SKView) {
        currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        alien = childNode(withName: "//alien") as! SKSpriteNode
        
        if UserDefaults.standard.object(forKey: "currentAlien") as! String ==  "Robot_Alien" {
            alien.size = CGSize(width: 255, height: 430)
        }
        
        alien.run(SKAction(named: UserDefaults.standard.object(forKey: "currentAlien") as! String)!)
        inGameMenu = childNode(withName: "//inGameMenu") as! MSButtonNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        
        portal1 = childNode(withName: "portal_1") as! SKSpriteNode
        portal2 = childNode(withName: "portal_2") as! SKSpriteNode
        
        // MARK: SK Reference link
        labelReferenceNode = SKReferenceNode(fileNamed: "Indicator")
        labelReferenceNode.physicsBody = nil
        self.addChild(labelReferenceNode!)
        
        labelIndicators = labelReferenceNode.childNode(withName: "labelIndicators") as! Indicators
        angleLabel = labelIndicators.angleIndicator!
        powerLabel = labelIndicators.powerIndicator!
        labelIndicators.position = CGPoint(x: 40, y: 20)
        
        // MARK: GUI Setup
        GUI = SKReferenceNode(fileNamed: "GUI_Menus")
        GUI.physicsBody = nil
        self.addChild(GUI!)
        
        menus = GUI.childNode(withName: "parentGUI") as! guiCode
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
        
        menus.position = CGPoint(x: cameraNode.position.x, y: -446.994)
        winMenu.childNode(withName: "cameraNode")
        
        // MARK: Ad popup
        GADRewardBasedVideoAd.sharedInstance().delegate = (self as GADRewardBasedVideoAdDelegate)
        adPopUp = SKReferenceNode(fileNamed: "adPage")
        adPopUp.physicsBody = nil
        self.addChild(adPopUp!)
        adScreen = adPopUp.childNode(withName: "adScreen") as! AdPage
        mainMenuButton = adScreen.mainMenuButton2!
        watchAd = adScreen.watchAd!
        
        adScreen.position = CGPoint(x: cameraNode.position.x, y: 1600)
        
        // MARK: Extra Portals
        if levelWithExtraPortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            portalA = childNode(withName: "portal_A") as! SKSpriteNode
            portalB = childNode(withName: "portal_B") as! SKSpriteNode
        }
        
        // MARK: Draggable Portals
        if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            
            bluePortalDrag = childNode(withName: "//bluePortalDrag") as! SKSpriteNode
            yellowPortalDrag = childNode(withName: "//yellowPortalDrag") as! SKSpriteNode
            
            bluePortalDrag.isHidden = true
            yellowPortalDrag.isHidden = true
        }
        
        // MARK: Larger Levels Borders
        if levelWithMovableCameraInXAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) || levelWithMovableCameraInYAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
            topBorder = childNode(withName: "topBorder") as! SKSpriteNode
            rightBorder = childNode(withName: "rightBorder") as! SKSpriteNode
        }
        
        background = childNode(withName: "background") as! SKSpriteNode
        lifeCounter = childNode(withName: "//lifeCounter") as! SKLabelNode
        numberOfLives = UserDefaults.standard.integer(forKey: "numberOfLifes")
        
        if UserDefaults.standard.integer(forKey: "numberOfLifes") <= 0 {
            adScreen.zPosition = 10
            cameraNode.childNode(withName: "life_counter")?.zPosition = 11
            lifeCounter.zPosition = 11
            adScreen.run(SKAction.moveTo(y: cameraNode.position.y + 37, duration: 1))
            gameState = .paused
        }
        lifeCounter.text = String(numberOfLives)
        
        self.physicsWorld.contactDelegate = self
        
        self.camera = cameraNode
        
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
        
        mainMenuButton.selectedHandler = {
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
        
        watchAd.selectedHandler = {
            if GADRewardBasedVideoAd.sharedInstance().isReady == true {
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: (self.view?.window?.rootViewController)!)
            }
        }
        
        levelSelectButton.selectedHandler = {
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
        
        resetButton.selectedHandler = {
            guard let scene = GameScene.level(self.currentLevel) else {
                print("Level 1 is missing?")
                return
            }
            scene.currentLevel = self.currentLevel
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
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
        
        inGameMenu.selectedHandler = {[unowned self] in
            if self.gameState == .playing {
                self.physicsWorld.speed = 0
                self.menus.position.x = self.cameraNode.position.x
                self.menus.position.y = self.cameraNode.position.y - 25
                self.winMenu.position.y -= 200
                self.gameOverSign.position.y -= 200
                self.nextLevelButton.position.y -= 200
                
                
                self.inGameMenu.isHidden = true
                self.gameState = .paused
            }
        }
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
        /* Called before each frame is rendered */
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
        if physicsWorld.speed == 1 {
            if background.position.y > -1000 && gameState == .playing{
                background.position.y -= 5
            } else if gameState == .playing{
                gameState = .gameOver
            }
        } else {
            if background.position.y > -1000 && gameState == .playing{
                background.position.y -= physicsWorld.speed * 5
            } else if gameState == .playing{
                gameState = .gameOver
            }
        }
        gameStart += fixedDelta
        timer += fixedDelta
    }
    
    func radToDeg(_ radian: Double) -> CGFloat {
        return CGFloat(radian * 180.0 / M_PI)
    }
    
    func selectPortalForTouch(_ touchLocation : CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        if touchedNode is SKSpriteNode {
            if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                if touchedNode == bluePortalDrag || touchedNode == portal1{
                    portal1.position = touchLocation
                    currentMovingPortal = portal1
                    bluePortalDrag.texture = SKTexture(imageNamed: "Portal_drag_Empty")
                    bluePortalHasBeenPlaced = true
                }
                if touchedNode == yellowPortalDrag || touchedNode == portal2{
                    portal2.position = touchLocation
                    currentMovingPortal = portal2
                    yellowPortalDrag.texture = SKTexture(imageNamed: "Portal_drag_Empty")
                    yellowPortalHasBeenPlaced = true
                }
            }
        }
    }
    func boundLayerPos(_ aNewPosition : CGPoint) -> CGPoint {
        let winSize = self.size
        var retval = aNewPosition
        retval.x = CGFloat(min(retval.x, 0))
        retval.x = CGFloat(max(retval.x, -(background.size.width) + winSize.width))
        retval.y = self.position.y
        
        return retval
    }
    func panForTranslation(_ translation : CGPoint) {
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
        // MARK: Draggable objects setup
        if gameState == .playing {
            if  levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                let touch = touches.first!
                let positionInScene = touch.location(in: self)
                selectPortalForTouch(positionInScene)
            }
        }
        if gameState == .playing {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
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
    
    func shouldStartDragging(touchLocation:CGPoint, threshold: CGFloat) -> Bool {
        let distance = fingerDistanceFromProjectileRestPosition(
            projectileRestPosition: Settings.Metrics.projectileRestPosition,
            fingerPosition: touchLocation
        )
        return distance < Settings.Metrics.projectileRadius + threshold
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .playing {
            if projectileIsDragged {
                if let touch = touches.first {
                    let touchLocation = touch.location(in: self)
                    let distance = fingerDistanceFromProjectileRestPosition(projectileRestPosition: touchLocation, fingerPosition: touchStartingPoint)
                    // TODO: Highpotenuese calculation for power
                    var power = (distance/75) * 100
                    if power > 100 {
                        power = 100
                    }
                    let vectorX = touchStartingPoint.x - touchCurrentPoint.x
                    let vectorY = touchStartingPoint.y - touchCurrentPoint.y
                    
                    let angleRad = atan(vectorY / vectorX)
                    let angleDeg = radToDeg(Double(angleRad))
                    var angle = angleDeg
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
                    
                    if angle > -1 {
                        let intAngle: Int = Int(angle)
                        powerLabel.text = "\(String(Int(power)))%"
                        angleLabel.text = "\(String(describing: intAngle))°"
                    }
                    
                    let initialVelocity = sqrt(pow((vectorX * Settings.Metrics.forceMultiplier) / 0.5, 2) + pow((vectorY * Settings.Metrics.forceMultiplier) / 0.5, 2))
                    let angleRadians = angle * CGFloat(M_PI) / 180
                    
                    func projectilePredictionPath (initialPosition: CGPoint, time: CGFloat, angle1: CGFloat /*initial Velocity and Gravity*/) -> CGPoint {
                        let YpointPosition = initialPosition.y + initialVelocity * time * sin(angle1) - 4.9 * pow(time,2)
                        let XpointPosition = initialPosition.x + initialVelocity * time * cos(angle1)
                        let predictionPoint = CGPoint(x: XpointPosition, y: YpointPosition)
                        return predictionPoint
                        
                    }
                    projectilePredictionPoint1.isHidden = false
                    projectilePredictionPoint2.isHidden = false
                    projectilePredictionPoint3.isHidden = false
                    projectilePredictionPoint4.isHidden = false
                    projectilePredictionPoint5.isHidden = false
                    projectilePredictionPoint1.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 0.3, angle1: angleRadians)
                    projectilePredictionPoint2.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 0.6, angle1: angleRadians)
                    projectilePredictionPoint3.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 0.9, angle1: angleRadians)
                    projectilePredictionPoint4.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 1.2, angle1: angleRadians)
                    projectilePredictionPoint5.position = projectilePredictionPath(initialPosition: touchStartingPoint, time: 1.5, angle1: angleRadians)
                    
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
                projectile.position = touchCurrentPoint
            } else {
                // MARK: Code to move the camera on X-Axis
                if levelWithMovableCameraInXAxis.contains(UserDefaults.standard.integer(forKey: "currentLevel")) && gameState == .playing && released == false {
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
                    
                    panForTranslation(translation)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .playing {
            if projectileIsDragged {
                cameraTarget = projectile
                projectileIsDragged = false
                let distance = fingerDistanceFromProjectileRestPosition(projectileRestPosition: touchCurrentPoint, fingerPosition: touchStartingPoint)
                if distance > Settings.Metrics.projectileSnapLimit {
                    let vectorX = touchStartingPoint.x - touchCurrentPoint.x
                    let vectorY = touchStartingPoint.y - touchCurrentPoint.y
                    projectile.physicsBody = SKPhysicsBody(circleOfRadius: 15)
                    projectile.physicsBody?.categoryBitMask = 1
                    projectile.physicsBody?.contactTestBitMask = 6
                    projectile.physicsBody?.collisionBitMask = 9
                    physicsBody?.friction = 0.6
                    physicsBody?.mass = 0.5
                    projectile.physicsBody?.applyImpulse(
                        CGVector(
                            dx: vectorX * Settings.Metrics.forceMultiplier,
                            dy: vectorY * Settings.Metrics.forceMultiplier
                        )
                    )
                    trajectoryTimeOut = 0
                    released = true
                    let sound = SKAction.playSoundFileNamed("BallReleasedSound", waitForCompletion: false)
                    self.run(sound)
                    if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                        self.physicsWorld.speed = 0.37
                    } else {
                        self.physicsWorld.speed = 0.5
                    }
                    
                    // MARK: Dragging Portals made visible
                    if  levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                        bluePortalDrag.isHidden = false
                        yellowPortalDrag.isHidden = false
                    }
                } else {
                    projectile.physicsBody = nil
                    projectile.position = Settings.Metrics.projectileRestPosition
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        /* Get references to the physics body parent SKSpriteNode */
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        /* Check if either physics bodies was a seal */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4{
            if contactA.categoryBitMask != 4{
                teleportBallA(node: nodeA)
                if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                    if yellowPortalHasBeenPlaced == false {
                        gameState = .gameOver
                    }
                }
            }
            if contactB.categoryBitMask != 4{
                teleportBallA(node: nodeB)
                if levelWithDraggablePortals.contains(UserDefaults.standard.integer(forKey: "currentLevel")) {
                    if yellowPortalHasBeenPlaced == false {
                        gameState = .gameOver
                    }
                }
            }
        }
        if contactA.categoryBitMask == 16 || contactB.categoryBitMask == 16{
            if contactA.categoryBitMask != 16{
                teleportBallB(node: nodeA)
            }
            if contactB.categoryBitMask != 16{
                teleportBallB(node: nodeB)
            }
        }
        if gameState != .gameOver && gameState != .won && released == true{
            if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8{
                print("there was contact with the ground")
                if contactA.categoryBitMask != 8{
                    removeBall(node: nodeA)
                }
                if contactB.categoryBitMask != 8{
                    removeBall(node: nodeB)
                }
                gameState = .gameOver
            }
        }
        
        if contactA.categoryBitMask == 0 || contactB.categoryBitMask == 0 {
            if contactA.categoryBitMask == 0{
                animateExplosion(node: nodeA)
                alien.removeFromParent()
                if winCount == 1 && gameState != .gameOver{
                    gameState = .won
                    winCount += 1
                }
                
            }
            if contactB.categoryBitMask == 0{
                animateExplosion(node: nodeB)
                alien.removeFromParent()
                if winCount == 1 && gameState != .gameOver{
                    gameState = .won
                    winCount += 1
                }
                
            }
        }
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
    
    func animateExplosion(node: SKNode) {
        node.run(SKAction(named: "Boom")!)
        // MARK: Sound Effect
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let sound = SKAction.playSoundFileNamed("granade", waitForCompletion: false)
        self.run(sound)
        
    }
    
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
    
    // MARK: Remove Alien
    func removeAlien(node: SKNode) {
        
        /* Create our hero death action */
        let alienDeath = SKAction.run({
            /* Remove seal node from scene */
            node.removeFromParent()
            
        })
        if winCount == 1 && gameState != .gameOver{
            gameState = .won
            winCount += 1
        }
        self.run(alienDeath)
    }
    
    // MARK: SlingShot
    func fingerDistanceFromProjectileRestPosition(projectileRestPosition: CGPoint, fingerPosition: CGPoint) -> CGFloat {
        return sqrt(pow(projectileRestPosition.x - fingerPosition.x,2) + pow(projectileRestPosition.y - fingerPosition.y,2))
    }
    
    func projectilePositionForFingerPosition(fingerPosition: CGPoint, projectileRestPosition:CGPoint, rLimit:CGFloat) -> CGPoint {
        let θ = atan2(fingerPosition.x - projectileRestPosition.x, fingerPosition.y - projectileRestPosition.y)
        let cX = sin(θ) * rLimit
        let cY = cos(θ) * rLimit
        return CGPoint(x: cX + projectileRestPosition.x, y: cY + projectileRestPosition.y)
    }
    
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
    
    func setupSlingshot() {
        let slingshot_1 = SKSpriteNode(imageNamed: "slingshot_1")
        slingshot_1.position = CGPoint(x: -100, y: -10)
        addChild(slingshot_1)
        slingshot_1.isHidden = false
        
        projectile = spear()
        projectile.position = Settings.Metrics.projectileRestPosition
        addChild(projectile)
        
        let slingshot_2 = SKSpriteNode(imageNamed: "slingshot_2")
        slingshot_2.position = CGPoint(x: -100, y: -10)
        addChild(slingshot_2)
        slingshot_2.isHidden = false
    }
    
    func GameOver() {
        cameraTarget = nil
        cameraNode.position.y = 123.14
        print("game Over is called")
        let numberOfLifes = UserDefaults.standard.integer(forKey: "numberOfLifes") - 1
        UserDefaults.standard.set(numberOfLifes, forKey: "numberOfLifes")
        UserDefaults.standard.synchronize()
        
        starOne.alpha = 0
        starTwo.alpha = 0
        starThree.alpha = 0
        
        menus.position.x = cameraNode.position.x
        
        let moveMenu = SKAction.move(to: CGPoint(x: menus.position.x, y: 180 ), duration: 1)
        let moveDelay = SKAction.wait(forDuration: 0.5)
        let menuSequence = SKAction.sequence([moveDelay,moveMenu])

        menus.run(menuSequence)
        pauseMenu.position.y = -200
        resumeButton.position.y = -200
        nextLevelButton.position.y = -200

        inGameMenu.isHidden = true
        
    }
    
    func starEmitterNode(node: SKNode) {
        let starEmitterPath = Bundle.main.path(forResource: "StarWinEmitter",
                                         ofType: "sks")
        
        let starEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: starEmitterPath!)
            as! SKEmitterNode
        
        starEmitter.position = node.position
    
        self.addChild(starEmitter)

    }
    
    func win() {
        cameraTarget = nil
        cameraNode.position.y = 123.14
        starOne.alpha = 0
        starTwo.alpha = 0
        starThree.alpha = 0
        
        menus.position.x = cameraNode.position.x
        
        let moveMenu = SKAction.move(to: CGPoint(x: menus.position.x, y: 180 ), duration: 1)
        let moveDelay = SKAction.wait(forDuration: 0.5)
        let menuSequence = SKAction.sequence([moveDelay,moveMenu])
        
        menus.run(menuSequence)
        pauseMenu.position.y = -200
        resumeButton.position.y = -200
        gameOverSign.position.y -= 200
        
        var stars = 0
        
        inGameMenu.isHidden = true
        
        if background.position.y > -1000 {
            stars = 1
            if background.position.y > -232{
                stars = 2
                if background.position.y > 538 {
                    stars = 3
                }
            }
        }
        
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
        
        if stars == 1 {
            starOne.run(starSequence)
            starEmitterNode(node: starOne)
        } else if stars == 2 {
            starOne.run(starSequence)
            starTwo.run(starSequence2)
            starEmitterNode(node: starOne)
            starEmitterNode(node: starTwo)
        } else if stars == 3 {
            starOne.run(starSequence)
            starTwo.run(starSequence2)
            starThree.run(starSequence3)
            starEmitterNode(node: starOne)
            starEmitterNode(node: starTwo)
            starEmitterNode(node: starThree)
        }
        
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
        
        let name = String(currentLevel)
        if stars > UserDefaults.standard.integer(forKey: name){
            levelScore[currentLevel] = stars
            UserDefaults.standard.set(levelScore[currentLevel]!, forKey: name)
            UserDefaults.standard.synchronize()
        }
    }
}
