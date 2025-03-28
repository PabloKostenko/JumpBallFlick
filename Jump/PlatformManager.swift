import SpriteKit

protocol PlatformManagerDelegate: AnyObject {
    var player: SKSpriteNode! { get }
    var playerRadius: CGFloat { get }
    var frame: CGRect { get }
    var scoreManager: ScoreManager! { get }
    func addChild(_ node: SKNode)
    func addGemRandomly()
    var isFreePlayMode: Bool { get }
    var currentPlatform: PlatformNode? { get }
}

class PlatformManager {
    var platforms: [PlatformNode] = []
    private let platformSpeed: CGFloat
    private weak var scene: PlatformManagerDelegate?
    private var platformCount: Int = 0
    
    init(scene: PlatformManagerDelegate, platformSpeed: CGFloat) {
        self.scene = scene
        self.platformSpeed = platformSpeed
    }
    
    func createPlatforms() {
        var platformCount = 6
        let platformYOffset: CGFloat = 200.0
        let platformHeightOffset: CGFloat = 150.0

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.isIPhone5 || appDelegate.isIPhone {
                platformCount = 4
            }
        }

        for i in 0..<platformCount {
            let platformType = randomPlatformType()
            let platformY = CGFloat(i) * platformHeightOffset + 100 + platformYOffset
            let platform = PlatformNode(type: platformType, position: CGPoint(x: 0, y: platformY))
            
            guard let scene = scene else { return }
            platform.position.x = CGFloat.random(in: scene.playerRadius...(scene.frame.width - scene.playerRadius - platform.size.width))
            adjustPlatformPositionIfNeeded(platform)
            scene.addChild(platform)
            platforms.append(platform)
        }
    }

    
    func movePlatforms() {
        guard let scene = scene else { return }
        
        var platformsToRemove: [PlatformNode] = []
        
        for platform in platforms {
            platform.position.y -= platformSpeed
            if let currentPlatform = scene.currentPlatform, currentPlatform === platform {
                scene.player.position.y -= platformSpeed
            }
            
            if platform.platformType == .moving {
                checkAndCorrectPlatformWallCollision(platform)
            }

            if platform.position.y < -platform.size.height {
                platformsToRemove.append(platform)
                let newPlatformType = randomPlatformType()
                let newPlatformY = scene.frame.height + platform.size.height
                let newPlatform = PlatformNode(type: newPlatformType, position: CGPoint(x: 0, y: newPlatformY))
                newPlatform.position.x = CGFloat.random(in: scene.playerRadius...(scene.frame.width - scene.playerRadius - newPlatform.size.width))
                adjustPlatformPositionIfNeeded(newPlatform)
                scene.addChild(newPlatform)
                platforms.append(newPlatform)
                
                scene.scoreManager.addScore(points: 1)
                platformCount += 1
                
                if platformCount >= 5 {
                    if scene.isFreePlayMode {
                        scene.addGemRandomly()
                    }
                    platformCount = 0
                }
            }
        }

        for platform in platformsToRemove {
            platform.removeFromParent()
            if let index = platforms.firstIndex(of: platform) {
                platforms.remove(at: index)
            }
        }
    }


    private func checkAndCorrectPlatformWallCollision(_ platform: PlatformNode) {
        guard let scene = scene else { return }
        
        let leftWallLimit: CGFloat = scene.playerRadius
        let rightWallLimit: CGFloat = scene.frame.width - scene.playerRadius - platform.size.width
        
        if platform.position.x < leftWallLimit {
            platform.position.x = leftWallLimit
            platform.physicsBody?.velocity.dx = abs(platform.physicsBody?.velocity.dx ?? 0)
        } else if platform.position.x > rightWallLimit {
            platform.position.x = rightWallLimit
            platform.physicsBody?.velocity.dx = -(abs(platform.physicsBody?.velocity.dx ?? 0))
        }
    }
    
    private func randomPlatformType() -> PlatformType {
        let randomValue = Int.random(in: 0...99)
        switch randomValue {
        case 0..<33:
            return .normal
        case 33..<66:
            return .withHole
        case 66..<100:
            return .moving
        default:
            return .normal
        }
    }

    private func adjustPlatformPositionIfNeeded(_ platform: PlatformNode) {
        guard let scene = scene else { return }
        
        let leftWallLimit: CGFloat = scene.playerRadius
        let rightWallLimit: CGFloat = scene.frame.width - scene.playerRadius - platform.size.width

        if platform.position.x < leftWallLimit {
            platform.position.x = leftWallLimit
        } else if platform.position.x > rightWallLimit {
            platform.position.x = rightWallLimit
        }
    }
    
    func getFirstPlatform() -> PlatformNode? {
        return platforms.first
    }
}
