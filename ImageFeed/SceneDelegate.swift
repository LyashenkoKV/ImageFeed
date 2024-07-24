//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 06.05.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let isUITesting = ProcessInfo.processInfo.arguments.contains("UITestMode")
        
        let window = UIWindow(windowScene: windowScene)
        
        let splashViewController: SplashViewController
        
        if isUITesting {
            splashViewController = SplashViewController(
                profileService: MockProfileService(),
                storage: MockOAuth2TokenStorage(),
                profileImageService: MockProfileImageService(),
                imagesListService: MockImagesListService()
            )
        } else {
            splashViewController = SplashViewController()
            
        }
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
        self.window = window
    }
}

