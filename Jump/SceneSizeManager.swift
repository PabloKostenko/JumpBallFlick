import SpriteKit

class SceneSizeManager {
    static let shared = SceneSizeManager()
    
    private(set) var sceneSize: CGSize = .zero
    private var isSceneSizeSet = false
    
    private init() {}
    
    func updateSceneSize(_ size: CGSize) {
        guard !isSceneSizeSet else { return }
        self.sceneSize = size
        isSceneSizeSet = true
    }
}

