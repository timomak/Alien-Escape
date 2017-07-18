//
//  GameScene.swift
//  AlienEscape
//
//  Created by timofey makhlay on 6/30/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

// print(#file, #function, #line)

// TODO: Sound effects and Music
// TODO: Animations
// TODO: MainMenu Animation
// TODO: Laser gun with the right angle
// TODO: Dotted line
// TODO: Win animation
// TODO: Secret levels based on number of collected stars
// TODO: Change start button
// TODO: Allow placement of portals
// TODO: Buy systems for the lifes or ads or sharing on social Media
// TODO: Change UI system Completely
// TODO: Raplace Slingshot with alien "stuff"
// TODO: Improve Game over (add animation GTA style [wasted])
// TODO: Add interchangeble items
// TODO: For Loop the level select


import SpriteKit

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

class GameScene: SKScene, SKPhysicsContactDelegate{
    
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
    
    var springField: SKFieldNode!
    var fieldNodeSize: SKSpriteNode!
    
    var gameOverSign: MSButtonNode!
    // MARK: Next Level Menu
    var starOne :SKSpriteNode!
    var starTwo :SKSpriteNode!
    var starThree :SKSpriteNode!
    var winMenu: SKSpriteNode!
    var nextLevelButton: MSButtonNode!
    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var gameStart: CFTimeInterval = 0
    var timer: CFTimeInterval = 0
    var trajectoryTimeOut: CFTimeInterval = 1
    
    var pauseMenu: SKSpriteNode!
    var resetButton: MSButtonNode!
    var resumeButton: MSButtonNode!
    var levelSelectButton: MSButtonNode!
    
    var background: SKSpriteNode!
    var portal1: SKSpriteNode!
    var portal2: SKSpriteNode!
    
    var alien: SKSpriteNode!
    var inGameMenu: MSButtonNode!
    // Sets Projectile as an Image
    var projectile: spear!
    
    // var rayGun: SKSpriteNode!
    
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
    
    func cameraMove() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 240, upper: 600)
        cameraNode.position.x = x
    }
    
    
    // MARK: Loading Levels
    class func level(_ currentLevel: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(currentLevel)") else {
            return nil
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    override func didMove(to view: SKView) {
        currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        alien = childNode(withName: "//alien") as! SKSpriteNode
        inGameMenu = childNode(withName: "//inGameMenu") as! MSButtonNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        // rayGun = childNode(withName: "rayGun") as! SKSpriteNode
        portal1 = childNode(withName: "portal_1") as! SKSpriteNode
        portal2 = childNode(withName: "portal_2") as! SKSpriteNode
        background = childNode(withName: "background") as! SKSpriteNode
        pauseMenu = childNode(withName: "pauseMenu") as! SKSpriteNode
        resumeButton = childNode(withName: "//resumeButton") as! MSButtonNode
        resetButton = childNode(withName: "resetButton") as! MSButtonNode
        
        starOne = childNode(withName: "//starOne") as! SKSpriteNode
        starTwo = childNode(withName: "//starTwo") as! SKSpriteNode
        starThree = childNode(withName: "//starThree") as! SKSpriteNode
        
        winMenu = childNode(withName: "winMenu") as! SKSpriteNode
        nextLevelButton = childNode(withName: "//nextLevelButton") as! MSButtonNode
        gameOverSign = childNode(withName: "//gameOverSign") as! MSButtonNode
        levelSelectButton = childNode(withName: "levelSelectButton") as! MSButtonNode
        
        if UserDefaults.standard.integer(forKey: "currentLevel") == 4 || UserDefaults.standard.integer(forKey: "currentLevel") == 6{
            springField = childNode(withName: "springField") as! SKFieldNode
            fieldNodeSize = childNode(withName: "fieldNodeSize") as! SKSpriteNode
            springField.region = SKRegion(size: fieldNodeSize.size)
        }

        
        lifeCounter = childNode(withName: "//lifeCounter") as! SKLabelNode
        
        let numberOfLives = UserDefaults.standard.integer(forKey: "numberOfLifes")
        
        lifeCounter.text = String(numberOfLives)
        
        self.physicsWorld.contactDelegate = self
        
        self.camera = cameraNode
        
        print("At did begin ",UserDefaults.standard.integer(forKey: "checkpoint"))
        
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
        
        gameOverSign.selectedHandler = {
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
        
        inGameMenu.selectedHandler = {
            
            if self.gameState == .playing {
                self.pauseMenu.position.x = self.cameraNode.position.x
                self.resetButton.position.x = self.cameraNode.position.x
                self.levelSelectButton.position.x = self.cameraNode.position.x
                self.resetButton.position.x = self.cameraNode.position.x
                
                
                self.pauseMenu.position.y = 150
                self.resumeButton.position.y = 240
                self.levelSelectButton.position.y = 140
                self.resetButton.position.y = 40
                self.inGameMenu.isHidden = true
                self.gameOverSign.isHidden = true
                self.gameState = .paused
            }
        }
        resumeButton.selectedHandler = {
            self.pauseMenu.position.y = -430
            self.resumeButton.position.y = -340
            self.levelSelectButton.position.y = -440
            self.resetButton.position.y = -540
            self.gameState = .playing
            self.inGameMenu.isHidden = false
        }
        
        setupSlingshot()
        gameOverSign.isHidden = true
        
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
        
        if UserDefaults.standard.integer(forKey: "currentLevel") > 4 {
            background.position.x = cameraNode.position.x
        }
        
        if UserDefaults.standard.integer(forKey: "currentLevel") > 6 {
            cameraMove()
        }
        
        if background.position.y > -1000 && gameState == .playing{
            background.position.y -= 5
        } else if gameState == .playing{
            gameState = .gameOver
        }
        
        gameStart += fixedDelta
        timer += fixedDelta
        trajectoryTimeOut += fixedDelta
        if projectile.position.x > -120 && projectile.position.x < 0 {
         if trajectoryTimeOut > 0.06 && trajectoryTimeOut < 0.15 {
            print("This shouldn't be 0: \(trajectoryTimeOut)")
            trajectoryLine(Point: projectile.position)
        }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .playing {
            func shouldStartDragging(touchLocation:CGPoint, threshold: CGFloat) -> Bool {
                let distance = fingerDistanceFromProjectileRestPosition(
                    projectileRestPosition: Settings.Metrics.projectileRestPosition,
                    fingerPosition: touchLocation
                )
                return distance < Settings.Metrics.projectileRadius + threshold
            }
            
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                
                if !projectileIsDragged && shouldStartDragging(touchLocation: touchLocation, threshold: Settings.Metrics.projectileTouchThreshold)  {
                    touchStartingPoint = touchLocation
                    touchCurrentPoint = touchLocation
                    projectileIsDragged = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if projectileIsDragged {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                let distance = fingerDistanceFromProjectileRestPosition(projectileRestPosition: touchLocation, fingerPosition: touchStartingPoint)
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
            if gameState == .playing && UserDefaults.standard.integer(forKey: "currentLevel") > 6 {
                guard let touch = touches.first else {
                    return
                }
                let location = touch.location(in: self)
                let previousLocation = touch.previousLocation(in: self)
                
                let targetX = cameraNode.position.x
                let x = clamp(value: targetX, lower: 239, upper: 600)
                cameraNode.position.x = x
                if cameraNode.position.x != x {
                    cameraNode.position.x = x
                } else {
                    camera?.position.x += (location.x - previousLocation.x) * -1
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if projectileIsDragged {
            cameraTarget = projectile
            projectileIsDragged = false
            let distance = fingerDistanceFromProjectileRestPosition(projectileRestPosition: touchCurrentPoint, fingerPosition: touchStartingPoint)
            if distance > Settings.Metrics.projectileSnapLimit {
                let vectorX = touchStartingPoint.x - touchCurrentPoint.x
                let vectorY = touchStartingPoint.y - touchCurrentPoint.y
                projectile.physicsBody = SKPhysicsBody(circleOfRadius: Settings.Metrics.projectileRadius)
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
                
                print("This should be 0: \(trajectoryTimeOut)")
            } else {
                projectile.physicsBody = nil
                projectile.position = Settings.Metrics.projectileRestPosition
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
                teleportBall(node: nodeA)
            }
            if contactB.categoryBitMask != 4{
                teleportBall(node: nodeB)
            }
        }
        if gameState != .gameOver && gameState != .won {
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
    
    func teleportBall(node: SKNode) {
        
        let moveBall = SKAction.move(to: portal2.position, duration:0)
        node.run(moveBall)
        if UserDefaults.standard.integer(forKey: "currentLevel") > 4 {
            cameraNode.position.x = 1764.218
            cameraNode.position.y = 123.14
        }
    }
    
    func animateExplosion(node: SKNode) {
        node.run(SKAction(named: "Boom")!)
        // MARK: Sound Effect
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
            static let projectileRadius = CGFloat(15)
            static let projectileRestPosition = CGPoint(x: -120, y: 0)
            static let projectileTouchThreshold = CGFloat(10)
            static let projectileSnapLimit = CGFloat(10)
            static let forceMultiplier = CGFloat(1.0)
            static let rLimit = CGFloat(50)
        }
        struct Game {
            static let gravity = CGVector(dx: 0,dy: -9.8)
        }
    }
    
    func setupSlingshot() {
        let slingshot_1 = SKSpriteNode(imageNamed: "slingshot_1")
        slingshot_1.position = CGPoint(x: -120, y: -50)
        addChild(slingshot_1)
        slingshot_1.isHidden = false
        
        projectile = spear()
        projectile.position = Settings.Metrics.projectileRestPosition
        addChild(projectile)
        let slingshot_2 = SKSpriteNode(imageNamed: "slingshot_2")
        slingshot_2.position = CGPoint(x: -120, y: -50)
        addChild(slingshot_2)
        slingshot_2.isHidden = false
    }
    
    func GameOver() {
        print("game Over is called")
        let numberOfLifes = UserDefaults.standard.integer(forKey: "numberOfLifes") - 1
        UserDefaults.standard.set(numberOfLifes, forKey: "numberOfLifes")
        UserDefaults.standard.synchronize()
        
        starOne.alpha = 0
        starTwo.alpha = 0
        starThree.alpha = 0
        
        resetButton.position.x = cameraNode.position.x
        levelSelectButton.position.x = cameraNode.position.x
        winMenu.position.x = cameraNode.position.x
        
        let moveMenu = SKAction.move(to: CGPoint(x: cameraNode.position.x, y:150), duration: 1)
        let moveDelay = SKAction.wait(forDuration: 0.5)
        let menuSequence = SKAction.sequence([moveDelay,moveMenu])
        winMenu.run(menuSequence)
        
        let moveMenu2 = SKAction.move(to: CGPoint(x: cameraNode.position.x, y:160), duration: 1)
        let menuSequence2 = SKAction.sequence([moveDelay,moveMenu2])
        levelSelectButton.run(menuSequence2)
        
        let moveMenu4 = SKAction.move(to: CGPoint(x: cameraNode.position.x, y: 40 ), duration: 1)
        let menuSequence4 = SKAction.sequence([moveDelay,moveMenu4])
        resetButton.run(menuSequence4)

        inGameMenu.isHidden = true
        
    }
    func win() {
        starOne.alpha = 0
        starTwo.alpha = 0
        starThree.alpha = 0
        
        winMenu.position.x = cameraNode.position.x
        nextLevelButton.position.x = cameraNode.position.x + 50
        levelSelectButton.position.x = cameraNode.position.x
        resetButton.position.x = cameraNode.position.x - 50
        nextLevelButton.position.y = resetButton.position.y
        
        let moveMenu = SKAction.move(to: CGPoint(x: cameraNode.position.x, y:150), duration: 1)
        let moveDelay = SKAction.wait(forDuration: 0.5)
        let menuSequence = SKAction.sequence([moveDelay,moveMenu])
        winMenu.run(menuSequence)
        
        let moveMenu2 = SKAction.move(to: CGPoint(x: cameraNode.position.x + 50, y:40), duration: 1)
        let menuSequence2 = SKAction.sequence([moveDelay,moveMenu2])
        nextLevelButton.run(menuSequence2)
        
        let moveMenu3 = SKAction.move(to: CGPoint(x: cameraNode.position.x, y:160), duration: 1)
        let menuSequence3 = SKAction.sequence([moveDelay,moveMenu3])
        levelSelectButton.run(menuSequence3)
        
        let moveMenu4 = SKAction.move(to: CGPoint(x: cameraNode.position.x - 50, y:40), duration: 1)
        let menuSequence4 = SKAction.sequence([moveDelay,moveMenu4])
        resetButton.run(menuSequence4)
        
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
        print(stars)
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
        } else if stars == 2 {
            starOne.run(starSequence)
            starTwo.run(starSequence2)
            
        } else if stars == 3 {
            starOne.run(starSequence)
            starTwo.run(starSequence2)
            starThree.run(starSequence3)
        }
        
        if UserDefaults.standard.integer(forKey: "checkpoint") < 2 {
            lastLevel = 2
            UserDefaults.standard.set(lastLevel, forKey: "checkpoint")
            UserDefaults.standard.synchronize()
            print("set to two", UserDefaults.standard.integer(forKey: "checkpoint"))
        }
        if UserDefaults.standard.integer(forKey: "checkpoint") > 1{
            UserDefaults.standard.set(currentLevel, forKey: "checkpoint")
            UserDefaults.standard.synchronize()
            print("At won ",UserDefaults.standard.integer(forKey: "checkpoint"))
        }

        
        let name = String(currentLevel)
        if stars > UserDefaults.standard.integer(forKey: name){
            levelScore[currentLevel] = stars
            UserDefaults.standard.set(levelScore[currentLevel]!, forKey: name)
            UserDefaults.standard.synchronize()
        }
    }
    func trajectoryLine(Point: CGPoint) {

        let point = SKSpriteNode(imageNamed: "Circle_small")
        point.position.x = Point.x
        point.position.y = Point.y
        addChild(point)

    }
}
