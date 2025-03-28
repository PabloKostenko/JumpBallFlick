import SpriteKit

class StoreScene: SKScene {

    // MARK: - Properties
    private let balls: [String] = [
        "fireball-shadow",
        "thunderball-shadow",
        "waterball-shadow",
        "darkball-shadow",
        "shadowball-shadow",
        "sunball-shadow"
    ]
    
    private let icons: [String] = [
        "icon-fireball",
        "icon-thunderball",
        "icon-waterball",
        "icon-darkball",
        "icon-shadowball",
        "icon-sunball"
    ]
    
    private let ballPrices: [String: Int] = [
        "fireball-shadow": 0,
        "thunderball-shadow": 25,
        "waterball-shadow": 50,
        "darkball-shadow": 75,
        "shadowball-shadow": 100,
        "sunball-shadow": 150
    ]
    
    private let toolPrices: [String: Int] = [
        "shield": 100,
        "magnet": 100
    ]
    
    private var purchasedTools: Set<String> = []
    private let tools: [String] = ["shield", "magnet"]
    private var gemCount: Int = 0
    private let scale: CGFloat = 0.5
    private let topButtonSpacing: CGFloat = 320

    private var selectedBall: String = "fireball-shadow"
    private var selectedBallNode: SKSpriteNode!
    private var gemLabel: SKLabelNode!
    
    private var settingsMenu: SettingsMenu?
    
    private var purchasedBalls: Set<String> = ["fireball"]

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        loadUserData()
        SettingsMenu.setupBackground(for: self, imageName: "background")
        setupDiamondDisplay()
        setupBallSection()
        setupToolSection()
        displaySelectedBall()
        setupBackButton()
    }

    // MARK: - UserDefaults Methods
    private func saveUserData() {
        GameDataManager.shared.gemCount = gemCount
        GameDataManager.shared.purchasedBalls = purchasedBalls
        GameDataManager.shared.purchasedTools = purchasedTools
        GameDataManager.shared.selectedBall = selectedBall
    }

    private func loadUserData() {
        gemCount = GameDataManager.shared.gemCount
        purchasedBalls = GameDataManager.shared.purchasedBalls
        purchasedTools = GameDataManager.shared.purchasedTools
        selectedBall = GameDataManager.shared.selectedBall
    }

    // MARK: - Setup Methods
    private func setupBackButton() {
           let backButton = SKSpriteNode(imageNamed: "icon-back")
           backButton.setScale(scale - 0.1)
           backButton.position = CGPoint(x: frame.minX + backButton.size.width / 2 + 320, y: frame.maxY - 220)
           backButton.zPosition = 1
           backButton.name = "back"
           addChild(backButton)
       }
    
    private func setupDiamondDisplay() {
        let gemPanel = SKSpriteNode(imageNamed: "panel-mainMenu")
        gemPanel.setScale(scale - 0.1)
        gemPanel.position = CGPoint(x: frame.maxX - gemPanel.size.width / 2 - topButtonSpacing, y: frame.maxY - 220)
        gemPanel.zPosition = 10.0
        addChild(gemPanel)

        let gemImage = SKSpriteNode(imageNamed: "icon-gem")
        gemImage.setScale(0.4)
        gemImage.position = CGPoint(x: gemPanel.position.x - 35, y: gemPanel.position.y)
        gemImage.zPosition = 11.0
        addChild(gemImage)

        gemLabel = SKLabelNode(text: "\(gemCount)")
        gemLabel.fontName = FontName.montserrat
        gemLabel.fontSize = dynamicFontSize(for: gemCount)
        gemLabel.fontColor = .white
        gemLabel.position = CGPoint(x: gemPanel.position.x + 25, y: gemPanel.position.y - 20)
        gemLabel.zPosition = 11.0
        addChild(gemLabel)
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
    
    private func displaySelectedBall() {
        if selectedBallNode != nil {
            selectedBallNode.removeFromParent()
        }
        selectedBallNode = SKSpriteNode(imageNamed: selectedBall)
        selectedBallNode.position = CGPoint(x: frame.midX, y: frame.maxY - topButtonSpacing - 70)
        selectedBallNode.setScale(scale)
        selectedBallNode.zPosition = 2

        addChild(selectedBallNode)
    }


    private func setupBallSection() {
        let ballTitle = SKSpriteNode(imageNamed: "icon-ballLabel")
        ballTitle.position = CGPoint(x: frame.midX, y: frame.midY + topButtonSpacing)
        ballTitle.setScale(scale - 0.15)
        ballTitle.zPosition = 4
        addChild(ballTitle)

        let ballStartX = frame.midX - topButtonSpacing + 25
        let ballStartY = frame.midY + 65
        let iconSpacingX: CGFloat = 300
        let iconSpacingY: CGFloat = 300

        for (index, ballName) in balls.enumerated() {
            let row = index / 3
            let col = index % 3

            let ballButton = SKSpriteNode(imageNamed: icons[index])
            ballButton.position = CGPoint(
                x: ballStartX + CGFloat(col) * iconSpacingX,
                y: ballStartY - CGFloat(row) * iconSpacingY
            )
            ballButton.name = balls[index]
            ballButton.setScale(scale - 0.1)
            ballButton.zPosition = 1
            addChild(ballButton)
            
            if index != 0 && !purchasedBalls.contains(ballName) {
                let priceLabel = SKSpriteNode(imageNamed: "icon-pricePanel")
                priceLabel.setScale(scale - 0.1)
                priceLabel.position = CGPoint(x: ballButton.position.x, y: ballButton.position.y - 100)
                priceLabel.zPosition = 2
                priceLabel.name = "price-\(ballName)"
                addChild(priceLabel)
                
                let gemImage = SKSpriteNode(imageNamed: "icon-gem")
                gemImage.setScale(scale - 0.2)
                gemImage.position = CGPoint(x: priceLabel.position.x - 25, y: priceLabel.position.y)
                gemImage.zPosition = 11.0
                gemImage.name = "gem-\(ballName)"
                addChild(gemImage)

                let gemLabel = SKLabelNode(text: "\(ballPrices[ballName] ?? 25)")
                gemLabel.fontName = FontName.montserrat
                gemLabel.fontSize = 36
                gemLabel.fontColor = .white
                gemLabel.position = CGPoint(x: priceLabel.position.x + 20, y: priceLabel.position.y - 15)
                gemLabel.zPosition = 11.0
                gemLabel.name = "priceLabel-\(ballName)"
                addChild(gemLabel)
            }
        }
    }

    private func updateGemLabel() {
        gemLabel.text = "\(gemCount)"
        gemLabel.fontSize = dynamicFontSize(for: gemCount)
    }

    private func buyItem(named itemName: String) {
        if balls.contains(itemName) {

            if purchasedBalls.contains(itemName) {
                selectedBall = itemName
                displaySelectedBall()
                saveUserData()
                return
            }

            let price = ballPrices[itemName] ?? 25
            if gemCount >= price {
                gemCount -= price
                purchasedBalls.insert(itemName)
                selectedBall = itemName
                displaySelectedBall()
                updateGemLabel()

                childNode(withName: "price-\(itemName)")?.removeFromParent()
                childNode(withName: "gem-\(itemName)")?.removeFromParent()
                childNode(withName: "priceLabel-\(itemName)")?.removeFromParent()

                saveUserData()
            } else {
                if let itemButton = childNode(withName: itemName) as? SKSpriteNode {
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
        } else if tools.contains(itemName) {
            if purchasedTools.contains(itemName) {
                return
            }

            let price = toolPrices[itemName] ?? 100
            if gemCount >= price {
                gemCount -= price
                purchasedTools.insert(itemName)
                updateGemLabel()
                if let toolButton = childNode(withName: itemName) as? SKSpriteNode {
                    toolButton.texture = SKTexture(imageNamed: "\(itemName)-owned")
                }
                childNode(withName: "price-\(itemName)")?.removeFromParent()
                childNode(withName: "gem-\(itemName)")?.removeFromParent()
                childNode(withName: "priceLabel-\(itemName)")?.removeFromParent()
                saveUserData()
            } else {
                if let itemButton = childNode(withName: itemName) as? SKSpriteNode {
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



    private func setupToolSection() {
        let toolTitle = SKSpriteNode(imageNamed: "icon-toolsLabel")
        toolTitle.position = CGPoint(x: frame.midX, y: frame.minY + 500)
        toolTitle.setScale(scale - 0.15)
        toolTitle.zPosition = 1
        addChild(toolTitle)

        let toolStartX = frame.midX - 130
        for (index, toolName) in tools.enumerated() {
            let toolButton = SKSpriteNode(imageNamed: purchasedTools.contains(toolName) ? "\(toolName)-owned" : toolName)
            toolButton.position = CGPoint(x: toolStartX + CGFloat(index) * 300, y: frame.minY + topButtonSpacing - 70)
            toolButton.name = toolName
            toolButton.setScale(scale - 0.15)
            toolButton.zPosition = 1
            addChild(toolButton)
            
            if !purchasedTools.contains(toolName) {
                let priceLabel = SKSpriteNode(imageNamed: "icon-pricePanel")
                priceLabel.setScale(scale - 0.1)
                priceLabel.position = CGPoint(x: toolButton.position.x, y: toolButton.position.y - 100)
                priceLabel.zPosition = 2
                priceLabel.name = "price-\(toolName)"
                addChild(priceLabel)
                
                let gemImage = SKSpriteNode(imageNamed: "icon-gem")
                gemImage.setScale(scale - 0.2)
                gemImage.position = CGPoint(x: priceLabel.position.x - 25, y: priceLabel.position.y)
                gemImage.zPosition = 11.0
                gemImage.name = "gem-\(toolName)"
                addChild(gemImage)

                let priceLabelNode = SKLabelNode(text: "\(toolPrices[toolName] ?? 100)")
                priceLabelNode.fontName = FontName.montserrat
                priceLabelNode.fontSize = 36
                priceLabelNode.fontColor = .white
                priceLabelNode.position = CGPoint(x: priceLabel.position.x + 20, y: priceLabel.position.y - 15)
                priceLabelNode.zPosition = 11.0
                priceLabelNode.name = "priceLabel-\(toolName)"
                addChild(priceLabelNode)
            }
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodesAtLocation = nodes(at: location)
            
            for node in nodesAtLocation {
                if let nodeName = node.name {
                    if nodeName == "back" {
                        saveUserData()
                        goBackToGame()
                    } else if balls.contains(nodeName) || tools.contains(nodeName) {
                        buyItem(named: nodeName)
                    }
                }
            }
        }
    }
    
    func resetPurchasedTools() {
        purchasedTools.removeAll()
        GameDataManager.shared.purchasedTools = purchasedTools
    }


    private func goBackToGame() {
        let scene = MainMenu(size: self.size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: .crossFade(withDuration: 0.5))
    }
}
