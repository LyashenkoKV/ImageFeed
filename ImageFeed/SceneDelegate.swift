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
        
        let authViewController = AuthViewController()
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        
        let tabBarController = UITabBarController()
        
        let authNavigationController = UINavigationController(rootViewController: authViewController)
        let imagesNavigationController = UINavigationController(rootViewController: imagesListViewController)
        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
        
        imagesListViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "square.stack.fill"), tag: 0)
        profileViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.crop.circle.fill"), tag: 1)
        
        tabBarController.viewControllers = [imagesNavigationController, profileNavigationController]
        
        UITabBar.appearance().barTintColor = .ypBlack
        UITabBar.appearance().tintColor = .ypWhite
        
        UINavigationBar.appearance().barTintColor = .ypBlack
        UINavigationBar.appearance().tintColor = .ypWhite
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ypWhite]
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        window.rootViewController = authNavigationController//tabBarController
        window.makeKeyAndVisible()
    }
}

