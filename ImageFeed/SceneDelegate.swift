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
        
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        
        let tabBarController = UITabBarController()
        
        imagesListViewController.tabBarItem = UITabBarItem(title: "Images", image: UIImage(systemName: "square.stack.fill"), tag: 0)
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle.fill"), tag: 1)
        
        tabBarController.viewControllers = [imagesListViewController, profileViewController]
        
        UITabBar.appearance().barTintColor = .ypBlack
        UITabBar.appearance().tintColor = .ypWhite
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

