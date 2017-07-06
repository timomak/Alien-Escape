//
//  GameScene.swift
//  AlienEscape
//
//  Created by timofey makhlay on 6/30/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

// print(#file, #function, #line)


// TODO: Game Victory when Level up
// TODO: Game Over with restart Button
// TODO: Pause Menu
// TODO: Background set as time
// TODO: Game Victory based on time it took
// TODO: Sound effects and Music
// TODO: Visuals
// TODO: Animations
// TODO: Online highscores
// TODO: MainMenu Animation
// TODO: Laser gun with the right angle
// TODO: Time Rappresentation in game
// TODO: Dotted line
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
                break
            case .paused:
                break
            case .won:
                break
            case .playing:
                break
                
            }
        }
    }
    var alien: SKSpriteNode!
    var inGameMenu: MSButtonNode!
    // Sets Projectile as an Image
    var projectile: spear!
    
    //Touch dragging vars
    var projectileIsDragged = false
    var touchCurrentPoint: CGPoint!
    var touchStartingPoint: CGPoint!
    
    // Setting up camera
    var cameraNode:SKCameraNode!
    var cameraTarget:SKSpriteNode!

    
    // TODO: Create a level up
    // MARK: Loading Levels
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFit
        return scene
    }

    override func didMove(to view: SKView) {
        alien = childNode(withName: "//alien") as! SKSpriteNode
        inGameMenu = childNode(withName: "//inGameMenu") as! MSButtonNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        self.physicsWorld.contactDelegate = self
        self.camera = cameraNode

        inGameMenu.selectedHandler = {
            guard let scene = GameScene.level(1) else {
                print("Level 1 is missing?")
                return
            }
            
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        setupSlingshot()
        
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        moveCamera()
        
        func checkSpear() {
            guard let cameraTarget = cameraTarget else {
                return
            }

            if cameraTarget.position.y < -200 || cameraTarget.position.x > 1050{
                cameraTarget.removeFromParent()
                resetCamera()
            }
        }
        checkSpear()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .playing {
            print(gameState)
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
                    projectile.isHidden = false
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
                projectile.physicsBody?.contactTestBitMask = 1
                physicsBody?.friction = 0.6
                physicsBody?.mass = 0.5
                projectile.physicsBody?.applyImpulse(
                    CGVector(
                        dx: vectorX * Settings.Metrics.forceMultiplier,
                        dy: vectorY * Settings.Metrics.forceMultiplier
                    )
                )
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
        if contactA.categoryBitMask == 0 || contactB.categoryBitMask == 0 {
            if contactA.categoryBitMask == 0{
                animateExplosion(node: nodeA)
            }
            if contactB.categoryBitMask == 0{
                animateExplosion(node: nodeB)
            }
        }
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            /* Was the collision more than a gentle nudge? */
            if contact.collisionImpulse > 5 {
                
                /* Kill Seal */
                if contactA.categoryBitMask == 2 {
                    removeAlien(node: nodeA)
                }
                if contactB.categoryBitMask == 2 {
                    removeAlien(node: nodeB)
                    
                }
            }
        }
    }
    
    func animateExplosion(node: SKNode) {
        print("There was contact ", node)
        node.run(SKAction(named: "Boom")!)
        /* Play SFX */
        let sound = SKAction.playSoundFileNamed("granade", waitForCompletion: false)
        self.run(sound)

    }
    
    
    func removeAlien(node: SKNode) {
        gameState = .won
        print(gameState)
        
        /* Create our hero death action */
        let alienDeath = SKAction.run({
            /* Remove seal node from scene */
            node.removeFromParent()
            
        })
        self.run(alienDeath)
    }
    
    // MARK: Move Camera function
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let targetY = cameraTarget.position.y
        let x = clamp(value: targetX, lower: 0, upper: 478)
        let y = clamp(value: targetY, lower: 0, upper: 268)
        cameraNode.position.x = x
        cameraNode.position.y = y
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
            static let projectileRestPosition = CGPoint(x: -190, y: 0)
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
        slingshot_1.position = CGPoint(x: -190, y: -50)
        addChild(slingshot_1)
        slingshot_1.isHidden = true
        
        let _ = UIBezierPath(
            arcCenter: CGPoint.zero,
            radius: Settings.Metrics.projectileRadius,
            startAngle: 0,
            endAngle: CGFloat(CGFloat.pi * 2),
            clockwise: true
        )
        projectile = spear()
        projectile.isHidden = false
        projectile.position = Settings.Metrics.projectileRestPosition
        addChild(projectile)
        
        let slingshot_2 = SKSpriteNode(imageNamed: "slingshot_2")
        slingshot_2.position = CGPoint(x: -190, y: -50)
        addChild(slingshot_2)
        slingshot_2.isHidden = true
    }
    
    func resetCamera() {
        /* Reset camera */
        let cameraReset = SKAction.move(to: CGPoint(x:0, y:0), duration: 1.5)
        let cameraDelay = SKAction.wait(forDuration: 0.5)
        let cameraSequence = SKAction.sequence([cameraDelay,cameraReset])
        cameraNode.run(cameraSequence)
        cameraTarget = nil
        if gameState == .playing {
            gameState = .gameOver
            print(gameState)
        }
    }
}
