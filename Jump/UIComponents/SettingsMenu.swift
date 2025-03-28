import SpriteKit

class SettingsMenu: SKNode {
    
    private let topButtonScale: CGFloat = 0.4
    private let toggleButtonScale: CGFloat = 1.1
    public  let backgroundDimNode: SKSpriteNode
    private var bgNode: SKSpriteNode!
    private var soundToggle: SKSpriteNode!
    private var musicToggle: SKSpriteNode!
    private var closeButton: SKSpriteNode!
    private var backButton: SKSpriteNode!
    
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
        backgroundDimNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(backgroundDimNode)
        
        let settingsBg = SKSpriteNode(imageNamed: "panel-soundSettings")
        settingsBg.setScale(topButtonScale)
        settingsBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        settingsBg.zPosition = 101
        addChild(settingsBg)

        soundToggle = SKSpriteNode(imageNamed: AudioSettingsManager.shared.isSoundEnabled ? "icon-sound-on" : "icon-sound-off")
        soundToggle.position = CGPoint(x: settingsBg.position.x / 2, y: settingsBg.position.y / 2 - 250)
        soundToggle.name = "SoundToggle"
        soundToggle.zPosition = 120
        soundToggle.setScale(toggleButtonScale)
        settingsBg.addChild(soundToggle)
        
        musicToggle = SKSpriteNode(imageNamed: AudioSettingsManager.shared.isMusicEnabled ? "icon-sound-on" : "icon-sound-off")
        musicToggle.position = CGPoint(x: settingsBg.position.x / 2, y: settingsBg.position.y / 4 - 335)
        musicToggle.name = "MusicToggle"
        musicToggle.zPosition = 120
        musicToggle.setScale(toggleButtonScale)
        settingsBg.addChild(musicToggle)

        closeButton = SKSpriteNode(imageNamed: "icon-back")
               closeButton.setScale(topButtonScale)
               closeButton.position = CGPoint(x: size.width * 0.5 - closeButton.size.width / 2 - 250,
                                              y: size.height * 0.5 + size.height * 0.5 - 220)
               closeButton.zPosition = 102
               closeButton.name = "CloseSettings"
               addChild(closeButton)
    }
    
    func updateSettingsUI() {
        soundToggle.texture = SKTexture(imageNamed: AudioSettingsManager.shared.isSoundEnabled ? "icon-sound-on" : "icon-sound-off")
        musicToggle.texture = SKTexture(imageNamed: AudioSettingsManager.shared.isMusicEnabled ? "icon-sound-on" : "icon-sound-off")
    }
}

