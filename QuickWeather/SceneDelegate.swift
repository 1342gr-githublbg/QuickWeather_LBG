//
//  SceneDelegate.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 11/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import UIKit

private let coordinator = Coordinator()

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard
      let rootNavigationController = window?.rootViewController as? UINavigationController,
      let citySelectorViewController = rootNavigationController.viewControllers.first as? CitySelectorTableViewController
    else {
      fatalError("Could not find the city selector view controller")
    }
    citySelectorViewController.delegate = coordinator
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
  }

  func sceneWillResignActive(_ scene: UIScene) {
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
  }
}
