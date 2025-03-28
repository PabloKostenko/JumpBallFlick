import SpriteKit

var gemCountPanel: Int = 0

class FreePlayScene: SKScene, SKPhysicsContactDelegate, PlatformManagerDelegate, ScoreManagerDelegate {
    
    var isFreePlayMode: Bool {
        return true
    }
    
    private var posY: CGFloat = 0.0
    var player: SKSpriteNode!
    private var isDragging = false
    private var isStuckToPlatform = false
    private var startTouchPoint: CGPoint?
    private var launchVector = CGVector(dx: 0, dy: 0)
    private var isGameOver = false
    var playerRadius: CGFloat = 30.0
    var scoreManager: ScoreManager!
    private var platformSpeed: CGFloat = 2.0
    private var isJumping = false
    private var isGamePaused = false
    private var platformManager: PlatformManager!

    private let worldNode = SKNode()
    private let hudNode = HUDNode()
    
    var firstTap = true
    var lastPlatformPosition: CGPoint?
    
    private let notifKey = "NotifKey"

    var launchStrengthMultiplier: CGFloat = 4
    var currentPlatform: PlatformNode?

    private var isMagnetActive = false
    private var shieldActive = false
    private var shieldUsed = false
    private var purchasedTools: Set<String> = GameDataManager.shared.purchasedTools

    let scoreKey = "FreePlayScoreKey"
    private var gemLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setupNodes()
        setupPauseButton()
        platformManager = PlatformManager(scene: self, platformSpeed: platformSpeed)
        platformManager.createPlatforms()
        createPlayer()
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = false
        placePlayerOnFirstPlatform()
        scoreManager = ScoreManager(scene: self, hudNode: self, scoreKey: scoreKey)
        activatePurchasedTools()
        showWelcomePanelIfNeeded()
        setupAudio()

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
        if let platform = currentPlatform, isStuckToPlatform {
            // Якщо платформа нижче певної межі, від'єднуємо мʼяч
            if platform.position.y + platform.size.height / 2 < 0 {
                isStuckToPlatform = false
                player.physicsBody?.affectedByGravity = true
            }
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

        if let currentPlatform = currentPlatform, currentPlatform.isBeingRemoved {
            self.currentPlatform = nil
            self.isStuckToPlatform = false
            self.player.physicsBody?.affectedByGravity = true
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
    
    private func gameOver() {
        isGameOver = true
        player.removeFromParent()
        scoreManager.handleGameOver()
        gemCountPanel = 0
        let storeScene = StoreScene(size: self.size)
        storeScene.resetPurchasedTools()
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
        hudNode.updateScore(score)
    }

    func setupGameOver(_ fontSize: CGFloat, _ highScore: Int, _ padding: CGFloat) {
        hudNode.setupGameOver(Int(fontSize), highScore, Int(padding))
    }

}

// MARK: - Physics Contact Handling
extension FreePlayScene {
    
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
                            guard let strongSelf = self else { return }
                            
                            if strongSelf.currentPlatform?.platformId == platformNode.platformId {
                                strongSelf.player.physicsBody?.affectedByGravity = true
                                strongSelf.isStuckToPlatform = false
                                strongSelf.currentPlatform = nil
                            }
                        },
                        SKAction.run {
                            platformNode.removePlatform()
                        }
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
                    gemCountPanel += 1
                    GameDataManager.shared.gemCount += 1
                    gemLabel.text = "\(GameDataManager.shared.gemCount)"
                    AudioSettingsManager.shared.playGameSound(fileName: SoundName.superScore, in: self)
                    superScoreNode.removeFromParent()
                }
            }
        default:
            break
        }
    }
}

// MARK: - Touch Handling
extension FreePlayScene {
    
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
                    AudioSettingsManager.shared.playGameSound(fileName: SoundName.jump, in: self)
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
extension FreePlayScene {
    private func setupNodes() {
        SettingsMenu.setupBackground(for: self, imageName: "background")
        setupPhysics()
        createPlayer()
        createGemLabel()
        createWalls()
        hudNode.freePlayScene = self
        addChild(hudNode)
        hudNode.skView = view
        hudNode.setupTopScore()
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
    
    private func createGemLabel() {
        let gemPanel = SKSpriteNode(imageNamed: "panel-mainMenu")
        gemPanel.setScale(0.17)
        gemPanel.position = CGPoint(x: frame.maxX - 50, y: frame.maxY - gemPanel.size.height / 2 - 20)
        gemPanel.zPosition = 10.0
        addChild(gemPanel)

        let gemImage = SKSpriteNode(imageNamed: "icon-gem")
        gemImage.setScale(0.17)
        gemImage.position = CGPoint(x: gemPanel.position.x + 15, y: gemPanel.position.y - 1)
        gemImage.zPosition = 11.0
        addChild(gemImage)
        
        gemLabel = SKLabelNode(text: "\(GameDataManager.shared.gemCount)")
        gemLabel.fontName = FontName.montserrat
        gemLabel.fontSize = dynamicFontSize(for: GameDataManager.shared.gemCount)
        gemLabel.fontColor = .white
        gemLabel.position = CGPoint(x: gemPanel.position.x - 12, y: gemPanel.position.y - 9)
        gemLabel.zPosition = 11.0
        addChild(gemLabel)
    }
    
    private func dynamicFontSize(for count: Int) -> CGFloat {
        switch count {
        case 0..<10:
            return 23
        case 10..<100:
            return 20
        case 100..<1000:
            return 18
        default:
            return 13
        }
    }
}

// MARK: - Miscellaneous Functions
extension FreePlayScene {
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
        let gemNode = GemNode()
        let gemWidth = gemNode.calculateAccumulatedFrame().size.width
        let randomX = CGFloat.random(in: gemWidth / 2...(frame.width - gemWidth / 2))
        let startY = frame.height + gemNode.calculateAccumulatedFrame().size.height
        gemNode.position = CGPoint(x: randomX, y: startY)
        addChild(gemNode)

        let moveDown = SKAction.moveTo(y: -gemNode.frame.height, duration: 5.0)
        let remove = SKAction.removeFromParent()
        gemNode.run(SKAction.sequence([moveDown, remove]))
        gemNode.bounce()
    }
}

extension FreePlayScene {

    private func setupAudio() {
        AudioSettingsManager.shared.playBackgroundMusic(fileName: "Cosmo Ball Game Song-2")
    }
}
