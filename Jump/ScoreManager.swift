import SpriteKit

var globalScore: Int = 0
var globalHighScore: Int = 0

protocol ScoreManagerDelegate: AnyObject {
    var scoreKey: String { get }
    func updateScore(_ score: Int)
    func setupGameOver(_ fontSize: CGFloat, _ highScore: Int, _ padding: CGFloat)
}

class ScoreManager {
    private var score = 0
    var levelGoal: Int = 0
    private weak var hudNode: ScoreManagerDelegate?
    private let scoreKey: String

    init(scene: ScoreManagerDelegate, hudNode: ScoreManagerDelegate, scoreKey: String) {
        self.hudNode = hudNode
        self.scoreKey = scoreKey
        
        globalScore = 0
    }

    func addScore(points: Int) {
        score += points
        globalScore = score
        hudNode?.updateScore(score)
        checkHighScore()
    }

    private func checkHighScore() {
        var highScore = UserDefaults.standard.integer(forKey: scoreKey)
        if score > highScore {
            UserDefaults.standard.set(score, forKey: scoreKey)
            highScore = score
        }
        globalHighScore = highScore
    }

    func getScore() -> Int {
        return score
    }
    
    func resetScore() {
        score = 0
        globalScore = 0
    }

    func handleGameOver() {
        let highScore = UserDefaults.standard.integer(forKey: scoreKey)
        hudNode?.setupGameOver(60, highScore, 3)
    }
}
