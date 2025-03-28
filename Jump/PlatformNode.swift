import SpriteKit

enum PlatformType {
    case normal
    case withHole
    case moving
}

class PlatformNode: SKSpriteNode {
    var platformType: PlatformType = .normal
    var platformId: UUID = UUID()
    var isBeingRemoved: Bool = false

    init(type: PlatformType, position: CGPoint) {
        self.platformType = type
        super.init(texture: nil, color: .clear, size: CGSize(width: 150, height: 30))
        self.position = position
        setupPlatform()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlatform() {
        switch platformType {
        case .normal:
            self.texture = SKTexture(imageNamed: "platform")
        case .withHole:
            self.texture = SKTexture(imageNamed: "platformWithHole")
        case .moving:
            self.texture = SKTexture(imageNamed: "platformMoving")
        }
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.Platform
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        self.physicsBody?.collisionBitMask = 0
        
        if platformType == .moving {
            let moveLeft = SKAction.moveBy(x: -100, y: 0, duration: 2.0)
            let moveRight = SKAction.moveBy(x: 100, y: 0, duration: 2.0)
            let sequence = SKAction.sequence([moveLeft, moveRight])
            let moveAction = SKAction.repeatForever(sequence)
            self.run(moveAction)
        }
    }
    
    func removePlatform() {
        guard !isBeingRemoved else { return }
        isBeingRemoved = true
        self.physicsBody = nil
        self.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.run { [weak self] in
                self?.removeFromParent()
            }
        ]))
    }
}
