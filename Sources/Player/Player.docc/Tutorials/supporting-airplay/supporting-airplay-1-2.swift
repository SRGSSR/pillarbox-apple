import AVFAudio
import SwiftUI
import UIKit

private final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        return true
    }
}

struct Application: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @SceneBuilder var body: some Scene {
        WindowGroup {
            // ...
        }
    }
}
