import Foundation

class GameDataManager {
    static let shared = GameDataManager()
    private let starsKey = "starsForLevels"
    private let unlockedLevelsKey = "unlockedLevels"

    var gemCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "gemCount")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gemCount")
        }
    }

    var purchasedBalls: Set<String> {
        get {
            let balls = UserDefaults.standard.array(forKey: "purchasedBalls") as? [String] ?? []
            return Set(balls)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "purchasedBalls")
        }
    }

    var purchasedTools: Set<String> {
        get {
            let tools = UserDefaults.standard.array(forKey: "purchasedTools") as? [String] ?? []
            return Set(tools)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "purchasedTools")
        }
    }

    var selectedBall: String {
        get {
            return UserDefaults.standard.string(forKey: "selectedBall") ?? "fireball-shadow"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedBall")
        }
    }

    private let balls: [String] = [
        "fireball-shadow",
        "thunderball-shadow",
        "waterball-shadow",
        "darkball-shadow",
        "shadowball-shadow",
        "sunball-shadow"
    ]
    
    private let icons: [String] = [
        "fireball",
        "thunderball",
        "waterball",
        "darkball",
        "shadowball",
        "sunball"
    ]

    func getSelectedBallWithoutShadow() -> String {
        if let index = balls.firstIndex(of: selectedBall) {
            return icons[index]
        } else {
            return selectedBall
        }
    }

    private init() {}
}


extension GameDataManager {

    func saveStars(_ stars: [Int]) {
            UserDefaults.standard.set(stars, forKey: starsKey)
        }
        
        func saveUnlockedLevels(_ unlockedLevels: Int) {
            UserDefaults.standard.set(unlockedLevels, forKey: unlockedLevelsKey)
        }
        
        func loadStars() -> [Int] {
            return UserDefaults.standard.array(forKey: starsKey) as? [Int] ?? [0, 0, 0, 0, 0]
        }

        func loadUnlockedLevels() -> Int {
            return UserDefaults.standard.integer(forKey: unlockedLevelsKey)
        }
}
