//
//  RMessagesViewController.swift
//  VideoChat
//
//  Created by Farshx on 20/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit


func insertMessageIntoBase(_ id_human: String, type: String, message: String, messageDate: String){
    let lastInsertedMessageID = DB.si().selectRow(withQyery: "SELECT MAX(`id_messge`) as m FROM `r_message`", andParams: nil)["m"] ?? "1"
    let lastInsertedMessageIDInt = ((lastInsertedMessageID as AnyObject).intValue ?? 1) + 1
    let query = "INSERT INTO `r_message` (`id_messge`, `id_user`, `id_human`, `type`, `message`, `date`) VALUES (?, ?, ?, ?, ?, ?)"
    DB.si().request(withQuery: query, andParams: [lastInsertedMessageIDInt, myData.id, id_human, type, message, messageDate])
}


class RMessagesViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, MessagingDelegate {
    
    //    MARK: Lets
    let ss = SlideNavigationController.sharedInstance()
    
    //    MARK: Vars
    var keyboardOpend = false
    var id_human: String!
    var human: Human! = nil
//    var history = false
    var messages = [[String: String]]()
    var lastMessageViewY: CGFloat = 0
    var lastDate = String()
    var unhideMenu = true
    
    //    MARK: Outlets
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var messagesScrollView: UIScrollView!
    @IBOutlet var sendMessageContentView: UIView!
    @IBOutlet var userImageView: UIView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text == "Your message"{
            textField.text = ""
        }
        textField.textColor = .black
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.characters.count == 0{
            textField.text = "Your message"
            textField.textColor = UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessageButtonAction(sendMessageButton)
        return true
    }
    
    func didOpenDialog() {
        SpecialLoading.SI.stopLoadin()
    }
    func didNotOpenDialog() {
        SpecialLoading.SI.stopLoadin()
        userIsOffline()
    }
    func messageSendError(_ message: String) {
        sendOfflineMessage(message)
//        FBSDKMessengerSharer.shareAudio(<#T##audioData: NSData!##NSData!#>, withOptions: <#T##FBSDKMessengerShareOptions!#>)
    }
    func haveMessage(_ message: String!, senderID: UInt) {
        msg(message, type: "his")
    }
    func userIsOffline(){
        let alert = UIAlertController(title: "Offline", message: "That user is offline", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SpecialLoading.SI.startLoad()
        messagingClass.sharedInstance().delegate = self
        NC.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { (sender) -> Void in
            let keyboardInfo:Dictionary = sender.userInfo!
            let keyboardFrameBegin:NSValue = keyboardInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
            let keyboardFrame = keyboardFrameBegin.cgRectValue
            var smFrame = self.sendMessageContentView.frame
            var msvFrame = self.messagesScrollView.frame
            if !self.keyboardOpend{
                smFrame.origin.y = kScreen.height - keyboardFrame.height - smFrame.height
                msvFrame.size.height = kScreen.height - keyboardFrame.height - smFrame.height - msvFrame.origin.y
                self.keyboardOpend = true
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.sendMessageContentView.frame = smFrame
                    self.messagesScrollView.frame     = msvFrame
                    self.messagesScrollView.contentOffset = CGPoint(x: 0, y: self.messagesScrollView.contentSize.height - msvFrame.size.height)
                })
            }
        }
        
        let query = "SELECT * FROM `r_message` WHERE `id_user` = ? AND `id_human` = ?"
        let tempMessages = DB.si().selectRows(withQyery: query, andParams: [myData.id, id_human])
        
        if tempMessages?.count != 0{
            let tempMessage = tempMessages?[0] as! [String: String]
            lastDate = tempMessage["date"]!
            createDate(lastDate)
        }
        
        for tempMessage in tempMessages!{
            if let tempMessage = tempMessage as? [String: Any]{
                let tempLastDate = lastDate.components(separatedBy: " ")[0]
                let messageDate = tempMessage["date"] as! String
                let tempMessageDate = messageDate.components(separatedBy: " ")[0]
                if tempLastDate != tempMessageDate{
                    createDate(tempMessage["date"] as! String)
                    lastDate = messageDate
                }
                createMessage(tempMessage["message"] as! String, type: tempMessage["type"] as! String, time: messageDate)
            }
        }
        
        userName.text = human.name
        MCImageCache.shared().loadImage(withURLPath: human.imagePath as String, index: 0) { (image, index) -> Void in
            if index == 0 && image != nil{
                self.userImage.image = image
            }
        }
        
        
        userImage.layer.shadowOffset = CGSize(width: 0, height: 0);
        userImage.layer.shadowRadius = self.userImage.frame.width;
        userImage.layer.shadowOpacity = 1;
        userImage.layer.shadowColor = UIColor.black.cgColor
        userImageView.layer.shadowOffset = CGSize(width: 0, height: 0);
        userImageView.layer.shadowRadius = self.userImage.frame.width;
        userImageView.layer.shadowOpacity = 1;
        userImageView.layer.shadowColor = UIColor.black.cgColor
        let partner = QBUUser()
        partner.id = UInt(id_human)!
        messagingClass.sharedInstance().createANewDialog(withMe: myData.myUser, andOponent: partner)
    }
    
    func createDate(_ date: String){
        let separatorImage = UIImage(named: "6_separator")
        let separatorImageView = UIImageView(image: separatorImage)
        var sivFrame = separatorImageView.frame
        sivFrame.size = CGSize(width: kScreen.width, height: 1)
        sivFrame.origin.y = isIpad ? 25 : 19
        separatorImageView.frame = sivFrame
        
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let dateFromString = dateF.date(from: date)
        dateF.dateFormat = "EEEE dd,"
        
        let dateLabel = UILabel()
        dateLabel.text = dateF.string(from: dateFromString ?? Date())
        dateLabel.font = UIFont(name: "Aileron-Regular", size: isIpad ? 13: 11)!
        dateLabel.textColor = UIColor(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1.0)
        dateLabel.textAlignment = .left
        dateLabel.sizeToFit()
        
        dateF.dateFormat = "MMM yyyy"
        
        let dateLabel2 = UILabel()
        dateLabel2.text = dateF.string(from: dateFromString ?? Date())
        dateLabel2.font = UIFont(name: "Aileron-Light", size: isIpad ? 13: 11)!
        dateLabel2.textColor = UIColor(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1.0)
        dateLabel2.textAlignment = .left
        dateLabel2.sizeToFit()
        
        let timeViewFrame = CGRect(x: 0, y: lastMessageViewY + (isIpad ? 20 : 10), width: kScreen.width, height: isIpad ? 30 : 20)
        let timeView = UIView(frame: timeViewFrame)
        timeView.backgroundColor = .clear
        timeView.addSubview(separatorImageView)
        
        var dlFrame = dateLabel.frame
        dlFrame.origin.x = isIpad ? 20 : 13
        dlFrame.origin.y = timeView.frame.height / 2 - dlFrame.height / 2
        dateLabel.frame = dlFrame
        
        var dlFrame2 = dateLabel2.frame
        dlFrame2.origin.x = dlFrame.width + dlFrame.origin.x + 3
        dlFrame2.origin.y = dlFrame.origin.y + (dlFrame.height - dlFrame2.height)
        dateLabel2.frame  = dlFrame2
        
        timeView.addSubview(dateLabel)
        timeView.addSubview(dateLabel2)
        
        messagesScrollView.addSubview(timeView)
        messagesScrollView.contentSize.height = lastMessageViewY + (isIpad ? 12 : 6)
        lastMessageViewY = timeView.frame.height + timeView.frame.origin.y
    }
    
    
    func createMessage(_ message: String, type: String = "my", time: String, animated: Bool = false){
        if message.characters.count != 0{
            let messageView = UIView(frame: CGRect(x: 0, y: lastMessageViewY + (isIpad ? 12 : 6), width: kScreen.width, height: 0))
            let maxWidth = CGFloat(isIpad ? 703 : 289)
            
            let textLabel = UILabel()
            textLabel.frame.origin = CGPoint(x: 10, y: 10)
            textLabel.font = UIFont(name: "Aileron-Regular", size: isIpad ? 15: 14)!
            textLabel.text = message
            textLabel.textColor = type == "my" ? .white : .black
            textLabel.numberOfLines = 0
            textLabel.sizeToFit()
            let newSize = textLabel.sizeThatFits(CGSize(width: maxWidth, height: textLabel.frame.height))
            if newSize.width <= maxWidth + 1{
                textLabel.frame.size = newSize
            }
            
            let timeLabel = UILabel()
            timeLabel.font = UIFont(name: "Aileron-Light", size: 9)
            timeLabel.textColor = UIColor(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1.0)
            let time = time.components(separatedBy: " ")[1].components(separatedBy: ":")
            timeLabel.text = time[0] + ":" + time[1]
            timeLabel.sizeToFit()
            
            var tvFrame = textLabel.frame
            tvFrame.size.height = tvFrame.size.height + 20
            tvFrame.size.width = tvFrame.size.width + 20
            
            let mTempView = UIView(frame: CGRect(x: type != "my" ? 13 : kScreen.width - 13 - tvFrame.width, y: 0, width: tvFrame.width, height: tvFrame.height))
            
            var mVFrane = messageView.frame
            mVFrane.size.height = textLabel.frame.height + (isIpad ? 32 : 16)
            messageView.frame = mVFrane
            
            mTempView.backgroundColor = type == "my" ?
                UIColor(red: 11 / 255.0, green: 183 / 255.0, blue: 230 / 255.0, alpha: 1.0) :
                UIColor(red: 238 / 255.0, green: 238 / 255.0, blue: 238 / 255.0, alpha: 1.0)
            mTempView.layer.cornerRadius = 6
            mTempView.layer.masksToBounds = true
            mTempView.addSubview(textLabel)
            
            let arrow = UIImageView(image: UIImage(named: type == "my" ? "7_bubble_arrow_blue" : "7_bubble_arrow_grey"))
            var arFrame = arrow.frame
            arFrame.origin.x = type != "my" ? 13 : kScreen.width - arFrame.width - 13
            
            var tlFrame = timeLabel.frame
            tlFrame.origin.x = type != "my" ? mTempView.frame.origin.x + (isIpad ? 12 : 8) : kScreen.width - tlFrame.width - (isIpad ? 12 : 8) - 13
            tlFrame.origin.y = mTempView.frame.height + (isIpad ? 10 : 4)
            timeLabel.frame = tlFrame
            
            arFrame.origin.y = timeLabel.center.y - arFrame.height
            arrow.frame = arFrame
            
            messageView.frame.size.height = timeLabel.frame.origin.y + timeLabel.frame.size.height + CGFloat(isIpad ? 12 : 6)
            
            messageView.addSubview(arrow)
            messageView.addSubview(mTempView)
            messageView.addSubview(timeLabel)
            
            lastMessageViewY = messageView.frame.height + messageView.frame.origin.y
            
            messagesScrollView.addSubview(messageView)
            messagesScrollView.contentSize.height = lastMessageViewY + (isIpad ? 12 : 6)
            messages.append([
                "message" : message,
                "type"    : type
                ])
            
            
            if messagesScrollView.contentSize.height > messagesScrollView.frame.height{
                let point = CGPoint(x: 0, y: messagesScrollView.contentSize.height - messagesScrollView.frame.height)
                if animated{
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.messagesScrollView.contentOffset = point
                    })
                }else{
                    messagesScrollView.contentOffset = point
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if unhideMenu{
            (ss?.bottomMenu as! RBottomMenuViewController).unHideMenu()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func closeKeyboardAction(_ sender: AnyObject) {
        messageTextField.resignFirstResponder()
        if self.keyboardOpend{
            var smFrame = self.sendMessageContentView.frame
            var msvFrame = self.messagesScrollView.frame
            smFrame.origin.y = kScreen.height - smFrame.height
            msvFrame.size.height = kScreen.height - smFrame.height - msvFrame.origin.y
            self.keyboardOpend = false
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.sendMessageContentView.frame = smFrame
                self.messagesScrollView.frame     = msvFrame
            })
        }
    }
    
    func msg(_ message: String, type: String){
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let tempLastDate = lastDate.components(separatedBy: " ")[0]
        let messageDate = dateF.string(from: Date())
        let tempMessageDate = messageDate.components(separatedBy: " ")[0]
        if tempLastDate != tempMessageDate{
            createDate(messageDate)
            lastDate = messageDate
        }
        insertMessageIntoBase(id_human, type: type, message: message, messageDate: messageDate)
        createMessage(message, type: type, time: messageDate, animated: true)
    }
    
    func sendOfflineMessage(_ message: String){
        let baseURL = URL(string: "http://vidlerr.com")!
        let manager = AFHTTPSessionManager(baseURL: baseURL)
        manager.post("applications/roomy/data.php",
            parameters: [
                "type" : "sendMessageOffline",
                "id_user_from" : myData.id,
                "id_user_to" : id_human,
                "message" : message
            ], progress: nil, 
            success: { (operation, result) -> Void in
                print(result)
            }) { (operation, error) -> Void in
                print(error)
        }
    }
    
    @IBAction func sendMessageButtonAction(_ sender: UIButton) {
        if messageTextField.text != "Your message"{
            if let message = messageTextField.text {
                if message != ""{
                    msg(message, type: "my")
                    messagingClass.sharedInstance().sendMesage(message)
                    messageTextField.text = ""
                    
                    QBRequest.user(withID: partener.id, successBlock: { (responce, user) in
                        guard let user = user else{
                            return
                        }
                        if let lastDate = user.lastRequestAt{
                            let dif = lastDate.timeIntervalSince(Date())
                            if dif >= 60{
                                QBRequest.sendPush(withText: "I wrote to you a new message, " + myData.name + "!",
                                    toUsers: "\(partener.id)",
                                    successBlock: { (resp, events) in
                                        
                                    }, errorBlock: { (error) in
                                        
                                })
                            }
                        }
                    }, errorBlock: { (responce) in
                            
                    })
                    
                    if !keyboardOpend{
                        messageTextField.text = "Your message"
                        messageTextField.textColor = UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0)
                    }
                }
            }
        }
    }
    @IBAction func backButtonAction(_ sender: AnyObject) {
        messagingClass.sharedInstance().leaveDialog()
        ss?.popViewController(animated: true)
    }
    
}
