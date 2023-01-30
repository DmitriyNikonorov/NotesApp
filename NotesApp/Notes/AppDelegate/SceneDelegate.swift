//
//  SceneDelegate.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        guard let databaseoordinator = try? CoreDataCoordinator(
            nameOfDataModelResource: DatabaseName.database.rawValue,
            withExtension: .momd
        ) else { return }

        let model = MainScreenModel()
        let vibreation = Vibration()
        let viewController = MainScreenController(vibration: vibreation, model: model, databaseCoordinator: databaseoordinator)

        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

