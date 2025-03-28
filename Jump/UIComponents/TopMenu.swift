
import SpriteKit

class TopMenu: SKNode {
    
    init(size: CGSize) {
        super.init()
        setupMenu(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMenu(size: CGSize) {
        let topButtonScale: CGFloat = 0.5
        let topButtonSpacing: CGFloat = 320
        
        let settingsButton = SKSpriteNode(imageNamed: "icon-setting")
        settingsButton.setScale(topButtonScale)
        settingsButton.position = CGPoint(x: size.width - settingsButton.size.width / 2 - topButtonSpacing, y: size.height - 220)
        settingsButton.zPosition = 10.0
        settingsButton.name = "Settings"
        addChild(settingsButton)

        let trophyButton = SKSpriteNode(imageNamed: "icon-trophy")
        trophyButton.setScale(topButtonScale)
        trophyButton.position = CGPoint(x: settingsButton.position.x - settingsButton.size.width + 50, y: settingsButton.position.y)
        trophyButton.zPosition = 10.0
        trophyButton.name = "Trophy"
        addChild(trophyButton)
    }
}
