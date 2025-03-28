import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = self.view as? SKView else {
            return
        }
        
        let scene = MainMenu(size: CGSize(width: screenWidth, height: screenHeight))
        scene.scaleMode = .aspectFill
        
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        view.showsPhysics = false

        view.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
