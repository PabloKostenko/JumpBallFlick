import SpriteKit

class PlayerNode: SKSpriteNode {
    
    //MARK: - Initializes
    
    init() {
        let selectedSkinName = GameDataManager.shared.getSelectedBallWithoutShadow()
        let texture = SKTexture(imageNamed: selectedSkinName)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "Player"
        self.zPosition = 10.0
        self.setScale(0.1)
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.linearDamping = 0.4
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = true
        
        self.physicsBody?.restitution = 0.6
        self.physicsBody?.friction =  0.3
        self.physicsBody?.mass = 1.0
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Platform | PhysicsCategories.Wall | PhysicsCategories.Score | PhysicsCategories.SuperScore
        self.physicsBody?.collisionBitMask = PhysicsCategories.Wall
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Setups
    
    internal func activate(_ isDynamic: Bool) {
        self.physicsBody?.isDynamic = isDynamic
    }
    
    internal func height() -> CGFloat {
        return self.position.y + screenHeight / 2 * 0.75
    }
    
    internal func launch(withImpulse impulse: CGVector, strengthMultiplier: CGFloat) {
        let scaledLaunchVector = CGVector(dx: impulse.dx * strengthMultiplier, dy: impulse.dy * strengthMultiplier)
        self.physicsBody?.applyImpulse(scaledLaunchVector)
    }

    internal func stickToPlatform(platform: SKSpriteNode) {
        self.position = CGPoint(x: self.position.x, y: platform.position.y + platform.size.height / 2 + self.size.height / 2)
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.linearDamping = 10
        self.physicsBody?.affectedByGravity = false
    }

    internal func releaseFromPlatform() {
        self.physicsBody?.linearDamping = 0.4
        self.physicsBody?.affectedByGravity = true
    }
}
