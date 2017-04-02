//
//  RBottomMenuViewController.swift
//  VideoChat
//
//  Created by Farshx on 23/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

let kDiscoverNotification = "kDiscoverNotification"
let kMessagesNotification = "kMessagesNotification"
let kFriendsNotification  = "kFriendsNotification"
let kHistoryNotification  = "kHistoryNotification"
let kMoreNotification     = "kMoreNotification"

class RBottomMenuViewController: UIViewController {
    
    @IBOutlet var blureView: UIVisualEffectView!
    @IBOutlet var bottomBorder: UIButton!
    @IBOutlet var maskButton: UIButton!
    @IBOutlet var discoverButton: UIButton!
    @IBOutlet var messagesButton: UIButton!
    @IBOutlet var friendsButton: UIButton!
    @IBOutlet var historyButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    
    var globalController: UIViewController!
    
    let ss = SlideNavigationController.sharedInstance()
    let viewHeight = CGFloat(isIpad ? 54 : 47)
    
    @IBAction func discoverButtonAction(_ sender: UIButton) {
        if !sender.isSelected{
//            (ss.bottomMenu as! RBottomMenuViewController).blureView.hidden = true
            bottomBorder.isHidden = true
            btnSelect(sender, controllerName: "cameraController")
            bottomBorder.isHidden = true
        }
    }
    @IBAction func messagesButtonAction(_ sender: UIButton) {
        if !sender.isSelected{
//            (ss.bottomMenu as! RBottomMenuViewController).blureView.hidden = false
            btnSelect(sender, controllerName: "myMessagesController")
        }
    }
    @IBAction func friendsButtonAction(_ sender: UIButton) {
        if !sender.isSelected{
//            (ss.bottomMenu as! RBottomMenuViewController).blureView.hidden = false
            btnSelect(sender, controllerName: "friendsController")
        }
    }
    @IBAction func historyButtonAction(_ sender: UIButton) {
        if !sender.isSelected{
//            (ss.bottomMenu as! RBottomMenuViewController).blureView.hidden = false
            btnSelect(sender, controllerName: "historyController")

        }
    }
    @IBAction func moreButtonAction(_ sender: UIButton) {
        if !sender.isSelected{
            sender.isSelected = true
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "menuController") as! RMenuViewController
            globalController.addChildViewController(controller)
            controller.didMove(toParentViewController: globalController)
            globalController.view.addSubview(controller.view)
            controller.view.frame.origin = CGPoint(x: kScreen.width, y: 0)
            hideMenu({ () -> Void in
                if let cont = self.globalController as? RCameraViewController{
                    cont.recallSwipe.isEnabled = false
                }
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    controller.view.frame.origin = CGPoint.zero
                })
            })
        }
    }
    
    func showController(_ viewController: UIViewController){
        closeMenu { () -> Void in
            self.ss?.switch(to: viewController, animated: false)
        }
    }
    
    func btnSelect(_ sender: UIButton, controllerName: String){
        unSelectAllButtons()
        sender.isSelected = true
        sender.backgroundColor = .clear
        bottomBorder.isHidden = false
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomBorder.center.x = sender.center.x
            }, completion: { (finished) -> Void in
                self.bottomBorder.isHidden = true
                if let controller = self.ss?.storyboard?.instantiateViewController(withIdentifier: controllerName){
                    self.globalController = controller
                    self.showController(controller)
                }
        }) 
    }
    
    func unSelectAllButtons(){
        discoverButton.isSelected = false
        messagesButton.isSelected = false
        friendsButton.isSelected  = false
        historyButton.isSelected  = false
        moreButton.isSelected     = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blureView.isHidden = true
        bottomBorder.isHidden = true
        self.view.frame = CGRect(x: 0, y: kScreen.height, width: kScreen.width, height: self.viewHeight)
        discoverButton.isSelected = true
        NC.addObserver(forName: NSNotification.Name(rawValue: "logout"), object: nil, queue: OperationQueue.main) { (sender) -> Void in
//            let fbManager = FBSDKLoginManager()
//            fbManager.logOut()
            let ss = SlideNavigationController.sharedInstance()
            (ss?.bottomMenu as! RBottomMenuViewController).hideMenu(nil)
            ss?.popToRootViewController(animated: true)
        }
    }
    
    func showMenu(_ comp:(() -> Void)?){
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.frame = CGRect(x: 0, y: kScreen.height - self.viewHeight, width: kScreen.width, height: self.viewHeight)
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.unHideAllButtons()
                    }, completion: { (finished) -> Void in
                        if !self.discoverButton.isSelected{
                            self.bottomBorder.isHidden = false
                        }
                        comp?()
                })
        }) 
    }
    func closeMenu(_ comp:(() -> Void)?){
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.hideAllButtons()
            }, completion: { (finisehd) -> Void in
                comp?()
                self.showMenu(nil)
        }) 
        
    }
    fileprivate func hideAllButtons(){
//        let dxc = self.discoverButton.center.x
//        self.messagesButton.center.x = dxc
//        self.friendsButton.center.x  = dxc
//        self.historyButton.center.x  = dxc
//        self.moreButton.center.x     = dxc
    }
    fileprivate func unHideAllButtons(){
//        let dxc = (CGFloat(33),CGFloat(96),CGFloat(224),CGFloat(286))
//        self.messagesButton.center.x = dxc.0
//        self.friendsButton.center.x  = dxc.1
//        self.historyButton.center.x  = dxc.2
//        self.moreButton.center.x     = dxc.3
    }
    func hideMenu(_ comp: (() -> Void)?){
//        self.bottomBorder.hidden = true
//        UIView.animateWithDuration(0.2, animations: { () -> Void in
//            self.hideAllButtons()
//            }) { (finished) -> Void in
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.view.frame = CGRect(x: 0, y: kScreen.height, width: kScreen.width, height: self.viewHeight)
                    }, completion: { (finished) -> Void in
                        comp?()
                }) 
//        }
    }
    func unHideMenu(){
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.frame = CGRect(x: 0, y: kScreen.height - self.viewHeight, width: kScreen.width, height: self.viewHeight)
            }, completion: { (finished) -> Void in
//                UIView.animateWithDuration(0.2, animations: { () -> Void in
//                    self.unHideAllButtons()
//                    }) { (finished) -> Void in
                        if !self.discoverButton.isSelected{
                            self.bottomBorder.isHidden = false
                        }
//                }
        }) 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
