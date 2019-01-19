//
//  AppDelegate.swift
//  HelloAlarm
//
//  Created by Nikita Somenkov on 18/01/2019.
//  Copyright © 2019 Nikita Somenkov. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupMainWindow()
        setupNotification()
        
        return true
    }
    
    func setupNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if !granted {
                fatalError("Alarm.app requare the notifications!")
            }
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    func setupMainWindow() {
        let vc = AlarmViewController()
        
        print(UIScreen.main.bounds)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let alarmViewController = window?.rootViewController as? AlarmViewController {
            alarmViewController.notificationDidReceive(id: notification.request.identifier)
        }
        completionHandler([.alert, .sound, .badge])
    }
}

