import UIKit

let screenWidth: CGFloat = 1536.0
let screenHeight: CGFloat = 2048.0

let appDL = UIApplication.shared.delegate as! AppDelegate

var playableRect: CGRect {
    var ratio: CGFloat = 16 / 9
    
    if appDL.isIPhoneX {
        ratio = 2.16
    } else if appDL.isIPad11 {
        ratio = 1.43
    }
    
    let w: CGFloat = screenHeight / ratio
    let h: CGFloat = screenHeight
    let x: CGFloat = (screenWidth - w) / 2
    let y: CGFloat = 0.0
    
    return CGRect(x: x, y: y, width: w, height: h)
}

struct PhysicsCategories {
    static let Player:      UInt32 = 0x1 << 1
    static let Platform:    UInt32 = 0x1 << 2
    static let Wall:        UInt32 = 0x1 << 3
    static let Score:       UInt32 = 0x1 << 4
    static let SuperScore:  UInt32 = 0x1 << 5
}

struct FontName {
    static let montserrat = "Montserrat-ExtraBold"
}

struct SoundName {
    static let superScore = "superScore.wav"
    static let jump = "jump.wav"
}

