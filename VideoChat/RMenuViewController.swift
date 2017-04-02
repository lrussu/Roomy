//
//  RMenuViewController.swift
//  VideoChat
//
//  Created by Farshx on 20/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class RMenuViewController: UIViewController, FBSDKAppInviteDialogDelegate {
    
    public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        
    }
    
    
    @IBOutlet var inviteFriends: UIButton!
    @IBOutlet var rateUS: UIButton!
    @IBOutlet var share: UIButton!
    @IBOutlet var support: UIButton!
    @IBOutlet var terms: UIButton!
    @IBOutlet var restore: UIButton!
    
    @IBOutlet var gemsLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    
    let ss = SlideNavigationController.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gemsLabel.text = "\(myData.gems)"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let bottomMenu = ss?.bottomMenu as! RBottomMenuViewController
        bottomMenu.hideMenu(nil)
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        
    }
    
    @IBAction func buyGemsAction(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.frame.origin = CGPoint(x: kScreen.width, y: 0)
            }, completion: { (finished) -> Void in
                let ss = SlideNavigationController.sharedInstance()
                let bottomMenu = ss?.bottomMenu as! RBottomMenuViewController
                bottomMenu.unHideMenu()
                bottomMenu.moreButton.isSelected = false
                bottomMenu.hideMenu { () -> Void in
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                    let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "buyController")
                    ss?.pushViewController(controller!, animated: true)
                }
        }) 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    @IBAction func inviteFriendsAction(_ sender: AnyObject) {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = URL(string: "https://fb.me/236664193348727")!
//        content.appInvitePreviewImageURL = NSURL(string: "")!
        FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
        
    }
    @IBAction func rateUSAction(_ sender: AnyObject) {
        let appURL = URL(string: getAppURLString())!
        if AP.canOpenURL(appURL){
            AP.openURL(appURL)
        }
    }
    @IBAction func shareAction(_ sender: AnyObject) {
        let str = "I use Roomy!\n" + getAppURLString()
        let act = UIActivityViewController(activityItems: [str], applicationActivities: nil)
        act.excludedActivityTypes = []
        if isIpad{
            act.popoverPresentationController!.sourceView = self.view
        }
        self.present(act, animated: true, completion: nil)
    }
    @IBAction func supportAction(_ sender: AnyObject) {
        BannerReviewClass.sharedInstance().support(self, andEmail: "info.publicartexpert@gmail.com")
    }
    @IBAction func termsAction(_ sender: AnyObject) {
        termsOfUse()
    }
    @IBAction func restoreAction(_ sender: AnyObject) {
        BannerReviewClass.sharedInstance().reset(self.view)
    }
    
    @IBAction func closeButtonAction(_ sender: AnyObject) {
        if let cont = self.parent as? RCameraViewController{
            cont.recallSwipe.isEnabled = true
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.frame.origin = CGPoint(x: kScreen.width, y: 0)
            }, completion: { (finished) -> Void in
                let bottomMenu = self.ss?.bottomMenu as! RBottomMenuViewController
                bottomMenu.unHideMenu()
                bottomMenu.moreButton.isSelected = false

                if finished{
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                }
        }) 
    }
    
}
