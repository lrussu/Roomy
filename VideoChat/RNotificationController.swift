//
//  RNotificationController.swift
//  VideoChat
//
//  Created by Farshx on 12/05/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class RNotificationController: UIViewController {
    
    var glb: (() -> Void)? = nil
    
    class func register() {
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        AP.registerUserNotificationSettings(pushNotificationSettings)
        AP.registerForRemoteNotifications()
    }
    
    class var registered: Bool{
        return AP.isRegisteredForRemoteNotifications// && AP.currentUserNotificationSettings?.types != UIUserNotificationType()
    }
    
    class func registerToPushNotifications(_ inController: UIViewController, comp:@escaping (() -> Void)){
        let reg = SlideNavigationController.sharedInstance().storyboard!.instantiateViewController(withIdentifier: "notifications") as! RNotificationController
        inController.addChildViewController(reg)
        reg.didMove(toParentViewController: inController)
        inController.view.addSubview(reg.view)
        reg.glb = comp
        reg.closeButton.isHidden = AP.currentUserNotificationSettings?.types != UIUserNotificationType()
        reg.view.alpha = 0
        reg.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.3, animations: {
            reg.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            reg.view.alpha = 1
        })
    }
    
    @IBOutlet var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.glb?()
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.view.alpha = 0
        }, completion: { (finished) in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }) 
    }
    @IBAction func allowNotifications(_ sender: AnyObject) {
        if AP.isRegisteredForRemoteNotifications && AP.currentUserNotificationSettings?.types == UIUserNotificationType(){
            let url = URL(string:UIApplicationOpenSettingsURLString)!
            AP.openURL(url)
            RNotificationController.perform(#selector(RNotificationController.register), with: nil, afterDelay: 15.0)
        }else{
            RNotificationController.register()
        }
        closeAction(sender)
    }
}
