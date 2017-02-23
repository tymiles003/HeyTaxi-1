//
//  AppDelegate+PushNotification.swift
//  CustomerTaxiApp
//
//  Created by Vu Tinh on 1/18/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//
import UIKit
import Foundation
import UserNotifications
import UserNotificationsUI


extension AppDelegate {
    
    func registerRemoteNotification() {
        //Requesting Authorization for User Interactions
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                
            }
        } else {
            // Fallback on earlier versions
        }
        
        let settings =  UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    func unregisterRemoteNotification() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    //MARK: -Remote notification support
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? [String : AnyObject] {
            let alertBody = (aps["alert"] as? String) ?? ""
            let alertController = UIAlertController(title: "Thông báo", message: alertBody, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = String.loadFromUserDefaults(withKey: UserDefaultKey.deviceToken)
        if token == "" {
            var pushToken = String(format: "%@", deviceToken as CVarArg)
            pushToken = pushToken.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            pushToken = pushToken.replacingOccurrences(of: " ", with: "")
            pushToken.saveToUserDefaults(withKey: UserDefaultKey.deviceToken)
            
            // Push token to server to ready receive Remote Notification
            
            let params = ["device_token":pushToken,
                          "device_token_type":"capns"]
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            guard let url = URL(string: "http:\\abc.cm") else {return}
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: 0))
            request.httpBody = jsonData
            let sessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
            })
            sessionDataTask.resume()
            
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(error.localizedDescription)")
    }

}
