import SpriteKit

class StarNode: SKNode {
    
    // MARK: - Properties
    private var node: SKSpriteNode!
    private let radius: CGFloat = 35.0
    private let scale: CGFloat = 0.5
    
    override init() {
        super.init()
        self.name = "Star"
        self.zPosition = 5.0
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupPhysics() {
        node = SKSpriteNode(imageNamed: "icon-star")
        node.name = "StarNode"
        node.setScale(scale)
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategories.SuperScore
        node.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        node.physicsBody?.collisionBitMask = 0
        
        addChild(node)
    }
    
    func bounce() {
        let isRepeat = SKAction.repeat(.sequence([
            .scale(to: scale * 0.85, duration: 0.1),
            .scale(to: scale * 1.0, duration: 0.1),
        ]), count: 2)
        
        run(.wait(forDuration: 0.5)) {
            self.node.run(.repeatForever(.sequence([
                isRepeat,
                .wait(forDuration: 1.5)
            ])))
        }
    }
}
