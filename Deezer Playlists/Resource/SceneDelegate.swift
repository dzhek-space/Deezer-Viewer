//
//  SceneDelegate.swift
//  Deezer Playlists
//
//  Created by Dzhek on 21.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = UserProfileViewController()
        window?.makeKeyAndVisible()
    }

}

