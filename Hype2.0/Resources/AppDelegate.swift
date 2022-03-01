//
//  AppDelegate.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/1/22.
//

import UIKit
import UserNotifications
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (userDidAllow, error) in
            if let error = error{
                print("🔴error in \(#function), \(error.localizedDescription)🔴")
            }
            if userDidAllow == true{
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //subscribe to remote notifications on our db
        HypeController.shared.subscribeForRemoteNotifications { error in
            if let error = error{
                print("🔴error in \(#function), \(error.localizedDescription), \(error)🔴")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🔴error in \(#function), \(error.localizedDescription), \(error)🔴")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        HypeController.shared.fetchHypes { (success) in
            if success{
                //where we do notification
            }
        }
    }
  
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

}

