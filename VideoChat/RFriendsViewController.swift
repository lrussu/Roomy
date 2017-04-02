//
//  RFriendsViewController.swift
//  VideoChat
//
//  Created by Farshx on 20/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class RFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    //    MARK: Outlets
    @IBOutlet var myGems: UILabel!
    @IBOutlet var friendsTableView: UITableView!
    @IBOutlet var addNewFriendButton: UIButton!
    
    @IBOutlet var friendsScrollView: UIScrollView!
    
    
    //    MARK: Vars
    var friendsList = [Human]()
    var requests = [Human]()
    var allDataFromRequests = [[String: String]]()
    var sections = 0
    
    
    var nextPoint = CGPoint.zero
    
    
    func createFriendView(_ imagePath: String, name: String, country: String, index: Int, request: Bool = false) -> UIView{
        let userView = UIView()
        userView.backgroundColor = .clear
        let width = kScreen.width / (isIpad ? 4 : 3)
        let height = CGFloat(isIpad ? 240 : 150)
        userView.frame.size = CGSize(width: width, height: height)
        
        let ind = round(CGFloat(index > (isIpad ? 3 : 2) ? index % (isIpad ? 4 : 3) : index))
        let ind2 = Int(CGFloat(index) / (isIpad ? 4 : 3))
        var sp: CGFloat = 0
        if isIpad{
            if ind.truncatingRemainder(dividingBy: 2) != 0{
                sp = 100
            }
        }else{
            if ind.truncatingRemainder(dividingBy: 2) == 0{
                sp = 50
            }
        }
        nextPoint = CGPoint(x: width * ind, y: CGFloat(ind2) * height + sp)
        userView.frame.origin = nextPoint
        
        let userImageView = UIImageView()
        let imgSize = isIpad ? CGSize(width: 130, height: 130) : CGSize(width: 77, height: 77)
        userImageView.setImageWith(URL(string: imagePath)!)
        userImageView.frame.size = imgSize
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = imgSize.height / 2
        userImageView.layer.masksToBounds = true
        userImageView.center = CGPoint(x: width / 2, y: imgSize.height / 2 + 10)
        userView.addSubview(userImageView)
        
        let labelsColor = UIColor(red: 46/255.0, green: 46/255.0, blue: 46/255.0, alpha: 1.0)
        
        let userNameLabel = UILabel()
        userNameLabel.font = UIFont.init(name: "Aileron-SemiBold", size: isIpad ? 20 : 17)
        userNameLabel.textColor = labelsColor
        userNameLabel.text = name
        userNameLabel.textAlignment = .center
        userNameLabel.sizeToFit()
        userNameLabel.center = CGPoint(x: userImageView.center.x, y: userImageView.frame.size.height + userImageView.frame.origin.y + 15)
        userView.addSubview(userNameLabel)
        
        if request{
            let acceptFriendRequest = UIButton()
            let acceptImage = UIImage(named: "6_add_friend_default")!
            acceptFriendRequest.setImage(acceptImage, for: UIControlState())
            acceptFriendRequest.frame = CGRect(x: 10, y: 0, width: acceptImage.size.width, height: acceptImage.size.height)
            acceptFriendRequest.alpha = 3 + CGFloat(index)
            acceptFriendRequest.tag = 1
            acceptFriendRequest.frame.origin.y = userImageView.frame.height + userImageView.frame.origin.y
            acceptFriendRequest.addTarget(self, action: #selector(friendRequestButtonAction(_:)), for: .touchUpInside)
            
            let rejectFriendRequest = UIButton()
            let rejectImage = UIImage(named: "6_delete_default")!
            rejectFriendRequest.setImage(rejectImage, for: UIControlState())
            rejectFriendRequest.frame = CGRect(x: userView.frame.width - rejectImage.size.width - 10, y: 0, width: rejectImage.size.width, height: rejectImage.size.height)
            rejectFriendRequest.alpha = 3 + CGFloat(index)
            rejectFriendRequest.tag = -1
            rejectFriendRequest.center.y = acceptFriendRequest.center.y
            rejectFriendRequest.addTarget(self, action: #selector(friendRequestButtonAction(_:)), for: .touchUpInside)
            
            userNameLabel.center.y += acceptFriendRequest.frame.height - 5
            
            userView.addSubview(acceptFriendRequest)
            userView.addSubview(rejectFriendRequest)
        }
        
        let userCountryLabel = UILabel()
        userCountryLabel.font = UIFont.init(name: "Aileron-Regular", size: isIpad ? 20 : 11)
        userCountryLabel.textColor = labelsColor
        userCountryLabel.text = country
        userCountryLabel.textAlignment = .center
        userCountryLabel.sizeToFit()
        
        let userCountryImage = getCountryFlagImage(country)
        let userCountryImageView = UIImageView(image: userCountryImage)
        userCountryImageView.frame.size = userCountryImage.size
        userCountryImageView.center = CGPoint(x: max(0, (width - userCountryLabel.frame.width - 5) / 2),
                                                  y: userNameLabel.center.y + userNameLabel.frame.height / 2 + userCountryImage.size.height / 2 + 5)
        userCountryLabel.center = CGPoint(x: userCountryImageView.center.x + userCountryLabel.frame.width / 2 + 10, y: userCountryImageView.center.y)
        
        userView.clipsToBounds = true
        userView.addSubview(userCountryLabel)
        userView.addSubview(userCountryImageView)
        
        return userView
    }
    
    
    @IBAction func friendRequestButtonAction(_ sender: UIButton){
        SpecialLoading.SI.startLoad()
        let baseURL = URL(string: "http://vidlerr.com")!
        let manager = AFHTTPSessionManager(baseURL: baseURL)
        
        let params: [String : Any] = [
            "type": "acceptFriendRequest",
            "userID" : myData.code,
            "h_id_user" : allDataFromRequests[Int(sender.alpha - 3)]["h_id_user"] ?? "0",
            "h_id_facebook" : allDataFromRequests[Int(sender.alpha - 3)]["h_id_facebook"] ?? "0",
            "accept" : "\(sender.tag)"
        ]
        manager.post("applications/roomy/data.php",
                     parameters: params,
                     progress: nil,
                     success: { (operation, result) in
                        NC.post(name: Notification.Name(rawValue: "friendAdded"), object: Int(sender.alpha - 3))
                        SpecialLoading.SI.stopLoadin()
        }) { (operation, error) in
            SpecialLoading.SI.stopLoadin()
        }
//        manager.post("applications/roomy/data.php",
//                     parameters: [
//                        "type": "acceptFriendRequest",
//                        "userID" : myData.code,
//                        "h_id_user" : allDataFromRequests[Int(sender.alpha - 3)]["h_id_user"] ?? "0",
//                        "h_id_facebook" : allDataFromRequests[Int(sender.alpha - 3)]["h_id_facebook"] ?? "0",
//                        "accept" : "\(sender.tag)"
//            ],
//                     progress: nil,
//                     success: { (operation, result) in
//                        
//                        NC.post(name: Notification.Name(rawValue: "friendAdded"), object: Int(sender.alpha - 3))
//                        SpecialLoading.SI.stopLoadin()
//                        
//        }) { (operation, error) in
//            SpecialLoading.SI.stopLoadin()
//        }
    }
    
    
    func createAllFreinds(){
        if friendsList.count != 0 || requests.count != 0{
            nextPoint = CGPoint.zero
            for v in friendsScrollView.subviews{
                v.removeFromSuperview()
            }
            for index in 0..<requests.count{
                let ss = requests[index]
                let v = createFriendView(ss.imagePath as String, name: ss.name, country: ss.country, index: index, request: true)
                friendsScrollView.addSubview(v)
                friendsScrollView.contentSize = CGSize(width: kScreen.width, height: v.frame.height + v.frame.origin.y)
            }
            for index in 0..<friendsList.count{
                let ss = friendsList[index]
                let v = createFriendView(ss.imagePath as String, name: ss.name, country: ss.country, index: index + requests.count)
                friendsScrollView.addSubview(v)
                friendsScrollView.contentSize = CGSize(width: kScreen.width, height: v.frame.height + v.frame.origin.y)
            }
        }
        let addButton = UIButton()
        let addimage = UIImage(named: "6_add_big_button")!
        addButton.setImage(addimage, for: UIControlState())
        addButton.frame.size = addimage.size
        addButton.addTarget(self, action: #selector(addNewFriendButtonAction(_:)), for: .touchUpInside)
        addButton.center.x = self.view.center.x
        
        if friendsList.count == 0 && requests.count == 0{
            friendsScrollView.isScrollEnabled = false
            let noUsersImage = UIImage(named: "no_friends_img")!
            let noUsers = UIImageView(image: noUsersImage)
            noUsers.frame.size = noUsersImage.size
            noUsers.center.x = kScreen.width / 2
            noUsers.center.y = CGFloat(isIpad ? 400 : 210)
            friendsScrollView.addSubview(noUsers)
            addButton.center.y = noUsers.center.y + noUsers.frame.size.height
        }else{
            friendsScrollView.isScrollEnabled = true
            addButton.center.y = friendsScrollView.contentSize.height + CGFloat(isIpad ? 75 : 75)
        }
        
        friendsScrollView.addSubview(addButton)
        friendsScrollView.contentSize = CGSize(width: kScreen.width, height: addButton.frame.origin.y + addButton.frame.width + (isIpad ? 150 : 50))
    }
    
    
    
    
    
    @IBAction func buyGemsAction(_ sender: AnyObject) {
        let ss = SlideNavigationController.sharedInstance()
        (ss?.bottomMenu as! RBottomMenuViewController).hideMenu { () -> Void in
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "buyController")
            ss?.pushViewController(controller!, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SpecialLoading.SI.startLoad()
        myGems.text = "\(myData.gems)"
        getOfflineMessages()
        
        
        let query = "SELECT * FROM `r_friends` WHERE `id_user` = ? AND `friend` = 1"
        let friends = DB.si().selectRows(withQyery: query, andParams: [myData.id])
        for friend2 in friends!{
            if let friend = friend2 as? [String: Any]{
                let id_friend   = friend["id_human"] as! String
                let name        = friend["name"] as! String
                let country     = friend["country"] as! String
                var country2 = country.replacingOccurrences(of: " ", with: "_")
                country2 = country2.lowercased()
                let image       = friend["image"] as! String
                let flagImage   = UIImage(named: country2)
                let human = Human(id:id_friend, name: name, imagePath: image as NSString!, country: country,  flagImage: flagImage)
                friendsList.append(human)
            }
        }
        
        createAllFreinds()
        
        NC.addObserver(forName: NSNotification.Name(rawValue: "friendAdded"), object: nil, queue: nil) { (sender) -> Void in
            if let index = sender.object as? Int{
                guard let id_human = self.allDataFromRequests[index]["h_id_user"] else{
                    return
                }
                guard let imagePath = self.allDataFromRequests[index]["imagePath"] else{
                    return
                }
                let newHum = self.requests[index]
                let name = newHum.name
                let country = newHum.country
                let query = "INSERT INTO `r_friends` (`id_human`, `id_user`, `name`, `country`, `image`, `friend`) VALUES (?, ?, ?, ?, ?, ?)"
                DB.si().request(withQuery: query, andParams: [id_human, myData.id, name, country, imagePath, 1])
                self.allDataFromRequests.remove(at: index)
                let hum = Human(id: id_human, name: name, imagePath: imagePath as NSString!, country: country, flagImage: getCountryFlagImage(country!))
                self.friendsList.append(hum)
                self.requests.remove(at: index)
                self.createAllFreinds()
            }
        }
        
        let baseURL = URL(string: "http://vidlerr.com")!
        let manager = AFHTTPSessionManager(baseURL: baseURL)
        manager.post("applications/roomy/data.php",
            parameters: [
                "type" : "getAcceptedFriendRequest",
                "id_user" : myData.id,
                "id_facebook" : myData.facebook,
                "userID" : myData.code
            ],
            progress:nil,
            success: { (operation, result) -> Void in
                guard let resp = result as? [String: AnyObject] else{
                    return
                }
                if let error = resp["error"]{
                    print(error)
                }
                if let data = resp["data"] as? [[String: AnyObject]]{
                    
                    for d in data{
                        let accepted = d["accepted"] as? String ?? "0"
                        guard let to_userID = d["to_userID"] as? String else{
                            break
                        }
                        print(DB.si().request(withQuery: "UPDATE `r_friends` SET `friend` = ? WHERE `code` = ? AND `id_user` = ?", andParams: [accepted, to_userID, myData.id]))
                    }
                    
                    self.friendsList.removeAll(keepingCapacity: false)
                    let query = "SELECT * FROM `r_friends` WHERE `id_user` = ? AND `friend` = 1"
                    let friends = DB.si().selectRows(withQyery: query, andParams: [myData.id])
                    for friend2 in friends!{
                        if let friend = friend2 as? [String: Any]{
                            let id_friend   = friend["id_human"] as! String
                            let name        = friend["name"] as! String
                            let country     = friend["country"] as! String
                            let image       = friend["image"] as! String
                            let flagImage   = getCountryFlagImage(country)
                            let human = Human(id:id_friend, name: name, imagePath: image as NSString!, country: country,  flagImage: flagImage)
                            self.friendsList.append(human)
                        }
                    }
                    self.createAllFreinds()
                }
            }) { (operation, error) -> Void in
                
        }
        manager.post("applications/roomy/data.php",
            parameters: [
                "type" : "getFriendRequests",
                "userID" : myData.code,
                "id_user" : myData.id,
                "id_facebook" : myData.facebook
            ],
            progress:nil,
            success: { (operation, resp) -> Void in
                if let resp = resp as? [String: AnyObject]{
                    if let users = resp["users"] as? [[String: AnyObject]]{
                        for user in users{
                            let h_id_user = user["id_user"] as? String ?? ""
                            let h_id_facebook = user["id_facebook"] as? String ?? ""
                            let req = FBSDKGraphRequest(
                                graphPath: "/\(h_id_facebook)",
                                parameters: ["fields" : "location, name"],
                                tokenString: FBSDKAccessToken.current().tokenString,
                                version: "v2.5",
                                httpMethod: "GET")
                            SpecialLoading.SI.startLoad()
                            req?.start(completionHandler: { (connection, result, error) in
                                let photo = "https://graph.facebook.com/\(h_id_facebook)/picture?type=large"
                                if let _ = error{
                                    print(error)
                                }else{
                                    if let result = result as? [String: Any]{
                                        print(result)
                                        let country: String!
                                        if let location = result["location"] as? [String: AnyObject]{
                                            country = (location["name"] as! String).components(separatedBy: ", ")[1] ?? "USA"
                                        }else{
                                            country = "USA"
                                        }
                                        var nm = "Name**"
                                        if let name = result["name"] as? String{
                                            nm = name.components(separatedBy: " ")[0] ?? "name"
                                            nm = nm.substring(to: nm.characters.index(nm.startIndex, offsetBy: nm.characters.count-2)) + "**"
                                        }
                                        let fl = getCountryFlagImage(country)
                                        let hum = Human(id: h_id_user, name: nm, imagePath: photo as! NSString, country: country, flagImage: fl)
                                        self.requests.append(hum)
                                    }
                                }
                                self.allDataFromRequests.append([
                                    "h_id_user" : h_id_user,
                                    "h_id_facebook" : h_id_facebook,
                                    "imagePath" : photo,
                                    "userID" : myData.id
                                    ])
                                self.createAllFreinds()
                                SpecialLoading.SI.stopLoadin()
                            })
                        }
                        return
                    }
                }
                SpecialLoading.SI.stopLoadin()
            }) { (operation, error) in
                SpecialLoading.SI.stopLoadin()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myGems.text = "\(myData.gems)"
    }
    
    @IBAction func addNewFriendButtonAction(_ sender: UIButton) {
        let ss = SlideNavigationController.sharedInstance()
        (ss?.bottomMenu as! RBottomMenuViewController).hideMenu { () -> Void in
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "findController") as! RFindFriendViewController
            ss?.pushViewController(controller, animated: true)
        }
    }
    @IBAction func facebookInviteAction(_ sender: AnyObject) {
        SpecialLoading.SI.startLoad()
        let req = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil, httpMethod: "GET")
        req?.start(completionHandler: { (connection, result, error) in
            print(result)
            if let result = result as? [String: Any]{
                if let data2 = result["data"] as? [[String: String]]{
                    for newFriend in data2{
                        getUserInfoByID(newFriend["id"]!, comp: { (data) -> Void in
                            print(data)
                            let id_facebook = data["id_facebook"]!
                            let country = data["country"] ?? "USA"
                            let photo = "https://graph.facebook.com/\(id_facebook)/picture?type=large"
                            let userCode = data["userID"]!
                            
                            let id_user = data["id_user"] ?? "0"
                            
                            let name = newFriend["name"] ?? "Unknown**"
                            let newName: String!
                            let nameComp = name.components(separatedBy: " ")
                            if nameComp.count > 1{
                                newName = nameComp[0].substring(to: nameComp[0].characters.index(nameComp[0].startIndex, offsetBy: nameComp[0].characters.count-2)) + "**"
                            }else{
                                newName = name.substring(to: name.characters.index(name.startIndex, offsetBy: name.characters.count-2)) + "**"
                            }
                            if let user = DB.si().selectRow(withQyery: "SELECT COUNT(*) as `c` FROM `r_friends` WHERE `id_human` = ?", andParams: [id_user]) as? [String: String]{
                                if user["c"] != nil && user["c"] != "0"{
                                    return
                                }
                            }
                            let query = "INSERT INTO `r_friends` (`id_human`, `id_user`, `name`, `country`, `image`, `friend`, `code`) VALUES (?, ?, ?, ?, ?, 1, ?)"
                            DB.si().request(withQuery: query, andParams: [id_user, myData.id, newName, country, photo, userCode])
                            let human = Human(id:id_user, name: newName, imagePath: photo as! NSString, country: country, flagImage: getCountryFlagImage(country))
                            self.friendsList.append(human)
                            let baseURL = URL(string: "http://vidlerr.com")!
                            let manager = AFHTTPSessionManager(baseURL: baseURL)
                            manager.post("/applications/roomy/data.php",
                                parameters: [
                                    "type" : "sendFriendRequest3",
                                    "id_user" : myData.id,
                                    "id_facebook" : myData.facebook,
                                    "to_userID" : id_user
                                ],
                                progress: nil,
                                success: { (operation, result) in
                                    //                                        print(result)
                                }, failure: { (operation, error) in
                                    //                                        print(error)
                            })
                            self.createAllFreinds()
                        }) { () -> Void in
                            
                        }
                    }
                    let messageText = "Your friends from Facebook don't use Roomy or all of them are in friend list.\nInvite other from Messanger?"
                    let alert = UIAlertController(title: "Friends", message: messageText, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Invite", style: .default, handler: { (action) in
                        if let path = MB.path(forResource: "Messagener_gif", ofType: "gif"){
                            if let pathData = try? Data(contentsOf: URL(fileURLWithPath: path)){
                                FBSDKMessengerSharer.shareAnimatedGIF(pathData, with: nil)
                            }
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            SpecialLoading.SI.stopLoadin()
        })
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! FriendsTableViewCell
        cell.backgroundColor = .white
        cell.acceptFriendRequest.isHidden = true
        cell.rejectFriendRequest.isHidden = true
        cell.chatButton.isHidden = false
        if sections == 2 {
            if indexPath.section == 0{
                cell.backgroundColor = cell.specialColor
                cell.acceptFriendRequest.isHidden = false
                cell.rejectFriendRequest.isHidden = false
                cell.chatButton.isHidden = true
                cell.friendRequestData = allDataFromRequests[indexPath.row]
                cell.tag = indexPath.row
            }
        }
        if cell.chatButton.isHidden{
            let hm = requests[indexPath.row]
            cell.friendCountry.text = hm.country
            cell.friendFlag.setImage(hm.flagImage, for: UIControlState())
            cell.friendName.text = hm.name
            let photoURL = URL(string: hm.imagePath as String)!
            cell.frindImage.setImageWith(photoURL)
        }else{
            let hm = friendsList[indexPath.row]
            cell.friendCountry.text = hm.country
            cell.friendFlag.setImage(hm.flagImage, for: UIControlState())
            cell.friendName.text = hm.name
            cell.frindImage.setImageWith(URL(string: hm.imagePath as String)!)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections == 2 {
            if section == 0{
                return requests.count
            }else{
                return friendsList.count
            }
        }else{
            return friendsList.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return isIpad ? 60 : 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "headerID") as! FriendsHeader
        if sections == 2{
            header.titleLabel.text = section == 0 ? "Friend Request" : "Friends"
        }else{
            header.titleLabel.text = "Friends"
        }
        return header
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sections == 2 && indexPath.section == 0{
            return
        }
        let ss = SlideNavigationController.sharedInstance()
        (ss?.bottomMenu as! RBottomMenuViewController).hideMenu { () -> Void in
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "messagesController") as! RMessagesViewController
            controller.id_human = self.friendsList[indexPath.row].id
            controller.human = self.friendsList[indexPath.row]
            ss?.pushViewController(controller, animated: true)
        }
    }
    
}
