import SpriteKit

class spear: SKSpriteNode {
    
    init() {
        // Make a texture from an image, a color, and size
        let texture = SKTexture(imageNamed: "Circle")
        let color = UIColor.clear
        let size = texture.size()
        
        
        // Call the designated initializer
        super.init(texture: texture, color: color, size: size)
        // Set physics properties
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
