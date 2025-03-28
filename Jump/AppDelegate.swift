import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: - Properties
    var window: UIWindow?
    
    var isAllIpad = false
    var isIPadPro = false
    var isIPad11 = false
    var isIPad12 = false
    var isIPad = false

    var isIPhoneX = false
    var isIPhonePlus = false
    var isIPhone = false
    var isIPhone5 = false

    //MARK: - Lifecycle methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupDevice()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    //MARK: - Device Setup
    func setupDevice() {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            isAllIpad = true
            switch UIScreen.main.nativeBounds.height {
            case 2388:
                isIPad11 = true
            case 2732:
                isIPad12 = true
            default:
                isIPadPro = true
            }
            
            if isIPad12 || isIPadPro {
                isIPad = true
            }
        
        case .phone:
            switch UIScreen.main.nativeBounds.height {
            case 2688, 1792, 2436, 2778:
                isIPhoneX = true
            case 1920, 2208:
                isIPhonePlus = true
                isIPhone = true
            case 1136:
                isIPhone5 = true
            default:
                isIPhoneX = true
            }
        case .tv: break
        default: break
        }
    }
}
