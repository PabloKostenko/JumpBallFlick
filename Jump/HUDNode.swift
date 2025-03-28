import SpriteKit

class HUDNode: SKNode {
    
    //MARK: - Properties
    private var topScoreShape: SKShapeNode!
    private var topScoreLbl: SKLabelNode!
    private var gameOverShape: SKShapeNode!
    private var gameOverNode: SKSpriteNode!
    private var menuNode: SKSpriteNode!
    private var restartNode: SKSpriteNode!
    private var resumeNode: SKSpriteNode!
    private var scoreTitleLbl: SKLabelNode!
    private var scoreLbl: SKLabelNode!
    private var highScoreTitleLbl: SKLabelNode!
    private var highScoreLbl: SKLabelNode!
    private var continueNode: SKSpriteNode!
    private var nextNode: SKSpriteNode!
    private var panelNode: SKSpriteNode!
    private var panelTitleLbl: SKLabelNode!
    private var panelSubLbl: SKLabelNode!
    
    var freePlayScene: FreePlayScene?
    var mainMenuScene: MainMenu?
    var levelsGameScene: LevelsGameScene?
    
    var skView: SKView!
    
    
    private var isMenu = false {
        didSet {
            updateBtn(node: menuNode, event: isMenu)
        }
    }
    
    private var isRestart = false {
        didSet {
            updateBtn(node: restartNode, event: isRestart)
        }
    }
    
    private var isResume = false {
        didSet {
            updateBtn(node: resumeNode, event: isResume)
        }
    }
    
    private var isNext = false {
        didSet {
            updateBtn(node: nextNode, event: isNext)
        }
    }
    
    private var isPanel = false {
        didSet {
            updateBtn(node: panelNode, event: isPanel)
        }
    }
    
    //MARK: - Initializes
    override init() {
        super.init()
        setupTopScore()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))

        if node.name == "Home" && !isMenu {
            isMenu = true
        }

        if node.name == "PlayAgain" && !isRestart {
            isRestart = true
        }

        if node.name == "Resume" && !isResume {
            isResume = true
        }

        if node.name == "Next" && !isNext {
            isNext = true
        }

        if node.name == "Panel" && !isPanel {
            isPanel = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let screenSize = skView?.bounds.size ?? CGSize(width: screenWidth, height: screenHeight)
        let currentSceneSize = SceneSizeManager.shared.sceneSize

        if isMenu {
            let scene = MainMenu(size: currentSceneSize)
            scene.scaleMode = .aspectFill
            skView?.presentScene(scene, transition: .crossFade(withDuration: 1.5))
        }
        
        if isResume {
            isResume = false
            removeNode()
            freePlayScene?.resumeGame()
            levelsGameScene?.resumeGame()
        }
        
        if isRestart {
            isRestart = false
            if let _ = freePlayScene {
                let scene = FreePlayScene(size: screenSize)
                scene.scaleMode = .aspectFill
                skView.presentScene(scene, transition: .crossFade(withDuration: 1.5))
            }
            
            if let _ = levelsGameScene {
                if let currentLevel = levelsGameScene?.currentLevel, let currentStarRanges = levelsGameScene?.starRanges {
                    let scene = LevelsGameScene(size: screenSize)
                    scene.scaleMode = .aspectFill
                    scene.currentLevel = currentLevel
                    scene.starRanges = currentStarRanges
                    scene.collectedStars = 0
                    scene.generatedStars = 0
                    
                    let starsForLevels = GameDataManager.shared.loadStars()
                    let starsEarnedForCurrentLevel = starsForLevels[currentLevel - 1]
                    scene.createStarLabel()
                    scene.starLabel.text = "\(starsEarnedForCurrentLevel)/3"
                    let levelGoals = [30, 50, 75, 100, 150]
                    scene.levelGoal = levelGoals[currentLevel - 1]
                    skView.presentScene(scene, transition: .crossFade(withDuration: 1.5))
                }
            }
        }

        if isNext {
            isNext = false
            if let currentLevel = levelsGameScene?.currentLevel {
                let unlockedLevels = GameDataManager.shared.loadUnlockedLevels()
                let nextLevel = currentLevel + 1
                let maxLevels = 5
                
                if nextLevel <= maxLevels, nextLevel <= unlockedLevels {
                    let nextScene = LevelsGameScene(size: screenSize)
                    nextScene.currentLevel = nextLevel
                    nextScene.scaleMode = .aspectFill
                    let levelGoals = [30, 50, 75, 100, 150]
                    nextScene.levelGoal = levelGoals[nextLevel - 1]
                    skView?.presentScene(nextScene, transition: .crossFade(withDuration: 1.5))
                } else {
                    if let itemButton = childNode(withName: "Next") as? SKSpriteNode {
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
            }
        }



        
        if isPanel {
            isPanel = false
            removeNode()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        
        if let parent = menuNode?.parent {
            isMenu = menuNode.contains(touch.location(in: parent))
        }
        
        if let parent = resumeNode?.parent {
            isResume = resumeNode.contains(touch.location(in: parent))
        }

        if let parent = restartNode?.parent {
            isRestart = restartNode.contains(touch.location(in: parent))
        }
        
        if let parent = nextNode?.parent {
            isNext = nextNode.contains(touch.location(in: parent))
        }

        if let parent = panelNode?.parent {
            isPanel = panelNode.contains(touch.location(in: parent))
        }
    }
}

//MARK: - Setups

extension HUDNode {
    
    private func updateBtn(node: SKNode, event: Bool) {
        var alpha: CGFloat = 1.0
        if event {
            alpha = 0.5
        }
        
        node.run(.fadeAlpha(to: alpha, duration: 0.1))
    }
    
     func setupTopScore() {
        guard let _ = freePlayScene else { return }
        let screenSize = UIScreen.main.bounds.size
        let scoreY: CGFloat = screenSize.height * 0.9
        
        topScoreShape = SKShapeNode(rectOf: CGSize(width: 110, height: 45), cornerRadius: 8.0)
        topScoreShape.fillColor = UIColor(hex: 0x000000, alpha: 0.5)
        topScoreShape.zPosition = 20.0
        topScoreShape.position = CGPoint(x: screenSize.width / 2, y: scoreY + 13)
        addChild(topScoreShape)
        
        topScoreLbl = SKLabelNode(fontNamed: FontName.montserrat)
        topScoreLbl.fontSize = 40.0
        topScoreLbl.text = "0"
        topScoreLbl.fontColor = .white
        topScoreLbl.zPosition = 25.0
        topScoreLbl.position = CGPoint(x: 0, y: -topScoreLbl.frame.height / 2)
        topScoreShape.addChild(topScoreLbl)
    }
    
    func updateScore(_ score: Int) {
        topScoreLbl.text = "\(score)"
        topScoreLbl.run(.sequence([
            .scale(to: 1.3, duration: 0.1),
            .scale(to: 1.0, duration: 0.1),
        ]))
    }

    private func removeNode() {
        gameOverShape?.removeFromParent()
        gameOverNode?.removeFromParent()
        continueNode?.removeFromParent()
        nextNode?.removeFromParent()
        panelNode?.removeFromParent()
        panelTitleLbl?.removeFromParent()
        panelSubLbl?.removeFromParent()
    }
}

//MARK: - GameOver

extension HUDNode {

    private func createGameOverShape() {
        let screenSize = UIScreen.main.bounds.size
        gameOverShape = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: screenSize.height))
        gameOverShape.zPosition = 49.0
        gameOverShape.fillColor = UIColor(hex: 0x000000, alpha: 0.7)
        addChild(gameOverShape)
    }

    private func createGamePanel(_ name: String) {
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)
        gameOverNode = SKSpriteNode(imageNamed: name)
        gameOverNode.setScale(scale * 0.15)
        gameOverNode.zPosition = 50.0
        gameOverNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        addChild(gameOverNode)
    }

    func setupGameOver(_ score: Int, _ highScore: Int, _ earnedCrystals: Int) {
        createGameOverShape()
        isUserInteractionEnabled = true
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)
        createGamePanel("panel-freePlay")

        // SCORE
        let scoreTitleLbl = SKLabelNode(fontNamed: FontName.montserrat)
        scoreTitleLbl.fontSize = 30.0 * scale
        scoreTitleLbl.text = "Score:"
        scoreTitleLbl.fontColor = .white
        scoreTitleLbl.zPosition = 55.0
        scoreTitleLbl.position = CGPoint(x: screenSize.width / 2, y: gameOverNode.position.y + gameOverNode.size.height * 0.27)
        addChild(scoreTitleLbl)
        
        let scoreLbl = SKLabelNode(fontNamed: FontName.montserrat)
        scoreLbl.fontSize = 30.0 * scale
        scoreLbl.text = "\(globalScore)"
        scoreLbl.fontColor = .white
        scoreLbl.zPosition = 55.0
        scoreLbl.position = CGPoint(x: screenSize.width / 2, y: scoreTitleLbl.position.y - scoreTitleLbl.frame.height - 10)
        addChild(scoreLbl)

        if globalScore >= highScore {
            let trophyIcon = SKSpriteNode(imageNamed: "cup")
            trophyIcon.setScale(scale * 0.15)
            trophyIcon.zPosition = 55.0
            trophyIcon.position = CGPoint(x: scoreLbl.position.x + scoreLbl.frame.width - 5, y: scoreLbl.position.y + 12)
            addChild(trophyIcon)
        }

        // HIGHSCORE
        let highScoreTitleLbl = SKLabelNode(fontNamed: FontName.montserrat)
        highScoreTitleLbl.fontSize = 30.0 * scale
        highScoreTitleLbl.text = "Highscore:"
        highScoreTitleLbl.fontColor = .white
        highScoreTitleLbl.zPosition = 55.0
        highScoreTitleLbl.position = CGPoint(x: screenSize.width / 2, y: scoreLbl.position.y - scoreLbl.frame.height  - 8)
        addChild(highScoreTitleLbl)
        
        let highScoreLbl = SKLabelNode(fontNamed: FontName.montserrat)
        highScoreLbl.fontSize = 30.0 * scale
        highScoreLbl.text = "\(highScore)"
        highScoreLbl.fontColor = .white
        highScoreLbl.zPosition = 55.0
        highScoreLbl.position = CGPoint(x: screenSize.width / 2, y: highScoreTitleLbl.position.y - highScoreTitleLbl.frame.height - 3)
        addChild(highScoreLbl)

        let highScoreTrophyIcon = SKSpriteNode(imageNamed: "cup")
        highScoreTrophyIcon.setScale(scale * 0.15)
        highScoreTrophyIcon.zPosition = 55.0
        highScoreTrophyIcon.position = CGPoint(x: highScoreLbl.position.x + highScoreLbl.frame.width - 5, y: highScoreLbl.position.y + 12)
        addChild(highScoreTrophyIcon)

        // EARNED
        let earnedTitleLbl = SKLabelNode(fontNamed: FontName.montserrat)
        earnedTitleLbl.fontSize = 30.0 * scale
        earnedTitleLbl.text = "Earned:"
        earnedTitleLbl.fontColor = .white
        earnedTitleLbl.zPosition = 55.0
        earnedTitleLbl.position = CGPoint(x: screenSize.width / 2, y: highScoreLbl.position.y - highScoreLbl.frame.height - 10)
        addChild(earnedTitleLbl)
        
        let earnedCrystalsLbl = SKLabelNode(fontNamed: FontName.montserrat)
        earnedCrystalsLbl.fontSize = 30.0 * scale
        earnedCrystalsLbl.text = "\(gemCountPanel)"
        earnedCrystalsLbl.fontColor = .white
        earnedCrystalsLbl.zPosition = 55.0
        earnedCrystalsLbl.position = CGPoint(x: screenSize.width / 2 - 5, y: earnedTitleLbl.position.y - earnedTitleLbl.frame.height - 7)
        addChild(earnedCrystalsLbl)

        let crystalIcon = SKSpriteNode(imageNamed: "icon-gem")
        crystalIcon.setScale(scale * 0.25)
        crystalIcon.zPosition = 55.0
        crystalIcon.position = CGPoint(x: earnedCrystalsLbl.position.x + earnedCrystalsLbl.frame.width + 8, y: earnedCrystalsLbl.position.y + 12)
        addChild(crystalIcon)

        restartNode = SKSpriteNode(imageNamed: "icon-restart")
        restartNode.setScale(scale * 0.15)
        restartNode.zPosition = 55.0
        restartNode.position = CGPoint(x: screenSize.width / 2, y: earnedCrystalsLbl.position.y - earnedCrystalsLbl.frame.height - 25)
        restartNode.name = "PlayAgain"
        addChild(restartNode)
        
        menuNode = SKSpriteNode(imageNamed: "icon-menu")
        menuNode.setScale(scale * 0.15)
        menuNode.zPosition = 55.0
        menuNode.position = CGPoint(x: screenSize.width / 2, y: restartNode.position.y - restartNode.frame.height + 23)
        menuNode.name = "Home"
        addChild(menuNode)
    }
}

//MARK: - Notif

extension HUDNode {
    func setupPanel(btnName: String) {
        
        isUserInteractionEnabled = true
        let screenSize = UIScreen.main.bounds.size
        _ = min(screenSize.width / 375.0, screenSize.height / 812.0)
        
        panelNode = SKSpriteNode(imageNamed: btnName)
        panelNode.setScale(0.15)
        panelNode.zPosition = 55.0
        panelNode.position = CGPoint(
            x: screenSize.width / 2,
            y: screenSize.height / 2 + screenSize.height / 4
        )
        panelNode.name = "Panel"
        addChild(panelNode)
        
        let waitAction = SKAction.wait(forDuration: 1.5)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let removeAction = SKAction.removeFromParent()
        
        panelNode.run(SKAction.sequence([waitAction, fadeOutAction, removeAction]))
    }
}

//MARK: - Pause

extension HUDNode {

    private func createPausePanel(_ name: String) {
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)

        gameOverNode = SKSpriteNode(imageNamed: name)
        gameOverNode.setScale(scale * 0.15)
        gameOverNode.zPosition = 50.0
        gameOverNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        addChild(gameOverNode)
    }

    func setupGamePause() {
        createGameOverShape()

        isUserInteractionEnabled = true
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)
        createGamePanel("panel-pause")

        resumeNode = SKSpriteNode(imageNamed: "icon-resume")
        resumeNode.setScale(scale * 0.15)
        resumeNode.zPosition = 55.0
        resumeNode.position = CGPoint(x: screenSize.width / 2, y: gameOverNode.position.y + gameOverNode.size.height * 0.20)
        resumeNode.name = "Resume"
        addChild(resumeNode)

        restartNode = SKSpriteNode(imageNamed: "icon-restart")
        restartNode.setScale(scale * 0.15)
        restartNode.zPosition = 55.0
        restartNode.position = CGPoint(x: screenSize.width / 2, y: resumeNode.position.y - resumeNode.frame.height + 25)
        restartNode.name = "PlayAgain"
        addChild(restartNode)
        
        menuNode = SKSpriteNode(imageNamed: "icon-menu")
        menuNode.setScale(scale * 0.15)
        menuNode.zPosition = 55.0
        menuNode.position = CGPoint(x: screenSize.width / 2, y: restartNode.position.y - restartNode.frame.height + 25)
        menuNode.name = "Home"
        addChild(menuNode)
    }
    
    func removePauseMenu() {
        gameOverShape?.removeFromParent()
        gameOverNode?.removeFromParent()
        resumeNode?.removeFromParent()
        restartNode?.removeFromParent()
        menuNode?.removeFromParent()
    }
}

//MARK: - Game Over 0/3
extension HUDNode {


    private func createGameOverLevelsPanel(_ name: String) {
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)

        gameOverNode = SKSpriteNode(imageNamed: name)
        gameOverNode.setScale(scale * 0.15)
        gameOverNode.zPosition = 50.0
        gameOverNode.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        addChild(gameOverNode)
    }

    func setupGameOverLevels() {
        createGameOverShape()

        isUserInteractionEnabled = true
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)
        
        createGameOverLevelsPanel("panel-gameOver")
        
        let starSpacing: CGFloat = 80.0
        let startXPosition: CGFloat = screenSize.width / 2 - starSpacing
        
        for i in 0..<3 {
            let starImageName = "icon-starEmpty"
            let starNode = SKSpriteNode(imageNamed: starImageName)
            starNode.setScale(scale * 0.3)
            starNode.position = CGPoint(x: startXPosition + CGFloat(i) * starSpacing, y: screenSize.height / 2 + 115)
            starNode.zPosition = 55.0
            addChild(starNode)
        }
        
        let starsLabel = SKLabelNode(fontNamed: FontName.montserrat)
        starsLabel.text = "0/3" 
        starsLabel.fontSize = 30.0 * scale
        starsLabel.fontColor = .white
        starsLabel.zPosition = 55.0
        starsLabel.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + 40)
        addChild(starsLabel)

        restartNode = SKSpriteNode(imageNamed: "icon-restart")
        restartNode.setScale(scale * 0.15)
        restartNode.zPosition = 55.0
        restartNode.position = CGPoint(x: screenSize.width / 2, y: starsLabel.position.y - 60)
        restartNode.name = "PlayAgain"
        addChild(restartNode)
        
        menuNode = SKSpriteNode(imageNamed: "icon-menu")
        menuNode.setScale(scale * 0.15)
        menuNode.zPosition = 55.0
        menuNode.position = CGPoint(x: screenSize.width / 2, y: restartNode.position.y - restartNode.frame.height + 25)
        menuNode.name = "Home"
        addChild(menuNode)
    }
    
}

//MARK: - Game Over 1/3
extension HUDNode {

    func setupGameOverStarLevels() {
        createGameOverShape()

        isUserInteractionEnabled = true
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)
        
        createGameOverLevelsPanel("panel-gameOver")
        
        let starSpacing: CGFloat = 80.0
        let startXPosition: CGFloat = screenSize.width / 2 - starSpacing
        
        for i in 0..<3 {
            let isFullStar = i < 1
            let starImageName = isFullStar ? "icon-star" : "icon-starEmpty"
            let starNode = SKSpriteNode(imageNamed: starImageName)
            let starScale = isFullStar ? scale * 0.5 : scale * 0.3
            starNode.setScale(starScale)
            starNode.position = CGPoint(x: startXPosition + CGFloat(i) * starSpacing, y: screenSize.height / 2 + 115)
            starNode.zPosition = 55
            addChild(starNode)
        }
        
        let starsLabel = SKLabelNode(fontNamed: FontName.montserrat)
        starsLabel.text = "1/3"
        starsLabel.fontSize = 30.0 * scale
        starsLabel.fontColor = .white
        starsLabel.zPosition = 55.0
        starsLabel.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + 40)
        addChild(starsLabel)

        restartNode = SKSpriteNode(imageNamed: "icon-restart")
        restartNode.setScale(scale * 0.15)
        restartNode.zPosition = 55.0
        restartNode.position = CGPoint(x: screenSize.width / 2, y: starsLabel.position.y - 60)
        restartNode.name = "PlayAgain"
        addChild(restartNode)
        
        menuNode = SKSpriteNode(imageNamed: "icon-menu")
        menuNode.setScale(scale * 0.15)
        menuNode.zPosition = 55.0
        menuNode.position = CGPoint(x: screenSize.width / 2, y: restartNode.position.y - restartNode.frame.height + 25)
        menuNode.name = "Home"
        addChild(menuNode)
    }
    
}

//MARK: - Success Not Full Stars 2/3

extension HUDNode {
    
    func setupGameNotSuccessLevels() {
        createGameOverShape()

        isUserInteractionEnabled = true
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)
        
        createGamePanel("panel-freePlay")
        
        let starSpacing: CGFloat = 80.0
        let startXPosition: CGFloat = screenSize.width / 2 - starSpacing
        
        for i in 0..<3 {
            let isFullStar = i < 2
            let starImageName = isFullStar ? "icon-star" : "icon-starEmpty"
            let starNode = SKSpriteNode(imageNamed: starImageName)
            let starScale = isFullStar ? scale * 0.5 : scale * 0.3
            starNode.setScale(starScale)
            starNode.position = CGPoint(x: startXPosition + CGFloat(i) * starSpacing, y: screenSize.height / 2 + 143)
            starNode.zPosition = 55
            addChild(starNode)
        }

        
        let starsLabel = SKLabelNode(fontNamed: FontName.montserrat)
        starsLabel.text = "2/3"
        starsLabel.fontSize = 30.0 * scale
        starsLabel.fontColor = .white
        starsLabel.zPosition = 55.0
        starsLabel.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + 70)
        addChild(starsLabel)

        nextNode = SKSpriteNode(imageNamed: "icon-next")
        nextNode.setScale(scale * 0.15)
        nextNode.zPosition = 55.0
        nextNode.position = CGPoint(x: screenSize.width / 2, y: starsLabel.position.y - 60)
        nextNode.name = "Next"
        addChild(nextNode)
        
        restartNode = SKSpriteNode(imageNamed: "icon-restart")
        restartNode.setScale(scale * 0.15)
        restartNode.zPosition = 55.0
        restartNode.position = CGPoint(x: screenSize.width / 2, y: nextNode.position.y - nextNode.frame.height + 25)
        restartNode.name = "PlayAgain"
        addChild(restartNode)
        
        menuNode = SKSpriteNode(imageNamed: "icon-menu")
        menuNode.setScale(scale * 0.15)
        menuNode.zPosition = 55.0
        menuNode.position = CGPoint(x: screenSize.width / 2, y: restartNode.position.y - restartNode.frame.height + 25)
        menuNode.name = "Home"
        addChild(menuNode)
    }
}

//MARK: - Success 3/3

extension HUDNode {
    
    func setupGameSuccessLevels() {
        createGameOverShape()

        isUserInteractionEnabled = true
        let screenSize = UIScreen.main.bounds.size
        let scale = min(screenSize.width / 375.0, screenSize.height / 812.0)
        
        createGameOverLevelsPanel("icon-completeFull")
        
        let starSpacing: CGFloat = 80.0
        let startXPosition: CGFloat = screenSize.width / 2 - starSpacing
        
        for i in 0..<3 {
            let starImageName = "icon-star"
            let starNode = SKSpriteNode(imageNamed: starImageName)
            starNode.setScale(scale * 0.5)
            starNode.position = CGPoint(x: startXPosition + CGFloat(i) * starSpacing, y: screenSize.height / 2 + 115)
            starNode.zPosition = 55.0
            addChild(starNode)
        }
        
        let starsLabel = SKLabelNode(fontNamed: FontName.montserrat)
        starsLabel.text = "3/3"
        starsLabel.fontSize = 30.0 * scale
        starsLabel.fontColor = .white
        starsLabel.zPosition = 55.0
        starsLabel.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + 40)
        addChild(starsLabel)

        nextNode = SKSpriteNode(imageNamed: "icon-next")
        nextNode.setScale(scale * 0.15)
        nextNode.zPosition = 55.0
        nextNode.position = CGPoint(x: screenSize.width / 2, y: starsLabel.position.y - 60)
        nextNode.name = "Next"
        addChild(nextNode)
        
        
        menuNode = SKSpriteNode(imageNamed: "icon-menu")
        menuNode.setScale(scale * 0.15)
        menuNode.zPosition = 55.0
        menuNode.position = CGPoint(x: screenSize.width / 2, y: nextNode.position.y - nextNode.frame.height + 25)
        menuNode.name = "Home"
        addChild(menuNode)
    }
}

