//
//  AppDelegate.swift
//  myPodcastApp
//
//  Created by William on 21/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import FacebookCore
@UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        UIApplication.shared.statusBarStyle = .lightContent
        let prefs:UserDefaults = UserDefaults.standard
        let isLoggedIn = prefs.integer(forKey: "isLogado") as Int
        
        if (isLoggedIn == 1) {
            let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = sb.instantiateViewController(withIdentifier: "BaseViewController")
//            let vc = sb.instantiateViewController(withIdentifier: "WelcomeViewController")
            
            vc.modalTransitionStyle = .crossDissolve
            window!.rootViewController = vc
            window!.makeKeyAndVisible()
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let appId: String = SDKSettings.appId
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId)") && url.host ==  "authorize" {
            return SDKApplicationDelegate.shared.application(app, open: url, options: options)
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

