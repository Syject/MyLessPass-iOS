//
//  AppDelegate.swift
//  LessPass UI
//
//  Created by Daniel Slupskiy on 13.01.17.
//  Copyright © 2017 Daniel Slupskiy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.barTintColor = UIColor.LesspassColors.v2.mainColor
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        if let splitViewController = self.window?.rootViewController as? UISplitViewController {
            if let navigationController = splitViewController.viewControllers.last as? UINavigationController {
                navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
                navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true
                
                splitViewController.preferredDisplayMode = .allVisible
            }
        }
        
        
        IQKeyboardManager.sharedManager().enable = true
        return true
    }

}

