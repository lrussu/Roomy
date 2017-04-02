//
//  RLoginViewController.swift
//  VideoChat
//
//  Created by Farshx on 20/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit


struct Me {
    var id: String!
    var facebook: String!
    var name: String!
    var country: String!
    var gems: Int = 0
    var image: UIImage!
    var flagImage: UIImage!
    var code: String!
    var myUser: QBUUser!
}

struct Human {
    var id: String!
    var name: String!
    var imagePath: NSString!
    var country: String!
    var flagImage: UIImage!
}


var myData: Me! = nil

class RLoginViewController: UIViewController, LoginDelegate {
    
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var logo: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var fbButton: UIButton!
    @IBOutlet var bottom: UIView!
    
    var viewisLoaded = false
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func closeApp(_ sender: Notification){
        deleteFromBase(nil)
        videoChatClass.sharedInstance().exit()
    }
    
    var loadingController: RLoadingController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImageView.frame = kScreen
        self.view.sendSubview(toBack: bgImageView)
        UD.set(true, forKey: "fistConnect")
        
        NC.addObserver(forName: NSNotification.Name(rawValue: "SpecialLoadingStart2"), object: nil, queue: OperationQueue.main) { (sender) in
            self.loadingController = RLoadingController.showLoadingIn(self)
        }
        NC.addObserver(forName: NSNotification.Name(rawValue: "SpecialLoadingStop2"), object: nil, queue: OperationQueue.main) { (sender) in
            self.loadingController?.closeLoading()
            SpecialLoading.SI.stopLoadin()
        }
        
        if BannerReviewClass.sharedInstance().connected(){
            LoginLogoutClass.sharedInstance().addFBLoginButton(to: self.fbButton, withCenter: CGPoint(x: self.fbButton.frame.width / 2, y: self.fbButton.frame.height / 2))
            LoginLogoutClass.sharedInstance().delegate = self
            NC.addObserver(self, selector: #selector(RLoginViewController.closeApp(_:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        }else{
            let alert = UIAlertController(title: "Internet", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                exit(0)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.logo.center = CGPoint(x: kScreen.width / 2, y: isIpad ? 210 : 158)
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.titleLabel.alpha = 1.0
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.fbButton.center = CGPoint(x: kScreen.width / 2, y: isIpad ? 580 : 349)
                }, completion: { (finished) -> Void in
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        self.bottom.center = CGPoint(x: kScreen.width / 2, y: kScreen.height - self.bottom.frame.height)
                    }, completion: { (finished) -> Void in
                        
                    })
                })
            })
        })
        if let kWindow = UIApplication.shared.keyWindow{
            if let bottomMenu = SlideNavigationController.sharedInstance().bottomMenu as? RBottomMenuViewController{
                bottomMenu.view.isHidden = true
                kWindow.addSubview(bottomMenu.view)
                kWindow.backgroundColor = UIColor(red: 24 / 255.0, green: 178 / 255.0, blue: 220 / 255.0, alpha: 1.0)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        myData = nil
        LoginLogoutClass.sharedInstance().haveActiveFbSession()
    }
    func returnCurrentUser(_ user: QBUUser!) {
        if myData == nil{
            login(user)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var opend = false
    func login(_ user: QBUUser!){
        if let profile = FBSDKProfile.current(){
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async { () -> Void in
                if let _ = SlideNavigationController.sharedInstance().storyboard?.instantiateViewController(withIdentifier: "cameraController"){
                    let id_facebook = profile.userID
                    let id_user = "\(user.id)"
                    let query = "SELECT * FROM `r_user` WHERE `id_user` = ? AND `id_facebook` = ?"
                    let users = DB.si().selectRow(withQyery: query, andParams: [id_user, id_facebook])
                    let imageURL = profile.imageURL(for: FBSDKProfilePictureMode.normal, size: CGSize(width: 450, height: 450))
                    let imageData = try? Data(contentsOf: imageURL!)
                    let name = profile.firstName.substring(to: profile.firstName.index(profile.firstName.startIndex, offsetBy: profile.firstName.characters.count-2)) + "**"
                    let image = imageURL?.absoluteString
                    if users?.count == 0 {
                        let insertQuery = "INSERT INTO `r_user` (`id_user`, `id_facebook`, `name`, `country`, `image`) VALUES (?, ?, ?, ?, ?)"
                        DB.si().request(withQuery: insertQuery, andParams: [id_user, id_facebook, name, "", image!])
                    }else{
                        let insertQuery = "UPDATE `r_user` SET `name` = ?, `image` = ? WHERE `id_user` = ? AND `id_facebook` = ?"
                        DB.si().request(withQuery: insertQuery, andParams: [name, image!, id_user, id_facebook])
                    }
                    DispatchQueue.main.sync(execute: { () -> Void in
                        var country = "USA"
                        let block2 = { () -> Void in
                            if let locationsController = self.storyboard?.instantiateViewController(withIdentifier: "locationsController") as? RLocationsViewController{
                                self.opend = true
                                locationsController.genderOrLocations = (false, false)
                                locationsController.multiSelect = false
                                locationsController.unhideMenu = false
                                self.addChildViewController(locationsController)
                                locationsController.didMove(toParentViewController: self)
                                self.view.addSubview(locationsController.view)
                                locationsController.view.frame.origin = CGPoint(x: 0, y: kScreen.height)
                                locationsController.selectedCountrysBlock = { (countrys) -> Void in
                                    let cn = countrys[0]["name"] ?? "USA"
                                    let insertQuery = "UPDATE `r_user` SET `country` = ? WHERE `id_user` = ? AND `id_facebook` = ?"
                                    DB.si().request(withQuery: insertQuery, andParams: [cn, id_user, id_facebook])
                                    self.block(id_user, id_facebook!, name, imageData, cn, user, self)
                                }
                                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                                    locationsController.view.frame.origin = CGPoint(x: 0, y: 0)
                                })
                            }
                        }
                        if let cn = DB.si().selectRow(withQyery: "SELECT `country` FROM `r_user` WHERE `id_user` = ? AND `id_facebook` = ?", andParams: [id_user, id_facebook])["country"] as? String{
                            if cn != ""{
                                country = cn
                                self.block(id_user, id_facebook!, name, imageData, country, user, self)
                            }else{
                                if !self.opend{
                                    block2()
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    let block = {(id_user: String, id_facebook: String, name: String, imageData: Data?, country: String, user: QBUUser, inC: UIViewController) -> Void in
        if let controller = SlideNavigationController.sharedInstance().storyboard?.instantiateViewController(withIdentifier: "cameraController"){
            let bl2 = {
                UD.set(id_user, forKey: "id_user")
                let myNewImage: UIImage!
                if imageData != nil{
                    myNewImage = UIImage(data: imageData!)
                }else{
                    myNewImage = UIImage(named: "default")
                }
                let code = DB.si().selectRow(withQyery: "SELECT `code` FROM `r_user` WHERE `id_user` = ? AND `id_facebook` = ?", andParams: [id_user, id_facebook])["code"] as? String
                let newUsr = user
                newUsr.password = "199211xy"
                myData = Me(id: id_user, facebook: id_facebook, name: name, country: country, gems: 0, image: myNewImage, flagImage: getCountryFlagImage(country), code: code ?? "none", myUser: newUsr)
                let baseURL = URL(string: "http://vidlerr.com/")!
                let manager = AFHTTPSessionManager(baseURL: baseURL)
                manager.post("applications/roomy/data.php",
                             parameters: [
                                "type"          : "getUserGems",
                                "id_user"       : id_user,
                                "id_facebook"   : id_facebook
                    ],
                             progress:nil,
                             success: { (operation, resp) -> Void in
                                if resp != nil{
                                    if let resp = resp as? [String: Any]{
                                    if let gems = resp["gems"] as? Int{
                                        myData.gems = gems
                                    }else{
                                        myData.gems = 0
                                    }
                                }
                }else{
                    myData.gems = 0
                }
                let ss = SlideNavigationController.sharedInstance()
                let bottomMenu = ss?.bottomMenu as! RBottomMenuViewController
                bottomMenu.globalController = controller
                bottomMenu.discoverButton.isSelected = true
                ss?.pushViewController(controller, animated: true)
                NC.post(name: Notification.Name(rawValue: "SpecialLoadingStop2"), object: nil)
            },
            failure: { (operation, error) -> Void in
                print("\n\n", error)
//                print(error.localizedDescription, "\n\n", error.userInfo, "\n\n", error.code, "\n\n", error.localizedFailureReason, "\n\n", error.localizedRecoverySuggestion)
                myData.gems = 0
                NC.post(name: Notification.Name(rawValue: "SpecialLoadingStop2"), object: nil)
            })
        }
        if !RNotificationController.registered{
            RNotificationController.registerToPushNotifications(inC, comp: {
                bl2()
            })
        }else{
            bl2()
        }
    }
}

@IBAction func facebookAction(_ sender: AnyObject) {
    
}
@IBAction func termsAction(_ sender: AnyObject) {
    termsOfUse()
}
@IBAction func privacyAction(_ sender: AnyObject) {
    privacyPolicy()
}
}
