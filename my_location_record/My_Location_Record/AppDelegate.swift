//
//  AppDelegate.swift
//  My_Location_Record
//
//  Created by Fung Matthew on 17/10/2024.
//

import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "STOP_TRACKING" {
            NotificationCenter.default.post(name: Notification.Name("StopTracking"), object: nil)
        }
        completionHandler()
    }
}
