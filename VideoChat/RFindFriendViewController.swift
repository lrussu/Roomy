//
//  RFindFriendViewController.swift
//  VideoChat
//
//  Created by Farshx on 20/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit
import Social
import Accounts
import MessageUI
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



func changeMyCode(_ controller: UIViewController, sender: UIButton?){
    let alert = UIAlertController(title: "Change your ID:", message: "ID must be longer than 5 characters.", preferredStyle: UIAlertControllerStyle.alert)
    alert.addTextField { (textField) -> Void in
        textField.placeholder = "Your ID"
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
        
    }))
    alert.addAction(UIAlertAction(title: "Change", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
        if let textFields = alert.textFields{
            let textField = textFields[0]
            if textField.text != nil && textField.text?.characters.count > 4{
                if textField.text != sender?.titleLabel?.text && textField.text != "User ID"{
                    SpecialLoading.SI.startLoad()
                    let baseURL = URL(string: "http://vidlerr.com")!
                    let manager = AFHTTPSessionManager(baseURL: baseURL)
                    manager.post("applications/roomy/data.php",
                        parameters: [
                            "type" : "userIDVerifity",
                            "userID" : textField.text!,
                            "id_user" : myData.id,
                            "id_facebook" : myData.facebook,
                            "country" : myData.country
                        ], progress: nil,
                        success: { (operation, resp) -> Void in
                            if let resp = resp as? [String: String]{
                                if let error = resp["error"]{
                                    print(error)
                                    if error == "already"{
                                        sender?.setTitle(textField.text, for: UIControlState())
                                        myData.code = textField.text
                                        let query = "UPDATE `r_user` SET `code` = ? WHERE `id_user` = ? AND `id_facebook` = ?"
                                        DB.si().request(withQuery: query, andParams: [myData.code, myData.id, myData.facebook])
                                        let alert2 = UIAlertController(title: "That ID is setted.", message: "Please enter another id.", preferredStyle: UIAlertControllerStyle.alert)
                                        alert2.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                                        controller.present(alert2, animated: true, completion: nil)
                                    }else if error == "exists" || error == "error_update" || error == "error_insert"{
                                        let alert2 = UIAlertController(title: "That ID is already used.", message: "Please enter another id.", preferredStyle: UIAlertControllerStyle.alert)
                                        alert2.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                                        controller.present(alert2, animated: true, completion: nil)
                                    }
                                }
                                if let _ = resp["userID"]{
                                    sender?.setTitle(textField.text, for: UIControlState())
                                    myData.code = textField.text
                                    let query = "UPDATE `r_user` SET `code` = ? WHERE `id_user` = ? AND `id_facebook` = ?"
                                    DB.si().request(withQuery: query, andParams: [myData.code, myData.id, myData.facebook])
                                }
                            }
                            SpecialLoading.SI.stopLoadin()
                        },
                        failure: { (operation, error) -> Void in
                            SpecialLoading.SI.stopLoadin()
                    })
                }
            }
        }
    }))
    controller.present(alert, animated: true, completion: nil)
}


class RFindFriendViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
//  MARK: Outlets
    
    @IBOutlet var yourID: UILabel!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var addToFriendsButton: UIButton!
    
    @IBOutlet var userID: UITextField!
    @IBOutlet var userView: UIView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userFlag: UIButton!
    @IBOutlet var userCountry: UILabel!
    @IBOutlet var successMessageView: UIView!
    
    @IBOutlet var changeUserID: UIButton!
    
    @IBOutlet var closeKeyboardGestureRecognizer: UITapGestureRecognizer!
    let ss = SlideNavigationController.sharedInstance()
    
    var newFriendID = ""
    var id_user_find_friend = ""
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if myData.code == "none"{
            changeUserIDAction(changeUserID)
            return false
        }else{
            if textField.text == "User ID"{
                textField.text = ""
            }
            textField.textColor = .black
            return true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.characters.count == 0{
            textField.text = "User ID"
            textField.textColor = UIColor(red: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1.0)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonAction(searchButton)
        return true
    }
    
    @IBAction func closeKeyBoardAction(_ sender: AnyObject) {
        userID.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeUserID.setTitle(myData.code, for: UIControlState())
        self.addToFriendsButton.isEnabled = false
        self.contactsView.alpha = 0
    }
    
    var canOpenMenu = true
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if canOpenMenu{
            (ss?.bottomMenu as! RBottomMenuViewController).unHideMenu()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override var prefersStatusBarHidden : Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addToFriendsButtonAction(_ sender: UIButton) {
        SpecialLoading.SI.startLoad()
        let baseURL = URL(string: "http://vidlerr.com")!
        let manager = AFHTTPSessionManager(baseURL: baseURL)
        manager.post("applications/roomy/data.php",
            parameters: [
                "type" : "sendFriendRequest",
                "id_user" : myData.id,
                "id_facebook" : myData.facebook,
                "to_userID" : newFriendID
            ],
            progress: nil,
            success: { (operation, resp) -> Void in
                if let resp = resp as? [String: AnyObject]{
                    if let _ = resp["send"]{
                        print("request sended")
                        sender.isEnabled = false
                        if self.id_user_find_friend != ""{
                            let text =  "I am looking to add you in my friends list, " + myData.name + "!"
                            QBRequest.sendPush(withText: text, toUsers: self.id_user_find_friend, successBlock: { (resp, events) in
                                self.id_user_find_friend = ""
                            }, errorBlock: { (error) in
                                self.id_user_find_friend = ""
                            })
                        }
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            self.successMessageView.alpha = 1.0
                        })
                    }
                    if let gems = resp["gems"] as? Int{
                        updateGems(gems)
                    }
                    if let error = resp["error"] as? String{
                        if error == "already"{
                            let alert = UIAlertController(title: "Request field", message: "You have already sent a request to this user.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                SpecialLoading.SI.stopLoadin()
            }) { (operation, error) -> Void in
                SpecialLoading.SI.stopLoadin()
        }
    }
    @IBAction func searchButtonAction(_ sender: UIButton) {
        userID.resignFirstResponder()
        if let text = userID.text{
            if text.characters.count != 0 && text != "User ID"{
                SpecialLoading.SI.startLoad()
                let baseURL = URL(string: "http://vidlerr.com")!
                let manager = AFHTTPSessionManager(baseURL: baseURL)
                manager.post("applications/roomy/data.php",
                    parameters: [
                        "type" : "searchFriend",
                        "id_user" : myData.id,
                        "id_facebook" : myData.facebook,
                        "userID" : text
                    ],
                    progress: nil,
                    success: { (operation, resp) -> Void in
                        if let resp = resp as? [String : AnyObject]{
                            if let data = resp["data"] as? [String: AnyObject]{
                                self.newFriendID = text
                                let id_user = data["id_user"] as? String ?? ""
                                self.id_user_find_friend = id_user
                                let id_facebook = data["id_facebook"] as? String ?? ""
                                let userID = data["userID"] as? String ?? ""
                                let country = data["country"] as? String ?? "USA"
                                let photo = "https://graph.facebook.com/\(id_facebook)/picture?type=large"
                                self.userImage.setImageWith(URL(string: photo)!)
                                let countryImageName = country.replacingOccurrences(of:" ", with: "_").lowercased()
                                self.userFlag.setImage(UIImage(named: countryImageName), for: UIControlState())
                                self.userCountry.text = country
                                let req = FBSDKGraphRequest(graphPath: "/\(id_facebook)", parameters: ["fields": "id, name, location"], httpMethod: "GET")
                                req?.start(completionHandler: { (connection, result, error) in
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
                                            self.userName.text = newName
                                            let query = "INSERT INTO `r_friends` (`id_human`, `id_user`, `name`, `country`, `image`, `friend`, `code`) VALUES (?, ?, ?, ?, ?, 0, ?)"
                                            DB.si().request(withQuery: query, andParams: [id_user, myData.id, newName, country, photo, userID])
                                            self.userView.isHidden = false
                                        }
                                    }else{
                                        self.userView.isHidden = true
                                    }
                                    let exists = DB.si().selectRow(withQyery: "SELECT COUNT(*) as c FROM `r_friends` WHERE `code` = ?", andParams: [text])["c"] as? String ?? "0"
                                    self.addToFriendsButton.isEnabled = exists != "0"
                                    SpecialLoading.SI.stopLoadin()
                                })
                                return
                            }
                        }
                        
                        SpecialLoading.SI.stopLoadin()
                    }) { (operation, error) in
                        self.id_user_find_friend = ""
                        SpecialLoading.SI.stopLoadin()
                }
            }
        }
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        canOpenMenu = true
        ss?.popViewController(animated: true)
    }

    @IBAction func changeUserIDAction(_ sender: UIButton) {
        changeMyCode(self, sender: sender)
    }
    
    
    @IBAction func closeSuccessMessageViewAction(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.successMessageView.alpha = 0
        }) 
    }
    

//    MARK: TopMenu
    
    @IBOutlet var topMenuView: UIView!
    
    @IBOutlet var searchFriendsButton: UIButton!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    
    @IBOutlet var sendInviteButton: UIButton!
    @IBAction func searchFriendsButtonAction(_ sender: UIButton) {
        closeKeyboardGestureRecognizer.isEnabled = true
        sender.isSelected = true
        messageButton.isSelected = false
        UIView.animate(withDuration: 0.3, animations: { 
            self.contactsView.alpha = 0
            self.searchUsersView.alpha = 1
        }) 
    }
    
    @IBAction func messageButtonAction(_ sender: UIButton) {
        closeKeyboardGestureRecognizer.isEnabled = false
        closeKeyBoardAction(sender)
        UIView.animate(withDuration: 0.3, animations: {
            self.contactsView.alpha = 1
            self.searchUsersView.alpha = 0
        }) 
        searchFriendsButton.isSelected = false
        SpecialLoading.SI.startLoad()
        var inv = [String]()
        if let invited = UD.object(forKey: "invited") as? [String]{
            inv = invited
        }
        LGPhonebook.sharedInstance().readContacts { (result) in
            guard let cn = result as? [PhoneBookContact] else{
                SpecialLoading.SI.stopLoadin()
                sender.isSelected = false
                return
            }
            var index = 0
            self.contacts.removeAll(keepingCapacity: false)
            for contact in cn{
                if contact.email != "No email" && !inv.contains(contact.email){
                    self.contacts.append(contact)
                    self.selectedContacts.append(index)
                    index += 1
                }
            }
            sender.isSelected = true
            self.contactsTableView.delegate = self
            self.contactsTableView.reloadData()
            if self.contacts.count == 0{
                self.contactsTableView.alpha = 0
                self.sendInviteButton.frame.origin.y = 20
            }else{
                self.contactsTableView.alpha = 1
                self.sendInviteButton.frame.origin.y = self.contactsTableView.contentSize.height + self.contactsTableView.frame.origin.y + 20
            }
            SpecialLoading.SI.stopLoadin()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == contactsTableView{
            self.sendInviteButton.frame.origin.y = (scrollView.contentSize.height - scrollView.contentOffset.y) + scrollView.frame.origin.y + 20
        }
    }
    
    @IBAction func facebookButtonAction(_ sender: AnyObject) {
        let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let block: SLComposeViewControllerCompletionHandler = { (result: SLComposeViewControllerResult) -> Void in
            if result == .done{
                print("done")
            }
        }
        controller?.completionHandler = block
        controller?.add(URL(string: getAppURLString()))
        self.present(controller!, animated: true, completion: nil)
    }
    
    @IBAction func twitterButtonAction(_ sender: AnyObject) {
        let controller = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        let block: SLComposeViewControllerCompletionHandler = { (result: SLComposeViewControllerResult) -> Void in
            if result == .done{
                print("done")
            }
        }
        controller?.completionHandler = block
        controller?.add(URL(string: getAppURLString()))
        self.present(controller!, animated: true, completion: nil)
    }
    
//    MARK: Contacts
    @IBOutlet var contactsView: UIView!
    @IBOutlet var searchUsersView: UIView!
    @IBOutlet var contactsTableView: UITableView!
    
    var contacts = [PhoneBookContact]()
    var selectedContacts = [Int]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! ContactCell
        let contact = contacts[indexPath.row]
        cell.contactImageView.image = contact.image
        cell.contactImageView.layer.masksToBounds = true
        cell.contactImageView.layer.cornerRadius = cell.contactImageView.frame.size.width / 2
        cell.contactNameLabel.text  = contact.name
        cell.contactPhoneLabel.text = contact.mobile
        cell.selectionIndicatorButton.isSelected = selectedContacts.contains(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedContacts.index(of: indexPath.row){
            selectedContacts.remove(at: index)
        }else{
            selectedContacts.append(indexPath.row)
        }
        let cell = tableView.cellForRow(at: indexPath) as! ContactCell
        cell.selectionIndicatorButton.isSelected = selectedContacts.contains(indexPath.row)
    }
    
    @IBAction func sendinviteAction(_ sender: AnyObject) {
        var emails = [String]()
        for index in selectedContacts{
            emails.append(contacts[index].email)
        }
//        if emails.count > 0{
            canOpenMenu = false
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            let theme = "You need to test Roomy Video Chat, it’s awesome"
            let text = "<html><head><title>" + theme + "</title></head><body>Hi,<br /><br />" +
                "You need to check this chat. I was very impressed from the beggining.<br />" +
                "<a href=" + getAppURLString() + ">Roomy - Video Call, Voice and Chat</a><br /><br />" +
                "Help us expand this community.<br />" +
                "Are you in?<br /><br />" +
                "<a href=" + getAppURLString() + ">Roomy - Video Call, Voice and Chat</a>" +
            "</body></html>"
            controller.setSubject(theme)
            controller.setToRecipients(emails)
            controller.setMessageBody(text, isHTML: true)
            self.present(controller, animated: true, completion: nil)
//        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if MFMailComposeResult.sent == result{
            var emails = [String]()
            for index in selectedContacts{
                emails.append(contacts[index].email)
            }
            UD.set(emails, forKey: "invited")
            
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
