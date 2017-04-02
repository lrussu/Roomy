//
//  AppDelegate.swift
//  VideoChat
//
//  Created by Farshx on 20/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

let NC = NotificationCenter.default
let UD = UserDefaults.standard
let FM = FileManager.default
let AP = UIApplication.shared
let MB = Bundle.main
let CD = UIDevice.current
let kScreen = UIScreen.main.bounds
let isIpad  = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad


func termsOfUse(){
    let appURL = URL(string: "")!
    if AP.canOpenURL(appURL){
        AP.openURL(appURL)
    }
}
func privacyPolicy(){
    let appURL = URL(string: "http://vidlerr.com/roomy_privacy.htm")!
    if AP.canOpenURL(appURL){
        AP.openURL(appURL)
    }
}
func deleteFromBase(_ comp: (() -> Void)?){
    if let id_ready = UD.object(forKey: "id_ready") as? String{
        let baseURL = URL(string: "http://vidlerr.com")!
        let manager = AFHTTPSessionManager(baseURL: baseURL)
        manager.post("applications/roomy/data.php",
            parameters: [
                "type" : "removeFromSearch",
                "id_ready" : id_ready
            ], progress: nil,
            success: { (operation, result) -> Void in
                comp?()
            }) { (operation, error) -> Void in
                comp?()
        }
    }else{
        comp?()
    }
}
func getCountryFlagImage(_ name: String) -> UIImage{
    return UIImage(named: name.replacingOccurrences(of: " ", with: "_").lowercased()) ?? UIImage(named: "usa")!
}

func getAppURLString() -> String{
    return "https://itunes.apple.com/us/app/roomy-video-and-audio-chat/id1151052133?ls=1&mt=8"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy-MM-dd"
        let currentDate = dateF.string(from: Date())
        if let lastDate = UD.string(forKey: "lastDate"){
            if lastDate != currentDate{
                let countOfEnters = UD.integer(forKey: "countOfEnters")
                UD.set(countOfEnters + 1, forKey: "countOfEnters")
            }
            UD.set(currentDate, forKey: "lastDate")
        }else{
            UD.set(1, forKey: "countOfEnters")
            UD.set(currentDate, forKey: "lastDate")
        }
        
        QBSettings.setApplicationID(35075)
        QBSettings.setAuthKey("JLVcGrNNPtCkY6M")
        QBSettings.setAuthSecret("vZ63VpJ2-QVAVyF")
        QBSettings.setAccountKey("kykvvgzB1yAwq1peC5gx")
        QBSettings.setKeepAliveInterval(30)
        QBSettings.setAutoReconnectEnabled(true)
        QBRTCConfig.setAnswerTimeInterval(20)
        
        
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        BannerReviewClass.sharedInstance()
        DB.si()
        let ss = SlideNavigationController.sharedInstance()
        let mainStoryboard = ss?.storyboard!
        ss?.enableShadow = false;
        ss?.bottomMenu = mainStoryboard?.instantiateViewController(withIdentifier: "bottomMenuController")
        ss?.enableSwipeGesture = false
        _ = SpecialLoading.SI
        
        if (RNotificationController.registered){
            RNotificationController.register()
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DEVICE TOKEN = \(deviceToken)")
        let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString
        let subsc = QBMSubscription()
        subsc.notificationChannel = QBMNotificationChannel.APNS
        subsc.deviceUDID = deviceIdentifier
        subsc.deviceToken = deviceToken
        
        QBRequest.createSubscription(subsc, successBlock: { (responce: QBResponse, subs: [QBMSubscription]?) in
            print("success push: ", responce)
        }) { (error: QBResponse) in
            print("error push: ", error)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        deleteFromBase(nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        videoChatClass.sharedInstance().exit()
    }

}

