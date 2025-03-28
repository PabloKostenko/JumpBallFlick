import SpriteKit

class LevelsGameScene: SKScene, SKPhysicsContactDelegate, PlatformManagerDelegate, ScoreManagerDelegate {
    
    var isFreePlayMode: Bool {
        return false
    }
    
    var collectedStars = 0
    private var posY: CGFloat = 0.0
    var player: SKSpriteNode!
    private var isDragging = false
    private var isStuckToPlatform = false
    private var startTouchPoint: CGPoint?
    private var launchVector = CGVector(dx: 0, dy: 0)
    private var isGameOver = false
    var playerRadius: CGFloat = 30.0
    var scoreManager: ScoreManager!
    var platformSpeed: CGFloat = 2.0
    private var isJumping = false
    private var isGamePaused = false
    private var platformManager: PlatformManager!

    private let worldNode = SKNode()
    private let hudNode = HUDNode()
    
    var firstTap = true
    var lastPlatformPosition: CGPoint?

    private let jumpSound = SKAction.playSoundFileNamed(SoundName.jump, waitForCompletion: false)
    private let superScoreSound = SKAction.playSoundFileNamed(SoundName.superScore, waitForCompletion: false)
    
    private let notifKey = "NotifKey"

    var launchStrengthMultiplier: CGFloat = 4
    var currentPlatform: PlatformNode?

    private var isMagnetActive = false
    private var shieldActive = false
    private var shieldUsed = false
    private var purchasedTools: Set<String> = GameDataManager.shared.purchasedTools

    let scoreKey = "FreePlayScoreKey"
    let earnedStars = "earnedStarsKey"

    var starLabel: SKLabelNode!
    
    var currentLevel: Int = 1
    var levelGoal: Int = 0
    var starRanges: [[(Int, Int)]] = []
    private var starGenerationThresholds: [Int] = []
    var generatedStars = 0


    
    override func didMove(to view: SKView) {

        
        setupNodes()
        setupPauseButton()
        setupAudio()
        
        if currentLevel > 0 && currentLevel <= starRanges.count {
            let starRangesForLevel = starRanges[currentLevel - 1]
            starGenerationThresholds = starRangesForLevel.map { $0.0 }
        }
        
        let starsForLevels = GameDataManager.shared.loadStars()
        let starsEarnedForCurrentLevel = starsForLevels[currentLevel - 1]
        starLabel.text = "\(starsEarnedForCurrentLevel)/3"
        
        collectedStars = 0
        generatedStars = 0
        
        platformManager = PlatformManager(scene: self, platformSpeed: platformSpeed)
        platformManager.createPlatforms()
        scoreManager = ScoreManager(scene: self, hudNode: self, scoreKey: scoreKey)
        scoreManager.resetScore()
        scoreManager.levelGoal = levelGoal
        
        createPlayer()
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = false
        placePlayerOnFirstPlatform()
        

        activatePurchasedTools()
        showWelcomePanelIfNeeded()

        run(SKAction.wait(forDuration: 0.1)) { [weak self] in
            guard let self = self else { return }
            self.player.physicsBody?.affectedByGravity = true
            self.player.physicsBody?.isDynamic = true
            self.physicsWorld.speed = 1.0
            self.isGamePaused = false
        }
    }


    func createPlayer() {
        player = PlayerNode()
        addChild(player)
    }

    func createWalls() {
        let leftWall = SKNode()
        leftWall.position = CGPoint(x: 0, y: frame.midY)
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: -frame.height / 2), to: CGPoint(x: 0, y: frame.height / 2))
        leftWall.physicsBody?.categoryBitMask = PhysicsCategories.Wall
        addChild(leftWall)

        let rightWall = SKNode()
        rightWall.position = CGPoint(x: frame.width, y: frame.midY)
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: -frame.height / 2), to: CGPoint(x: 0, y: frame.height / 2))
        rightWall.physicsBody?.categoryBitMask = PhysicsCategories.Wall
        addChild(rightWall)

        let topBoundary = SKNode()
        topBoundary.position = CGPoint(x: frame.midX, y: frame.height)
        topBoundary.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -frame.width / 2, y: 0), to: CGPoint(x: frame.width / 2, y: 0))
        topBoundary.physicsBody?.categoryBitMask = PhysicsCategories.Wall
        addChild(topBoundary)
    }

    override func update(_ currentTime: TimeInterval) {
        if isGameOver || isGamePaused { return }
        
        platformManager.movePlatforms()
        handleMagnetEffect()
        if scoreManager.getScore() >= levelGoal {
            gameOver()
            return
        }

        if let platform = currentPlatform, platform.platformType == .moving, isStuckToPlatform {
            let currentPlatformPosition = platform.position
            if let lastPosition = lastPlatformPosition {
                let deltaX = currentPlatformPosition.x - lastPosition.x
                player.position.x += deltaX
            }
            lastPlatformPosition = currentPlatformPosition
        } else {
            lastPlatformPosition = nil
        }

        if player.position.y < 0 {
            if shieldActive && !shieldUsed {
                shieldUsed = true
                player.position = CGPoint(x: frame.midX, y: frame.height - 100)
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.affectedByGravity = true
            } else {
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.position = CGPoint(x: frame.midX, y: frame.height - 100)
                player.physicsBody?.affectedByGravity = true
                deactivateTools()
                gameOver()
            }
        }
    }


    func handlePlayerContactWithPlatform(platform: PlatformNode) {
        guard !isStuckToPlatform else { return }

        if player.position.y >= platform.position.y + player.size.height / 2 {
            let playerCenterX = player.position.x
            let platformLeftEdge = platform.position.x - platform.size.width / 2
            let platformRightEdge = platform.position.x + platform.size.width / 2
            let stickinessZone = (platformRightEdge - platformLeftEdge) * 0.9
            let leftStickyBound = platform.position.x - stickinessZone / 2
            let rightStickyBound = platform.position.x + stickinessZone / 2

            if playerCenterX >= leftStickyBound && playerCenterX <= rightStickyBound {
                player.position = CGPoint(x: player.position.x, y: platform.position.y + platform.size.height / 2 + player.size.height / 2)
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.linearDamping = 10
                player.physicsBody?.affectedByGravity = false
                isStuckToPlatform = true
                currentPlatform = platform
                isJumping = false
            }
        }
    }

    private func pauseGame() {
        isGamePaused = true
        self.isPaused = true
        hudNode.setupGamePause()
    }
    
    func resumeGame() {
        isGamePaused = false
        self.isPaused = false
        hudNode.removePauseMenu()
    }
    
    func gameOver() {
        isGameOver = true
        player.removeFromParent()
        scoreManager.handleGameOver()
        scoreManager.resetScore()
        
        var starsForLevels = GameDataManager.shared.loadStars()
        let starsEarnedThisGame = collectedStars
        let previouslyEarnedStars = starsForLevels[currentLevel - 1]
        let totalEarnedStars = max(previouslyEarnedStars, starsEarnedThisGame)
        
        starsForLevels[currentLevel - 1] = totalEarnedStars
        GameDataManager.shared.saveStars(starsForLevels)

        
        switch totalEarnedStars {
        case 3:
            hudNode.setupGameSuccessLevels()
        case 2:
            hudNode.setupGameNotSuccessLevels()
        case 1:
            hudNode.setupGameOverStarLevels()
        default:
            hudNode.setupGameOverLevels()
        }
        
        let newScene = StoreScene(size: self.size)
        newScene.resetPurchasedTools()
    }




    // MARK: - Magnet and Shield
    func activateMagnet() {
        isMagnetActive = true
        run(SKAction.wait(forDuration: 10.0)) { [weak self] in
            self?.isMagnetActive = false
        }
    }

    func activateShield() {
        shieldActive = true
        shieldUsed = false
        run(SKAction.wait(forDuration: 10.0)) { [weak self] in
            self?.shieldActive = false
        }
    }

    private func handleMagnetEffect() {
        guard isMagnetActive else { return }
        for node in children {
            if let gemNode = node as? GemNode {
                let distance = hypot(player.position.x - gemNode.position.x, player.position.y - gemNode.position.y)
                if distance < 300 {
                    let moveAction = SKAction.move(to: player.position, duration: 0.5)
                    gemNode.run(moveAction)
                }
            }
        }
    }
    
    private func activatePurchasedTools() {
        if purchasedTools.contains("magnet") {
            activateMagnet()
        }
        if purchasedTools.contains("shield") {
            activateShield()
        }
    }

    private func deactivateTools() {
        isMagnetActive = false
        shieldActive = false
        shieldUsed = false
    }

    // MARK: - ScoreManagerDelegate Methods
    func updateScore(_ score: Int) {
        if generatedStars < 3 &&
            generatedStars < starGenerationThresholds.count &&
            score >= starGenerationThresholds[generatedStars] {
            
            addGemRandomly()
            generatedStars += 1
            UserDefaults.standard.set(collectedStars, forKey: "earnedStarsKey")
        }
    }


    func setupGameOver(_ fontSize: CGFloat, _ highScore: Int, _ padding: CGFloat) {
        if isFreePlayMode {
            hudNode.setupGameOver(Int(fontSize), highScore, Int(padding))
        }
    }

    

}

// MARK: - Physics Contact Handling
extension LevelsGameScene {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
            
        let playerBody: SKPhysicsBody
        let otherBody: SKPhysicsBody
            
        if contactA.categoryBitMask == PhysicsCategories.Player {
            playerBody = contactA
            otherBody = contactB
        } else if contactB.categoryBitMask == PhysicsCategories.Player {
            playerBody = contactB
            otherBody = contactA
        } else {
            return
        }
        
        if otherBody.categoryBitMask == PhysicsCategories.Platform,
           let platformNode = otherBody.node as? PlatformNode {
            if player.position.y > platformNode.position.y + platformNode.size.height / 2 {
                handlePlayerContactWithPlatform(platform: platformNode)
                if platformNode.platformType == .withHole {
                    platformNode.run(SKAction.sequence([
                        SKAction.wait(forDuration: 1.0),
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.run { [weak self] in
                            if self?.currentPlatform?.platformId == platformNode.platformId {
                                self?.player.physicsBody?.affectedByGravity = true
                                self?.isStuckToPlatform = false
                            }
                        },
                        SKAction.removeFromParent()
                    ]))
                }
            }
        }

        switch otherBody.categoryBitMask {
        case PhysicsCategories.Platform:
            if let platformNode = otherBody.node as? PlatformNode {
                handlePlayerContactWithPlatform(platform: platformNode)
                return
            }
            
        case PhysicsCategories.Score:
            if let scoreNode = otherBody.node {
                scoreManager.addScore(points: 1)
                scoreNode.removeFromParent()
            }
            
        case PhysicsCategories.SuperScore:
            if contactA.categoryBitMask == PhysicsCategories.SuperScore || contactB.categoryBitMask == PhysicsCategories.SuperScore {
                if let superScoreNode = (contactA.categoryBitMask == PhysicsCategories.SuperScore ? contactA.node : contactB.node) {
                    collectedStars += 1
                    starLabel.text = "\(collectedStars)/3"
                    run(superScoreSound)
                    superScoreNode.removeFromParent()
                }
            }
        default:
            break
        }
    }
}

// MARK: - Touch Handling
extension LevelsGameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            startTouchPoint = touch.location(in: self)
            isDragging = true
            let node = atPoint(startTouchPoint!)

            if node.name == "Pause" {
                pauseGame()
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let startTouch = startTouchPoint {
            let currentTouch = touch.location(in: self)
            let dx = currentTouch.x - startTouch.x
            let dy = currentTouch.y - startTouch.y
            launchVector = CGVector(dx: dx * -1, dy: dy * -1)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGamePaused {
            return
        }
        
        if isDragging {
            isDragging = false

            if !isJumping {
                if isStuckToPlatform {
                    player.physicsBody?.linearDamping = 0.4
                    player.physicsBody?.affectedByGravity = true
                    isStuckToPlatform = false
                }

                if let currentPlatform = currentPlatform {
                    currentPlatform.physicsBody?.categoryBitMask = 0
                    let scaledLaunchVector = CGVector(dx: launchVector.dx * launchStrengthMultiplier, dy: launchVector.dy * launchStrengthMultiplier)
                    player.physicsBody?.applyImpulse(scaledLaunchVector)
                    isJumping = true
                    run(jumpSound)
                    let wait = SKAction.wait(forDuration: 0.2)
                    let enableContact = SKAction.run { [weak self] in
                        currentPlatform.physicsBody?.categoryBitMask = PhysicsCategories.Platform
                    }
                    run(SKAction.sequence([wait, enableContact]))
                }
            }
        }
    }
}

// MARK: - Setup Nodes and UI
extension LevelsGameScene {
    private func setupNodes() {
        SettingsMenu.setupBackground(for: self, imageName: "background")
        setupPhysics()
        createPlayer()
        createStarLabel()
        createWalls()
        addChild(hudNode)
        hudNode.skView = view
        hudNode.levelsGameScene = self
    }
    
    private func setupPhysics() {
       physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
       physicsWorld.contactDelegate = self
       backgroundColor = .white
    }
    
    private func setupPauseButton() {
        let pauseButton = SKSpriteNode(imageNamed: "icon-pause")
        pauseButton.setScale(0.2)
        pauseButton.position = CGPoint(x: frame.minX + pauseButton.size.width / 2 , y: frame.maxY - pauseButton.size.height / 2 - 20)
        pauseButton.zPosition = 1
        pauseButton.name = "Pause"
        addChild(pauseButton)
    }
    
    func createStarLabel() {
        if starLabel != nil { return }
        
        let starPanel = SKSpriteNode(imageNamed: "panel-mainMenu")
        starPanel.setScale(0.17)
        starPanel.position = CGPoint(x: frame.maxX - 50, y: frame.maxY - starPanel.size.height / 2 - 20)
        starPanel.zPosition = 10.0
        addChild(starPanel)

        let starImage = SKSpriteNode(imageNamed: "icon-star")
        starImage.setScale(0.17)
        starImage.position = CGPoint(x: starPanel.position.x + 15, y: starPanel.position.y - 1)
        starImage.zPosition = 11.0
        addChild(starImage)
        
        starLabel = SKLabelNode(text: "\(collectedStars)/3")
        starLabel.fontName = FontName.montserrat
        starLabel.fontSize = 20
        starLabel.fontColor = .white
        starLabel.position = CGPoint(x: starPanel.position.x - 12, y: starPanel.position.y - 9)
        starLabel.zPosition = 11.0
        addChild(starLabel)
    }

    
}

// MARK: - Miscellaneous Functions
extension LevelsGameScene {
    func showWelcomePanelIfNeeded() {
        if !UserDefaults.standard.bool(forKey: notifKey) {
            UserDefaults.standard.set(false, forKey: notifKey)
            hudNode.setupPanel(btnName: "icon-welcome")
        }
    }
    
    func placePlayerOnFirstPlatform() {
        if let firstPlatform = platformManager.getFirstPlatform() {
            player.position = CGPoint(x: firstPlatform.position.x, y: firstPlatform.position.y + playerRadius + 10)
            if firstPlatform.platformType == .withHole {
                firstPlatform.platformType = .normal
            }
        }
    }
    
    func addGemRandomly() {
        let starNode = StarNode()
        let starWidth = starNode.calculateAccumulatedFrame().size.width
        let randomX = CGFloat.random(in: starWidth / 2...(frame.width - starWidth / 2))
        let startY = frame.height - starNode.calculateAccumulatedFrame().size.height / 2
        starNode.position = CGPoint(x: randomX, y: startY)
        addChild(starNode)
        
        let moveDown = SKAction.moveTo(y: -starNode.frame.height, duration: 5.0)
        let remove = SKAction.removeFromParent()
        starNode.run(SKAction.sequence([moveDown, remove]))
        starNode.bounce()
    }

    
    func calculateStarsEarned(score: Int) -> Int {
        guard currentLevel > 0 && currentLevel <= starRanges.count else { return 0 }
        
        let starRangesForLevel = starRanges[currentLevel - 1]
        
        for (index, range) in starRangesForLevel.enumerated() {
            if score >= range.0 && score <= range.1 {
                return index + 1
            }
        }
        return 0
    }
}

// MARK: - Audio

extension LevelsGameScene {

    private func setupAudio() {
        AudioSettingsManager.shared.playBackgroundMusic(fileName: "Cosmo Ball Game Song-2")
    }
}
