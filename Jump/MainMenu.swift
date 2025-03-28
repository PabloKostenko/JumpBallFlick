import SpriteKit
import AVFoundation

class MainMenu: SKScene {
    
    // MARK: - Properties
    private var playButton: SKSpriteNode!
    private var levelsButton: SKSpriteNode!
    private var storeButton: SKSpriteNode!
    
    private var starCount: Int = 0
    
    private var settingsMenu: SettingsMenu?
    private var trophyMenu: TrophyMenu?
    
    var soundEffectPlayer: AVAudioPlayer?
    var musicPlayer: AVAudioPlayer?
    
    
    private var isButtonPlay = false {
        didSet {
            updateBtn(node: playButton, event: isButtonPlay)
        }
    }
    
    private var isButtonLevels = false {
        didSet {
            updateBtn(node: levelsButton, event: isButtonLevels)
        }
    }
    
    private var isButtonStore = false {
        didSet {
            updateBtn(node: storeButton, event: isButtonStore)
        }
    }

    // MARK: - Scene Life Cycle
    override func didMove(to view: SKView) {
        AudioSettingsManager.shared.initializeDefaultSettings()
        
        if let sceneSize = view.scene?.size {
            SceneSizeManager.shared.updateSceneSize(sceneSize)
        }
        
        setupNodes()
        setupAudio()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if let settingsMenu = settingsMenu, node == settingsMenu.backgroundDimNode {
            closeSettingsMenu()
            return
        }
        
        if let trophyMenu = trophyMenu, node == trophyMenu.backgroundDimNode {
            closeTrophyMenu()
            return
        }
        
        if node.name == "Play" && !isButtonPlay {
            isButtonPlay = true
        } else if node.name == "Levels" && !isButtonLevels {
            isButtonLevels = true
        } else if node.name == "Store" && !isButtonStore {
            isButtonStore = true
        } else if node.name == "Settings" {
            toggleSettingsMenu()
        } else if node.name == "Trophy"{
            toggleTrophyMenu()
        } else if node.name == "SoundToggle" {
            toggleSound()
        } else if node.name == "MusicToggle" {
            toggleMusic()
        } else if node.name == "CloseSettings" {
            closeSettingsMenu()
        } else if node.name == "CloseTrophy" {
            closeTrophyMenu()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        
        if let parent = playButton?.parent {
            isButtonPlay = playButton.contains(touch.location(in: parent))
        }
        
        if let parent = levelsButton?.parent {
            isButtonLevels = levelsButton.contains(touch.location(in: parent))
        }
        
        if let parent = storeButton?.parent {
            isButtonStore = storeButton.contains(touch.location(in: parent))
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if isButtonPlay {
            let scene = FreePlayScene(size: view!.bounds.size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: .crossFade(withDuration: 0.5))
        }
        
        if isButtonLevels {
            let scene = LevelsScene(size: self.size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: .crossFade(withDuration: 0.5))
        }
        
        if isButtonStore {
            let scene = StoreScene(size: self.size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: .crossFade(withDuration: 0.5))
        }
    }
}



// MARK: - Setup Nodes

extension MainMenu {
    private func setupNodes() {
        SettingsMenu.setupBackground(for: self, imageName: "background")
        setupButtons()
        setupTopPanel()
        
        let topMenu = TopMenu(size: self.size)
        addChild(topMenu)
    }
    
    private func setupTopPanel() {
        let topButtonScale: CGFloat = 0.5
        let topButtonSpacing: CGFloat = 320
        let gemCount = GameDataManager.shared.gemCount

        let starPanel = SKSpriteNode(imageNamed: "panel-mainMenu")
        starPanel.setScale(topButtonScale - 0.1)
        starPanel.position = CGPoint(x: frame.minX + starPanel.size.width / 2 + topButtonSpacing - 30, y: frame.maxY - 200)
        starPanel.zPosition = 10.0
        addChild(starPanel)

        let starImage = SKSpriteNode(imageNamed: "icon-star")
        starImage.setScale(0.4)
        starImage.position = CGPoint(x: starPanel.position.x - 35, y: starPanel.position.y)
        starImage.zPosition = 11.0
        addChild(starImage)

        let starLabel = SKLabelNode(text: "\(starCount)")
        starLabel.fontName = FontName.montserrat
        starLabel.fontSize = dynamicFontSize(for: starCount)
        starLabel.fontColor = .white
        starLabel.position = CGPoint(x: starPanel.position.x + 25, y: starPanel.position.y - 20)
        starLabel.zPosition = 11.0
        addChild(starLabel)

        let gemPanel = SKSpriteNode(imageNamed: "panel-mainMenu")
        gemPanel.setScale(topButtonScale - 0.1)
        gemPanel.position = CGPoint(x: starPanel.position.x, y: starPanel.position.y - starPanel.size.height / 2 - 30)
        gemPanel.zPosition = 10.0
        addChild(gemPanel)

        let gemImage = SKSpriteNode(imageNamed: "icon-gem")
        gemImage.setScale(0.4)
        gemImage.position = CGPoint(x: gemPanel.position.x - 35, y: gemPanel.position.y)
        gemImage.zPosition = 11.0
        addChild(gemImage)

        let gemLabel = SKLabelNode(text: "\(gemCount)")
        gemLabel.fontName = FontName.montserrat
        gemLabel.fontSize = dynamicFontSize(for: gemCount)
        gemLabel.fontColor = .white
        gemLabel.position = CGPoint(x: gemPanel.position.x + 25, y: gemPanel.position.y - 20)
        gemLabel.zPosition = 11.0
        addChild(gemLabel)
    }

    private func setupButtons() {
        let desiredButtonWidth: CGFloat = 700
        let buttonSpacing: CGFloat = -70
        
        playButton = SKSpriteNode(imageNamed: "icon-play")
        let playAspectRatio = playButton.size.height / playButton.size.width
        playButton.size = CGSize(width: desiredButtonWidth, height: desiredButtonWidth * playAspectRatio)
        playButton.position = CGPoint(x: frame.midX, y: frame.midY + playButton.size.height + buttonSpacing)
        playButton.zPosition = 10.0
        playButton.name = "Play"
        addChild(playButton)
        
        levelsButton = SKSpriteNode(imageNamed: "icon-levels")
        let levelsAspectRatio = levelsButton.size.height / levelsButton.size.width
        levelsButton.size = CGSize(width: desiredButtonWidth, height: desiredButtonWidth * levelsAspectRatio)
        levelsButton.position = CGPoint(x: frame.midX, y: playButton.position.y - playButton.size.height - buttonSpacing)
        levelsButton.zPosition = 10.0
        levelsButton.name = "Levels"
        addChild(levelsButton)
        
        storeButton = SKSpriteNode(imageNamed: "icon-store")
        let storeAspectRatio = storeButton.size.height / storeButton.size.width
        storeButton.size = CGSize(width: desiredButtonWidth, height: desiredButtonWidth * storeAspectRatio)
        storeButton.position = CGPoint(x: frame.midX, y: levelsButton.position.y - levelsButton.size.height - buttonSpacing)
        storeButton.zPosition = 10.0
        storeButton.name = "Store"
        addChild(storeButton)
    }
    
    private func dynamicFontSize(for count: Int) -> CGFloat {
        switch count {
        case 0..<10:
            return 50
        case 10..<100:
            return 45
        case 100..<1000:
            return 40
        default:
            return 35
        }
    }
    
}

// MARK: - Settings Menu

extension MainMenu {
    
    private func toggleSettingsMenu() {
        if settingsMenu == nil {
            showSettingsMenu()
        } else {
            closeSettingsMenu()
        }
    }
    
    private func showSettingsMenu() {
        settingsMenu = SettingsMenu(size: self.size)
        settingsMenu!.zPosition = 200
        addChild(settingsMenu!)
    }

    private func closeSettingsMenu() {
        settingsMenu?.removeFromParent()
        settingsMenu = nil
    }

    private func toggleSound() {
        AudioSettingsManager.shared.isSoundEnabled.toggle()
        settingsMenu?.updateSettingsUI()
    }
    
    private func toggleMusic() {
        AudioSettingsManager.shared.isMusicEnabled.toggle()
        settingsMenu?.updateSettingsUI()
    }
}

// MARK: - Trophy Menu
extension MainMenu {
    
    private func toggleTrophyMenu() {
        if trophyMenu == nil {
            showTrophyMenu()
        } else {
            closeTrophyMenu()
        }
    }
    
    private func showTrophyMenu() {
        trophyMenu = TrophyMenu(size: self.size)
        trophyMenu!.zPosition = 200
        addChild(trophyMenu!)
    }

    private func closeTrophyMenu() {
        trophyMenu?.removeFromParent()
        trophyMenu = nil
    }
}

// MARK: - Audio

extension MainMenu {
    
    private func setupAudio() {
        AudioSettingsManager.shared.playBackgroundMusic(fileName: "Cosmo Ball Game Song")
    }
}

// MARK: - Animation buttons
extension MainMenu {
    
    private func updateBtn(node: SKNode, event: Bool) {
        var alpha: CGFloat = 1.0
        if event {
            alpha = 0.5
        }
        
        node.run(.fadeAlpha(to: alpha, duration: 0.1))
    }
}
   
