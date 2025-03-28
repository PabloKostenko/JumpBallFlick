import SpriteKit
import AVFoundation

class LevelsScene: SKScene {
    
    
    // MARK: - Properties
    let levelLabels = ["Level 1", "Level 2", "Level 3", "Level 4", "Level 5"]
    private var starsForLevels = [0, 0, 0, 0, 0]
    
    private let scale: CGFloat = 0.5
    private let topButtonSpacing: CGFloat = 320
    private let topButtonScale: CGFloat = 0.5
    
    private var unlockedLevels = 1
    
    private var settingsMenu: SettingsMenu?
    private var trophyMenu: TrophyMenu?
    var scoreManager: ScoreManager!
    
    var soundEffectPlayer: AVAudioPlayer?
    var musicPlayer: AVAudioPlayer?
    
    private var currentLevel = 1
    private var levelGoals: [Int] = [30, 50, 75, 100, 150]
    var starRanges: [[(Int, Int)]] = [
        [(5, 10), (13, 18), (18, 27)],
        [(10, 20), (21, 35), (36, 50)],
        [(15, 30), (31, 50), (51, 75)],
        [(20, 40), (41, 70), (71, 100)],
        [(30, 50), (51, 100), (101, 150)]
    ]
    private var platformSpeeds: [CGFloat] = [1.5, 2.0, 2.5, 3.0, 3.5]
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        starsForLevels = GameDataManager.shared.loadStars()
        unlockedLevels = GameDataManager.shared.loadUnlockedLevels()
        
        if unlockedLevels < 1 {
            unlockedLevels = 1
        }
        
        for (index, stars) in starsForLevels.enumerated() {
            if stars >= 2 && (index + 1) < levelLabels.count {
                unlockedLevels = max(unlockedLevels, index + 2)
            }
        }

        GameDataManager.shared.saveUnlockedLevels(unlockedLevels)
        updateLevelButtons()
        setupBackButton()
        setupNodes()
        setupAudio()
        setupModeSwitch()
    }



    
    // MARK: - Setup Methods
    private func setupNodes() {
        SettingsMenu.setupBackground(for: self, imageName: "background")
        let topMenu = TopMenu(size: self.size)
        addChild(topMenu)
    }
    
    private func setupBackButton() {
           let backButton = SKSpriteNode(imageNamed: "icon-back")
           backButton.setScale(scale - 0.1)
           backButton.position = CGPoint(x: frame.minX + backButton.size.width / 2 + 320, y: frame.maxY - 220)
           backButton.zPosition = 1
           backButton.name = "back"
           addChild(backButton)
       }
    
    private func setupLevelButtons() {
        let startY = frame.midY + 370
        let spacingY: CGFloat = 250
        
        for (index, level) in levelLabels.enumerated() {
            let levelNode = SKSpriteNode(imageNamed: "icon-levelPanel")
            levelNode.position = CGPoint(x: frame.midX, y: startY - CGFloat(index) * spacingY)
            levelNode.setScale(scale - 0.12)
            levelNode.zPosition = 1
            levelNode.name = "level-\(index + 1)"
            addChild(levelNode)
            
            let levelLabel = SKLabelNode(text: "Level \(index + 1)")
            levelLabel.fontName = FontName.montserrat
            levelLabel.fontSize = 107
            levelLabel.fontColor = .white
            levelLabel.position = CGPoint(x: levelNode.position.x - 160, y: levelNode.position.y - 40)
            levelLabel.zPosition = 2
            levelLabel.name = "level-\(index + 1)"
            addChild(levelLabel)
            
            if index < unlockedLevels {
                addStars(for: levelNode, stars: starsForLevels[index], levelIndex: index + 1)
            } else {
                let lockNode = SKSpriteNode(imageNamed: "icon-lock")
                lockNode.position = CGPoint(x: levelNode.position.x + 230, y: levelNode.position.y + 5)
                lockNode.setScale(scale - 0.05)
                lockNode.zPosition = 2
                lockNode.name = "level-\(index + 1)"
                addChild(lockNode)
            }
        }
    }


    private func addStars(for levelNode: SKSpriteNode, stars: Int, levelIndex: Int) {
        let starSpacing: CGFloat = 90.0
        for i in 0..<3 {
            let isFullStar = i < stars
            let starImageName = isFullStar ? "icon-star" : "icon-starEmpty"
            let starNode = SKSpriteNode(imageNamed: starImageName)
            
            let starScale = isFullStar ? 0.6 : scale - 0.1
            starNode.setScale(starScale)
            
            starNode.position = CGPoint(x: levelNode.position.x + 130 + CGFloat(i) * starSpacing, y: levelNode.position.y)
            starNode.zPosition = 2
            addChild(starNode)
        }
    }
    private func setupModeSwitch() {
        let buttonYPosition = frame.maxY - 450
        
        let freePlayButton = SKSpriteNode(imageNamed: "icon-freePlay")
        freePlayButton.position = CGPoint(x: frame.midX - 230, y: buttonYPosition)
        freePlayButton.setScale(scale - 0.1)
        freePlayButton.zPosition = 1
        freePlayButton.name = "freePlay"
        addChild(freePlayButton)
        
        let levelsLabel = SKSpriteNode(imageNamed: "icon-levelsLabel")
        levelsLabel.position = CGPoint(x: frame.midX + 230, y: buttonYPosition)
        levelsLabel.setScale(scale - 0.1)
        levelsLabel.zPosition = 1
        addChild(levelsLabel)
    }
    
    
    // MARK: - Touch Handling
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
        
        if let nodeName = node.name {
            if nodeName == "back" {
                goBackToMainMenu()
            } else if nodeName == "freePlay" {
                startFreePlay()
            } else if nodeName.starts(with: "level-") {
                let levelIndex = Int(nodeName.replacingOccurrences(of: "level-", with: "")) ?? 0
                if levelIndex <= unlockedLevels {
                    startLevel(levelIndex)
                } else {
                    if let itemButton = childNode(withName: nodeName) as? SKSpriteNode {
                        let flashRed = SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1)
                        let revertColor = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
                        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
                        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                        let colorSequence = SKAction.sequence([flashRed, revertColor])
                        let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
                        let group = SKAction.group([colorSequence, fadeSequence])
                        
                        itemButton.run(group)
                    }
                }
            } else if nodeName == "Settings" {
                toggleSettingsMenu()
            } else if nodeName == "Trophy" {
                toggleTrophyMenu()
            } else if nodeName == "SoundToggle" {
                toggleSound()
            } else if nodeName == "MusicToggle" {
                toggleMusic()
            } else if nodeName == "CloseSettings" {
                closeSettingsMenu()
            } else if nodeName == "CloseTrophy" {
                closeTrophyMenu()
            }
        }
    }


    func completeLevel(withStars stars: Int) {
        let nextLevel = currentLevel + 1
        if stars >= 2 && nextLevel <= levelLabels.count {
            if nextLevel > unlockedLevels {
                unlockedLevels = nextLevel
                GameDataManager.shared.saveUnlockedLevels(unlockedLevels)
            }
        }
        updateLevelButtons()
        goBackToMainMenu()
    }

    private func updateLevelButtons() {
        removeAllLevelNodes()
        setupLevelButtons()
    }

    private func removeAllLevelNodes() {
        for node in children {
            if node.name?.starts(with: "level-") == true {
                node.removeFromParent()
            }
        }
    }

    private func startLevel(_ level: Int) {
        if level <= unlockedLevels {
            currentLevel = level
            setupLevelDifficulty(for: level)
            
            let gameScene = LevelsGameScene(size: view!.bounds.size)
            gameScene.scaleMode = .aspectFill
            gameScene.currentLevel = level
            gameScene.levelGoal = levelGoals[level - 1]
            gameScene.platformSpeed = platformSpeeds[level - 1]
            gameScene.starRanges = starRanges
            view?.presentScene(gameScene, transition: .crossFade(withDuration: 0.5))
        }
    }


    
    private func setupLevelDifficulty(for level: Int) {
        let speed = platformSpeeds[level - 1]
        let starRangesForLevel = starRanges[level - 1]
    }
    
    private func startFreePlay() {
        let scene = FreePlayScene(size: view!.bounds.size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: .crossFade(withDuration: 0.5))
    }
    
    private func goBackToMainMenu() {
        let scene = MainMenu(size: self.size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: .crossFade(withDuration: 0.5))
    }
}
// MARK: - Settings Menu
extension LevelsScene {
    
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
extension LevelsScene {
    
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

extension LevelsScene {
    
    private func setupAudio() {
        AudioSettingsManager.shared.playBackgroundMusic(fileName: "Cosmo Ball Game Song")
    }
}

   
