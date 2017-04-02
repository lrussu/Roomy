//
//  RCameraViewController.swift
//  VideoChat
//
//  Created by Farshx on 20/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit
import QuartzCore
import MessageUI

var partener: QBUUser! = nil
var first = true

var genresFilters = ""
var locationsFiltres = ""

func canSendPush(_ comp: @escaping (_ can: Bool) -> Void){
    let baseURL = URL(string: "http://vidlerr.com")!
    let manager = AFHTTPSessionManager(baseURL: baseURL)
    manager.post("applications/roomy/data.php",
                 parameters: [
                    "type" : "canSendPush"
        ], progress: nil, success: { (operation, res) in
            if let res = res as? [String :Any]{
                if let error = res["error"] as? String{
                    print(error)
                    comp(false)
                    return
                }
                if let can = res["can"] as? String{
                    comp((can == "1"))
                }
            }
        }) { (operation, error) in
            comp(false)
    }
}

func getOfflineMessages(){
    let baseURL = URL(string: "http://vidlerr.com")!
    let manager = AFHTTPSessionManager(baseURL: baseURL)
    let params = [
        "type" : "getAllOfflineMessages",
        "id_user" : myData.id,
        "id_facebook" : myData.facebook,
        "code" : myData.code,
        "country" : myData.country
    ]
    manager.post("applications/roomy/data.php",
        parameters: params,
        progress: nil,
        success: { (operation, result) -> Void in
            if let result = result as? [String: AnyObject]{
                if let error = result["error"]{
                    print(error)
                }
                if let messages = result["messages"] as? [[String: AnyObject]]{
                    print(messages)
                    let lastInsertsMessageIDString = (DB.si().selectRow(withQyery: "SELECT MAX(`id_messge`) as `m` FROM `r_message`", andParams: nil)["m"] as? String) ?? "1"
                    var lastInsertsMessageIDInt = Int(lastInsertsMessageIDString) ?? 1
                    for message in messages{
                        lastInsertsMessageIDInt += 1
                        let id_human = message["id_user_from"] as? String ?? "**"
                        let id_user = myData.id
                        let msg = message["message"] as? String ?? "**"
                        var dateString = message["date"] as? String ?? "2016.01.01 00:00:00"
                        dateString = dateString.replacingOccurrences(of: "-", with: ".")
                        let query = "INSERT INTO `r_message` (`id_messge`, `id_user`, `id_human`, `type`, `message`, `date`) VALUES (?, ?, ?, ?, ?, ?)"
                        DB.si().request(withQuery: query, andParams: [lastInsertsMessageIDInt, id_user, id_human, "his", msg, dateString])
                    }
                }
            }
        }) { (operation, error) -> Void in
            
    }
}

func dispatchAfter(_ seconds: TimeInterval, dispatchBlock:(() -> Void)?){
    let dispatchTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: dispatchTime) { () -> Void in
        dispatchBlock?()
    }
}


func getUserInfoByID(_ userID: String, comp: @escaping ((_ data: [String: String]) -> Void), errorBlock: (() -> Void)?){
    let baseURL = URL(string: "http://vidlerr.com")!
    let manager = AFHTTPSessionManager(baseURL: baseURL)
    manager.post("applications/roomy/data.php",
        parameters: [
            "type" : "getUserInfoByID",
            "userID" : userID
        ], progress:nil, success: { (operation, result) -> Void in
            if let result = result as? [String: AnyObject]{
                if let error = result["error"]{
                    print(error)
                    errorBlock?()
                    return
                }
                if let data = result["data"] as? [String: String]{
                    print(data)
                    comp(data)
                    return
                }
            }
            errorBlock?()
        }) { (operation, error) -> Void in
            errorBlock?()
    }
}



class RCameraViewController: UIViewController, videoDelegate, MessagingDelegate, QBRTCClientDelegate, QBChatDelegate, MFMailComposeViewControllerDelegate{
    //    MARK: Outlets
    @IBOutlet var myGems: UILabel!
    @IBOutlet var myName: UILabel!
    @IBOutlet var myFlag: UIButton!
    @IBOutlet var myCountry: UILabel!
    @IBOutlet var videoView: UIView!
    @IBOutlet var searchingView: UIView!
    @IBOutlet var bannerView: UIView!
    @IBOutlet var recallSwipe: UISwipeGestureRecognizer!
    @IBOutlet var selfVideoView: UIView!
    @IBOutlet var buyGemsButton: UIButton!
    
    @IBOutlet var exitButton: UIButton!
    @IBOutlet var locationsAlertView: UIView!
    @IBOutlet var genderAlertView: UIView!
    
    var handAnimationImageView: UIImageView! = nil
    var canPlayVideo = false {
        didSet{
            if canPlayVideo == true && canPlayVideoAfterAnimations == true{
                self.canPlayVideo = false
                self.canPlayVideoAfterAnimations = false
                self.interfaceUserConnected({ () -> Void in
                    self.cnLBL.isHidden = true
                    self.pBG.isHidden = true
                    self.bannerView2.isHidden = true
                    self.pUserImageView.isHidden = true
                    self.videoView.addSubview(videoChatClass.sharedInstance())
                    self.videoView.sendSubview(toBack: videoChatClass.sharedInstance())
                    self.sayHello()
                })
            }
        }
    }
    var canPlayVideoAfterAnimations = false {
        didSet{
            if canPlayVideoAfterAnimations == true && canPlayVideo == true{
                canPlayVideo = true
            }
        }
    }
    var heCallMe = false
    var unhideMenuVar = true
    
    var pushCounter = 0
    var pushTimer: Timer? = nil
    
    func pushTimerAction(_ sendr: Timer){
        if pushTimer != nil{
            if pushCounter >= 10{
                sendPush()
                pushCounter = 0
            }
            pushCounter += 1
        }else{
            sendr.invalidate()
        }
    }
    
    func pushh(_ index: UInt){
        let pg = QBGeneralResponsePage(currentPage: index, perPage: index + 10)
        QBRequest.users(for: pg, successBlock: { (responce, page, users) in
            if users != nil && users?.count != 0{
                var ids = ""
                for user in users!{
                    ids += "\(user.id),"
                }
                ids = ids.substring(to: ids.characters.index(ids.startIndex, offsetBy: ids.characters.count - 2))
                QBRequest.sendPush(withText: "New users are waiting for you!",
                    toUsers: ids,
                    successBlock: { (resp, events) in
                        print("push sended: ", users?.count)
                    }, errorBlock: { (error) in
                        print(error)
                })
                self.pushh(pg.perPage)
            }
            }, errorBlock: { (responce) in
                print("error requiest for push")
        })
    }
    
    func sendPush(){
        canSendPush { (can) in
            if can{
                self.pushh(1)
            }
        }
    }
    
    
    @IBAction func gendersAlertViewCloseAction(_ sender: AnyObject) {
        showGenresAlert(false)
    }
    
    @IBAction func genderAlertViewGoToShop(_ sender: AnyObject) {
        showGenresAlert(false)
    }
    
    func showGenresAlert(_ show: Bool){
        genderAlertView.center = show ? self.view.center : CGPoint(x: self.view.frame.width + self.view.center.x * 2, y: self.view.center.y)
    }
    
    
    var sayHelloImageView: UIImageView! = nil
    func sayHello(){
        if sayHelloImageView == nil{
            sayHelloImageView = UIImageView()
        }else{
            if let _ = sayHelloImageView.superview{
                sayHelloImageView.removeFromSuperview()
                sayHelloImageView.stopAnimating()
                sayHelloImageView = nil
                sayHello()
                return
            }
        }
        var imgs = [UIImage]()
        for index in 0..<8 {
            let filename = "1_Camera_say_hello000\(index)"
            if let im = UIImage(named: filename){
                imgs.append(im)
            }
        }
        if imgs.count > 0{
            sayHelloImageView.animationImages = imgs
            sayHelloImageView.animationRepeatCount = 0
            sayHelloImageView.animationDuration = 1.4
            sayHelloImageView.frame.size = imgs[0].size
            sayHelloImageView.frame.origin = CGPoint(x: 0, y: 90)
            
            sayHelloImageView.startAnimating()
            if let kWindow = AP.keyWindow{
                kWindow.addSubview(sayHelloImageView)
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(sayHelloTimerAction(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    var sayHelloTimerTime = 0
    func sayHelloTimerAction(_ sender: Timer){
        if sayHelloTimerTime >= 5{
            sayHelloTimerTime = 0
            sender.invalidate()
            sayHelloImageView.removeFromSuperview()
            sayHelloImageView.stopAnimating()
            sayHelloImageView = nil
        }else{
            sayHelloTimerTime += 1
        }
    }
    
    var chooseACountryImageView: UIImageView? = nil
    func chooseACountry(){
        if chooseACountryImageView == nil{
            chooseACountryImageView = UIImageView()
        }else{
            removeChooseACountry()
            chooseACountry()
            return
        }
        var imgs = [UIImage]()
        for index in 0..<24 {
            let filename: String!
            if index < 10{
                filename = "1_Camera_choose_country000\(index)"
            }else{
                filename = "1_Camera_choose_country00\(index)"
            }
            if let im = UIImage(named: filename){
                imgs.append(im)
            }
        }
        if imgs.count > 0{
            chooseACountryImageView?.animationImages = imgs
            chooseACountryImageView?.animationRepeatCount = 0
            chooseACountryImageView?.animationDuration = 1
            chooseACountryImageView?.frame.size = imgs[0].size
            chooseACountryImageView?.frame.origin = CGPoint(x: kScreen.width - chooseACountryImageView!.frame.width, y: isIpad ? 800 - chooseACountryImageView!.frame.height : 285)
            chooseACountryImageView?.startAnimating()
            if let kWindow = AP.keyWindow{
                kWindow.addSubview(chooseACountryImageView!)
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(chooseACountryTimerAction(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    var chooseACountryTimerTime = 0
    func chooseACountryTimerAction(_ sender: Timer){
        if chooseACountryTimerTime >= 5{
            chooseACountryTimerTime = 0
            sender.invalidate()
            removeChooseACountry()
        }else{
            chooseACountryTimerTime += 1
        }
    }
    
    func search(_ user: QBUUser){
        unhideMenuVar = false
        let dic = [
            "ID": "\(user.id)",
            "gender": user.customData ?? "male",
            "country": myData.country,
            "filters": genresFilters + "-" + locationsFiltres,
            "facebook": myData.facebook,
            "userID": myData.code
        ] as [String : Any]
        print(dic)
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
        let str  = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        videoChatClass.sharedInstance().sendData(str as! String) { (result) -> Void in
            guard let result = result as? [String: AnyObject] else{
                return
            }
            print(result)
            if let globalGems = result["globalGems"] as? Int{
                self.myGems.text = "\(globalGems)"
                updateGems(globalGems)
            }
            if let error = result["error"] as? String{
                print(error)
                self.exitAction(error as AnyObject)
                if error == "locations_not_exists"{
                    self.showLocationsAlert(true)
                }
                if error == "gender_not_exists"{
                    self.showGenresAlert(true)
                }
                return
            }
            if let search = result["search"]{
                if let dataString = search["data"] as? NSString{
                    if let data = dataString.data(using: String.Encoding.utf8.rawValue){
                        if let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]{
                            if let ID = dict?["ID"] as? NSString{
                                partener.id = UInt(ID.integerValue)
                            }
                            if let customData = dict?["gender"] as? String{
                                partener.customData = customData
                            }
                            if let website = dict?["county"] as? String{
                                partener.website = website
                            }
                            messagingClass.sharedInstance().createANewDialog(withMe: user, andOponent: partener)
                            print("connection \(partener)")
                            return
                        }
                    }
                }
            }
            if let add = result["add"]{
                print(add)
                self.pushTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.pushTimerAction(_:)), userInfo: nil, repeats: true)
                self.exitButton.isHidden = false
                return
            }
            print("error connection")
        }
    }
    func hideMenu(){
        let ss = SlideNavigationController.sharedInstance()
        let bottomMenu = ss?.bottomMenu as! RBottomMenuViewController
        bottomMenu.hideMenu(nil)
    }
    func unHideMenu(){
        let ss = SlideNavigationController.sharedInstance()
        let bottomMenu = ss?.bottomMenu as! RBottomMenuViewController
        bottomMenu.unHideMenu()
    }
    func stioSession(){
        let s = AVAudioSession.sharedInstance()
        let _ = try? s.setActive(false)
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        captureSession = nil
        
    }
    func searchUser(){
        removeChooseACountry()
        self.exitButton.isHidden = false
        stioSession()
        
        SpecialLoading.SI.setSmallLoadingTo(searchingView, atCenter: CGPoint(x: kScreen.width / 2, y: isIpad ? 197 : 115))
        for v in bannerView.subviews{
            v.removeFromSuperview()
        }
        AdsClass.si().showGoogleBanner(CGPoint.zero, controller: self, in: self.bannerView, unitID: "ca-app-pub-5755016420114701/8384615479", andSize: kGADAdSizeMediumRectangle)
        self.hideMenu()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.searchingView.alpha = 1.0
            }, completion: { (finished) -> Void in
                dispatchAfter(2, dispatchBlock: { () -> Void in
                    if !UD.bool(forKey: "exitActionBool"){
                        self.exitButton.isHidden = true
                        self.search(myData.myUser)
                    }
                })
        }) 
    }
    func stopSearchUser(){
        unhideMenuVar = true
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.searchingView.alpha = 0
        }) 
        SpecialLoading.SI.stopLoadin()
    }
    

    @IBAction func exitAction(_ sender: AnyObject) {
        UD.set(true, forKey: "exitActionBool")
        stioSession()
        checkCamera1()
        deleteFromBase { () -> Void in
            self.hideConnectionElements()
            videoChatClass.sharedInstance().exit()
            self.stopSearchUser()
            self.unHideMenu()
        }
    }
    
    func beginNewSearch(){
        self.hideConnectionElements()
        hideMenu()
        searchUser()
    }
    func videoTrackBegin() {
        unhideMenuVar = false
        canPlayVideo = true
        if UD.bool(forKey: "fistConnect") == true{
            UD.set(false, forKey: "fistConnect")
        }
    }
    func didOpenDialog() {
//        MARK: I call
        if !heCallMe{
            connectingAnimations(partener.id as! NSNumber){
                self.call()
            }
        }else{
            heCallMe = false
        }
    }
//        MARK: He call
    func heCallMe(_ userID: NSNumber!) {
        self.exitButton.isHidden = true
        heCallMe = true
        partener.id = userID.uintValue
        connectingAnimations(userID){ () -> Void in
            self.heCallMe = false
        }
    }
    func connectingAnimations(_ userID: NSNumber, spComp:(()->Void)?){
        pushTimer?.invalidate()
        pushTimer = nil
        unhideMenuVar = false
        recallSwipe.isEnabled = false
        let startBlock = { () -> Void in
            for v in self.bannerView2.subviews{
                v.removeFromSuperview()
            }
            AdsClass.si().showGoogleBanner(CGPoint.zero, controller: self, in: self.bannerView2, unitID: "ca-app-pub-5755016420114701/9721747879", andSize: isIpad ? kGADAdSizeLeaderboard : kGADAdSizeLargeBanner)
            self.getStartedToConnect({ () -> Void in
                self.cnLBL.isHidden = false
                self.pBG.isHidden = false
                self.pUserImageView.isHidden = false
                self.bannerView2.isHidden = false
                self.pNameLabel.isHidden = false
                self.pFlag.isHidden = false
                self.pCountryLabel.isHidden = false
                self.pDataView.isHidden = false
                
                self.pUserImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.stopSearchUser()
                UIView.animate(withDuration: 2.0, animations: { () -> Void in
                    self.pUserImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.recallSwipe.isEnabled = true
                    self.exitButton.isEnabled = true
                    }, completion: { (finisehd) -> Void in
                        self.canPlayVideoAfterAnimations = true
                })
            })
        }
        let ID = userID.intValue
        let id_user = "\(ID)"
        if let hm = DB.si().selectRow(withQyery: "SELECT * FROM `r_friends` WHERE `id_human` = ? AND `id_user` = ?", andParams: [id_user, myData.id]) as? [String: String]{
            if hm.count != 0{
                spComp?()
                let country = hm["country"]!
                let photo = hm["image"]!
                self.pUserImageView.setImageWith(URL(string: photo)!)
                self.pFlag.setImage(getCountryFlagImage(country), for: UIControlState())
                self.pCountryLabel.text = country
                self.pNameLabel.text = hm["name"]
                startBlock()
                return
            }
        }
        getUserInfoByID("\(ID)", comp: { (data) -> Void in
            print(data)
            spComp?()
            let id_facebook = data["id_facebook"]!
            let country = data["country"] ?? "USA"
            let photo = "https://graph.facebook.com/\(id_facebook)/picture?type=large"
            let userCode = data["userID"]!
            self.pUserImageView.setImageWith(URL(string: photo)!)
            self.pFlag.setImage(getCountryFlagImage(country), for: UIControlState())
            self.pCountryLabel.text = country
            let req = FBSDKGraphRequest(graphPath: "/\(id_facebook)", parameters: ["fields": "id, name, location"], httpMethod: "GET")
            req?.start(completionHandler: { (connection, result, error) -> Void in
                if error == nil{
                    if let res = result as? [String: AnyObject]{
                        print(res)
                        let name = res["name"] as? String ?? "Unknown**"
                        let newName: String!
                        let nameComp = name.components(separatedBy: " ")
                        if nameComp.count > 1{
                            newName = nameComp[0].substring(to: nameComp[0].characters.index(nameComp[0].startIndex, offsetBy: nameComp[0].characters.count-2)) + "**"
                        }else{
                            newName = name.substring(to: name.characters.index(name.startIndex, offsetBy: name.characters.count-2)) + "**"
                        }
                        self.pNameLabel.text = newName
                        let query = "INSERT INTO `r_friends` (`id_human`, `id_user`, `name`, `country`, `image`, `friend`, `code`) VALUES (?, ?, ?, ?, ?, 0, ?)"
                        DB.si().request(withQuery: query, andParams: [id_user, myData.id, newName, country, photo, userCode])
                        startBlock()
                    }else{
                        self.exitButton.isEnabled = true
                        self.recallSwipe.isEnabled = true
                        self.recallAction(userID)
                    }
                }else{
                    self.exitButton.isEnabled = true
                    self.recallSwipe.isEnabled = true
                    self.recallAction(userID)
                }
            })
            }) { () -> Void in
                self.exitButton.isEnabled = true
                self.recallSwipe.isEnabled = true
                self.recallAction(userID)
        }
    }
    func didNotOpenDialog() {
        searchUser()
    }
    func messageSendError(_ message: String!) {
        
    }
    func haveMessage(_ message: String!, senderID: UInt) {
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let messageDate = dateF.string(from: Date())
        insertMessageIntoBase("\(senderID)", type: "his", message: message, messageDate: messageDate)
    }
    func call(){
        videoChatClass.sharedInstance().callUsers(withIDs: [partener.id])
    }
    func sendMessage(_ message: String){
        messagingClass.sharedInstance().sendMesage(message)
    }
    var recall = false
    @IBAction func recallAction(_ sender: AnyObject) {
        recall = true
        UD.set(false, forKey: "exitActionBool")
        SpecialLoading.SI.startLoad()
        if first{
            searchUser()
            first = false
        }else{
            recall = false
            videoChatClass.sharedInstance().hangUp()
        }
    }
    
    
    //    MARK: CAMERA
    var captureSession : AVCaptureSession? = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    func checkCamera1(){
        if captureSession == nil{
            captureSession = AVCaptureSession()
        }
        captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices! {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if((device as AnyObject).position == AVCaptureDevicePosition.front) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginSession()
                    }
                }
            }
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            let _ = try? device.lockForConfiguration()
            if device.isFocusModeSupported(.locked){
                device.focusMode = .locked
            }
            device.unlockForConfiguration()
        }
        
    }
    
    @IBOutlet var permissionsView: UIView!
    func beginSession() {
        configureDevice()
        
        let s = AVAudioSession.sharedInstance()
        let _ = try? s.setCategory(AVAudioSessionCategoryPlayAndRecord)
        let _ = try? s.setActive(true)
        
        
        if s.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))){
            s.requestRecordPermission({ (ss) -> Void in
                print(ss)
            })
        }

        
        captureSession?.addInput(try? AVCaptureDeviceInput(device: captureDevice))
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        if let previewLayer = previewLayer{
            if let sls = selfVideoView.layer.sublayers{
                for sl in sls{
                    sl.removeFromSuperlayer()
                }
            }
            selfVideoView.layer.addSublayer(previewLayer)
            
            startHandAnimation()
        }
        var plFrame = self.view.layer.frame
        plFrame.size.height = isIpad ? (kScreen.height * (1024 / 768)) : kScreen.height + 4
        plFrame.origin = CGPoint(x: 0, y: -((plFrame.size.height - kScreen.height) / 2))
        previewLayer?.frame = plFrame
        captureSession?.startRunning()
        let autS = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        let autS2 = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        if AVAuthorizationStatus.authorized != autS || AVAuthorizationStatus.authorized != autS2{
            selfVideoView.isHidden = true
            permissionsView.isHidden = false
        }else{
            selfVideoView.isHidden = false
            permissionsView.isHidden = true
        }
    }
    
    //    MARK: CAMERA
    
    func showLocationsAlert(_ show: Bool){
        locationsAlertView.center = show ? self.view.center : CGPoint(x: self.view.frame.width + self.view.center.x * 2, y: self.view.center.y)
    }
    @IBAction func gotoshop(_ sender: AnyObject) {
        cancelLocationAlertAction(sender)
        buyGemsAction(sender)
    }
    @IBAction func cancelLocationAlertAction(_ sender: AnyObject) {
        showLocationsAlert(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handAnimationImageView = UIImageView()
        permissionsView.isHidden = true
        searchingView.alpha = 0
        myGems.text = "\(myData.gems)"
        myName.text = myData.name
        myCountry.text = myData.country
        myFlag.setImage(myData.flagImage, for: UIControlState())
        
        messagingClass.sharedInstance().delegate = self
        videoChatClass.sharedInstance()
        videoChatClass.sharedInstance().delegate = self
        videoChatClass.sharedInstance().globalView = videoView
        
        //        videoView.addSubview(videoChatClass.sharedInstance())
        partener = QBUUser()
        getOfflineMessages()
        
        hideConnectionElements()
        
        if UD.integer(forKey: "countOfEnters") >= 4{
            genderPerferenceViewOpen(true)
            UD.set(0, forKey: "countOfEnters")
        }
        
    }
    func removeChooseACountry(){
        chooseACountryImageView?.stopAnimating()
        chooseACountryImageView?.removeFromSuperview()
        chooseACountryImageView = nil
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeChooseACountry()
        if handAnimationImageView != nil{
            handAnimationImageView.stopAnimating()
            handAnimationImageView.removeFromSuperview()
            handAnimationImageView = nil
        }
    }
    func hideConnectionElements(){
        cnLBL.isHidden = true
        pBG.isHidden = true
        pUserImageView.isHidden = true
        addToFriendsButton.isHidden = true
        writeMessageButton.isHidden = true
        reportUserButton.isHidden = true
        pNameLabel.isHidden = true
        pFlag.isHidden = true
        pCountryLabel.isHidden = true
        pDataView.isHidden = true
        bannerView2.isHidden = true
    }
    
    @IBAction func buyGemsAction(_ sender: AnyObject) {
        removeChooseACountry()
        let ss = SlideNavigationController.sharedInstance()
        (ss?.bottomMenu as! RBottomMenuViewController).hideMenu { () -> Void in
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "buyController") as! RBuyGemsViewController
            controller.unhideMenu = self.unhideMenuVar
            ss?.pushViewController(controller, animated: true)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override var prefersStatusBarHidden : Bool {
        return false
    }
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = UIApplication.shared.keyWindow{
            if let bottomMenu = SlideNavigationController.sharedInstance().bottomMenu as? RBottomMenuViewController{
                if unhideMenuVar{
                    bottomMenu.view.isHidden = false
                    bottomMenu.showMenu(nil)
                }
            }
        }
        if videoChatClass.sharedInstance().superview != videoView{
            myGems.text = "\(myData.gems)"
            stioSession()
            checkCamera1()
        }
        startHandAnimation()
        if UD.bool(forKey: "fistConnect"){
            chooseACountry()
        }
    }
    
    func startHandAnimation(){
        if handAnimationImageView == nil{
            handAnimationImageView = UIImageView()
        }
        var imgs = [UIImage]()
        for index in 0..<36 {
            let filename: String!
            if index < 10{
                filename = "1_Camera000\(index)"
            }else{
                filename = "1_Camera00\(index)"
            }
            if let im = UIImage(named: filename){
                imgs.append(im)
            }
        }
        if imgs.count > 0{
            handAnimationImageView.animationImages = imgs
            handAnimationImageView.animationRepeatCount = 0
            handAnimationImageView.animationDuration = 1.4
            handAnimationImageView.frame.size =  CGSize(width: 93, height: 109)
            handAnimationImageView.center = CGPoint(x: kScreen.width / 2 + 5, y: (isIpad ? 870 : 472) - handAnimationImageView.frame.size.height / 2)
            
            handAnimationImageView.startAnimating()
            self.selfVideoView.addSubview(handAnimationImageView)
            self.selfVideoView.bringSubview(toFront: handAnimationImageView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func locationsFilterAction(_ sender: AnyObject) {
        removeChooseACountry()
        self.recallSwipe.isEnabled = false
        if let locationsController = self.storyboard?.instantiateViewController(withIdentifier: "locationsController") as? RLocationsViewController{
            locationsController.unhideMenu = videoChatClass.sharedInstance().superview != videoView
            locationsController.genderOrLocations = (false, true)
            locationsController.selectedCountrysBlock = { (locations: [[String: String]]) -> Void in
                self.recallSwipe.isEnabled = true
                print(locations)
                if locations.count > 0{
                    locationsFiltres = ""
                    for location in locations{
                        locationsFiltres += location["name"]! + ","
                    }
                    locationsFiltres = locationsFiltres.substring(to: locationsFiltres.characters.index(locationsFiltres.startIndex, offsetBy: locationsFiltres.characters.count - 1))
                }else{
                    locationsFiltres = ""
                }
            }
            hideMenu()
            self.addChildViewController(locationsController)
            locationsController.didMove(toParentViewController: self)
            self.view.addSubview(locationsController.view)
            locationsController.view.frame.origin = CGPoint(x: 0, y: kScreen.height)
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                locationsController.view.frame.origin = CGPoint(x: 0, y: 0)
            })
        }
    }
    @IBAction func genderFilterAction(_ sender: AnyObject) {
        removeChooseACountry()
        self.recallSwipe.isEnabled = false
        self.buyGemsButton.isEnabled = false
        if let locationsController = self.storyboard?.instantiateViewController(withIdentifier: "locationsController") as? RLocationsViewController{
            locationsController.unhideMenu = videoChatClass.sharedInstance().superview != videoView
            locationsController.genderOrLocations = (true, true)
            locationsController.selectedGenresBlock = { (genres: [[String: String]]) -> Void in
                self.recallSwipe.isEnabled = true
                self.buyGemsButton.isEnabled = true
                print(genres)
                if genres.count > 0{
                    genresFilters = ""
                    for gen in genres{
                        genresFilters += gen["name"]! + ","
                    }
                    genresFilters = genresFilters.substring(to: genresFilters.characters.index(genresFilters.startIndex, offsetBy: genresFilters.characters.count - 1))
                }else{
                    genresFilters = ""
                }
            }
            hideMenu()
            self.addChildViewController(locationsController)
            locationsController.didMove(toParentViewController: self)
            self.view.addSubview(locationsController.view)
            locationsController.view.frame.origin = CGPoint(x: 0, y: kScreen.height)
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                locationsController.view.frame.origin = CGPoint(x: 0, y: kScreen.height - (isIpad ? 264 : 156))
            })
        }
    }
    
    //    MARK: VIDEOVIEWITEMS
    
    func getStartedToConnect(_ comp: (()->Void)?){
        self.pUserImageView.alpha = 1
        UIView.animate(withDuration: 0, animations: { () -> Void in
            self.pNameLabel.center = isIpad ? CGPoint(x: kScreen.width / 2, y: 433) : CGPoint(x: 160, y: 255)
            self.pFlag.center = isIpad ? CGPoint(x: 347, y: 489) : CGPoint(x: 143, y: 278)
            self.pCountryLabel.center = isIpad ? CGPoint(x: 410, y: 489) : CGPoint(x: 185, y: 278)
            
            }, completion: { (finisehd) -> Void in
                self.addToFriendsButton.isHidden = true
                self.writeMessageButton.isHidden = true
                self.reportUserButton.isHidden = true
                comp?()
        }) 
    }
    
    func interfaceUserConnected(_ comp:(()->Void)?){
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.pNameLabel.center = isIpad ? CGPoint(x: kScreen.width / 2, y: 60) : CGPoint(x: 141, y: 37)
            self.pFlag.center = isIpad ? CGPoint(x: 524, y: 61) : CGPoint(x: 209, y: 38)
            self.pCountryLabel.center = isIpad ? CGPoint(x: 586, y: 61) : CGPoint(x: 246, y: 37)
            
            }, completion: { (finisehd) -> Void in
                self.addToFriendsButton.isHidden = false
                self.writeMessageButton.isHidden = false
                self.reportUserButton.isHidden = false
                comp?()
        }) 
    }
    @IBOutlet var addToFriendsButton: UIButton!
    @IBOutlet var writeMessageButton: UIButton!
    @IBOutlet var reportUserButton: UIButton!
    
    @IBOutlet var cnLBL: UILabel!
    @IBOutlet var pBG: UIImageView!
    @IBOutlet var pNameLabel: UILabel!
    @IBOutlet var pFlag: UIButton!
    @IBOutlet var pCountryLabel: UILabel!
    @IBOutlet var pDataView: UIView!
    @IBOutlet var pUserImageView: UIImageView!
    @IBOutlet var bannerView2: UIView!
    
    @IBAction func addToFriendsAction(_ sender: AnyObject) {
        if myData.code != "none" && myData.code != ""{
            SpecialLoading.SI.startLoad()
            let baseURL = URL(string: "http://vidlerr.com")!
            let manager = AFHTTPSessionManager(baseURL: baseURL)
            manager.post("applications/roomy/data.php",
                parameters: [
                    "type" : "sendFriendRequest2",
                    "id_user" : myData.id,
                    "id_facebook" : myData.facebook,
                    "to_userID" : "\(partener.id)"
                ],
                progress: nil,
                success: { (operation, resp) -> Void in
                    if let resp = resp as? [String: AnyObject]{
                        if let _ = resp["send"]{
                            print("request sended")
                            let alert = UIAlertController(title: "Request sended", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        if let gems = resp["gems"] as? Int{
                            updateGems(gems)
                            self.myGems.text = "\(gems)"
                        }
                        if let error = resp["error"] as? String{
                            if error == "already"{
                                let alert = UIAlertController(title: "Request field", message: "You have already sent a request to this user.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            if error == "not_exists"{
                                let alert = UIAlertController(
                                    title: "Request field",
                                    message: "That user do not have special ID." +
                                        "\nPlease tell him about it." +
                                    "\nTo create it you need to click on the \"Add to Friends\" or in the \"Friends\" tab.",
                                    preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            if error == "not_enough"{
                                let alert = UIAlertController(
                                    title: "Request field",
                                    message: "You don't have enough gems for add friend.\nYou have to need 300 gems for add new friend.",
                                    preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Purchase gems", style: UIAlertActionStyle.default){ (action) -> Void in
                                    self.buyGemsAction(action)
                                    })
                                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    SpecialLoading.SI.stopLoadin()
                }) { (operation, error) -> Void in
                    SpecialLoading.SI.stopLoadin()
            }
        }else{
            changeMyCode(self, sender: nil)
        }
    }
    @IBAction func writeMessageAction(_ sender: AnyObject) {
        let ss = SlideNavigationController.sharedInstance()
        (ss?.bottomMenu as! RBottomMenuViewController).hideMenu { () -> Void in
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "messagesController") as! RMessagesViewController
            controller.id_human = "\(partener.id)"
            controller.unhideMenu = false
            let data2 = DB.si().selectRow(withQyery: "SELECT * FROM `r_friends` WHERE `id_human` = ? AND `id_user` = ?", andParams: [controller.id_human, myData.id])
            guard let data = data2 as? [String: String] else{
                return
            }
            let hum = Human(id:controller.id_human, name:data["name"]!, imagePath:data["image"]! as NSString!, country:data["country"]!, flagImage: getCountryFlagImage(data["country"]!))
            controller.human = hum
            ss?.pushViewController(controller, animated: true)
        }
    }
    @IBAction func reportUserAction(_ sender: AnyObject) {
        let screenShot = BannerReviewClass.sharedInstance().screenshot(from: self)
        let partenerID = "\(partener.id)"
        let myID = myData.id
        composeMail(screenShot!, text:"My id: " + myID! + "\nOther id: " + partenerID)
    }
    var mailComposeVC: MFMailComposeViewController?
    func composeMail(_ image: UIImage, text: String) {
        mailComposeVC = MFMailComposeViewController()
        if let mailComposeVC = mailComposeVC{
            //            mailComposeVC.addAttachmentData(UIImageJPEGRepresentation(image, CGFloat(1.0))!, mimeType: "image/jpeg", fileName:  "screenshot.jpeg")
            mailComposeVC.setSubject("Report that user.")
            mailComposeVC.setToRecipients(["info.publicartexpert@gmail.com"])
            mailComposeVC.setCcRecipients(nil)
            mailComposeVC.setBccRecipients(nil)
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setMessageBody("<html><body><p>" + text + "</p></body></html>", isHTML: true)
            self.present(mailComposeVC, animated: true, completion: nil)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true){ () -> Void in
            self.hideMenu()
        }
        controller.dismiss(animated: true){ () -> Void in
            self.hideMenu()
        }
    }
    
//    MARK: Gender Perference
    @IBOutlet var genderPerferenceView: UIView!
    @IBOutlet var femaleButton: UIButton!
    @IBOutlet var maleButton: UIButton!
    @IBOutlet var closeGenderPerferencesButton: UIButton!
    
    @IBAction func genderPerferenceAction(_ sender: UIButton) {
        femaleButton.isSelected = false
        maleButton.isSelected = false
        sender.isSelected = true
    }
    @IBAction func close(_ sender: AnyObject) {
        genderPerferenceViewOpen(false)
    }
    func genderPerferenceViewOpen(_ open: Bool){
        genderPerferenceView.center = open ? self.view.center : CGPoint(x: self.view.frame.width + self.view.center.x * 2, y: self.view.center.y)
        recallSwipe.isEnabled = !open
    }
    @IBAction func confirmGenderPerferenceAction(_ sender: AnyObject) {
        if femaleButton.isSelected{
            genresFilters = "Female"
        }
        if maleButton.isSelected{
            genresFilters = "Male"
        }
        close(sender)
    }
    
    
    
    
}
