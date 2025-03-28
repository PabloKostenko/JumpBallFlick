import SpriteKit

class TrophyMenu: SKNode {
    
    private let topButtonScale: CGFloat = 0.4
    private let toggleButtonScale: CGFloat = 1.1
    public let backgroundDimNode: SKSpriteNode
    private var bgNode: SKSpriteNode!
    private var closeButton: SKSpriteNode!
    
    init(size: CGSize) {
        backgroundDimNode = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: size)
        backgroundDimNode.zPosition = 50.0
        super.init()
        setupMenu(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func setupBackground(for scene: SKScene, imageName: String) {
        let bgNode = SKSpriteNode(imageNamed: imageName)
        bgNode.zPosition = -1.0
        bgNode.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        
        let scaleX = scene.frame.width / bgNode.size.width
        let scaleY = scene.frame.height / bgNode.size.height
        let scale = max(scaleX, scaleY)
        bgNode.setScale(scale)
        
        if appDL.isIPhoneX || appDL.isIPad11 || appDL.isIPadPro {
            bgNode.size = CGSize(width: scene.frame.width * 1.1, height: scene.frame.height * 1.1)
        }
        
        scene.addChild(bgNode)
    }

    private func setupMenu(size: CGSize) {
        globalHighScore = UserDefaults.standard.integer(forKey: "FreePlayScoreKey")
        
        backgroundDimNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(backgroundDimNode)
        
        let trophyBg = SKSpriteNode(imageNamed: "panel-highScore")
        trophyBg.setScale(topButtonScale)
        trophyBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        trophyBg.zPosition = 101
        addChild(trophyBg)

        let highScoreLbl = SKLabelNode(fontNamed: FontName.montserrat)
        highScoreLbl.fontSize = 80.0
        highScoreLbl.text = "\(globalHighScore)"
        highScoreLbl.fontColor = .white
        highScoreLbl.zPosition = 102.0
        highScoreLbl.position = CGPoint(x: size.width / 2, y: size.height / 2 - 45)
        addChild(highScoreLbl)

        let highScoreTrophyIcon = SKSpriteNode(imageNamed: "cup")
        highScoreTrophyIcon.setScale(0.45)
        highScoreTrophyIcon.zPosition = 102.0
        highScoreTrophyIcon.position = CGPoint(x: highScoreLbl.position.x + highScoreLbl.frame.width / 2 + 40, y: highScoreLbl.position.y + 30)
        addChild(highScoreTrophyIcon)
        
        closeButton = SKSpriteNode(imageNamed: "icon-back")
               closeButton.setScale(topButtonScale)
               closeButton.position = CGPoint(x: size.width * 0.5 - closeButton.size.width / 2 - 250,
                                              y: size.height * 0.5 + size.height * 0.5 - 220)
               closeButton.zPosition = 102
               closeButton.name = "CloseTrophy"
               addChild(closeButton)
    }
}
