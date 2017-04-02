//
//  RMyMessagesViewController.swift
//  VideoChat
//
//  Created by Farshx on 23/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class RMyMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var myGems: UILabel!
    @IBOutlet var myName: UILabel!
    @IBOutlet var myFlag: UIButton!
    @IBOutlet var myCountry: UILabel!
    @IBOutlet var myImage: UIImageView!
    @IBOutlet var myMessagesTableView: UITableView!
    
    var historyData = [[String: String]]()
    var selectedIndexPath: IndexPath! = nil
    var humanOnline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myGems.text = "\(myData.gems)"
        myName.text = myData.name
        myCountry.text = myData.country
        myFlag.setImage(myData.flagImage, for: UIControlState())
        myImage.image = myData.image
        getOfflineMessages()
        
        let query = "SELECT `a`.`id_human`, `a`.`date`, `b`.`name`, `b`.`country`, `b`.`image` " +
            "FROM `r_message` as `a`, `r_friends` as `b` " +
            "WHERE `a`.`id_user` = `b`.`id_user` " +
            "AND `a`.`id_user` = ? " +
            "AND `a`.`id_human` = `b`.`id_human` " +
            "GROUP BY `a`.`id_human` " +
        "ORDER BY `a`.`date` DESC"
        if let groups = DB.si().selectRows(withQyery: query, andParams: [myData.id]) as? [[String: String]]{
            historyData = groups
        }
        if historyData.count == 0{
            myMessagesTableView.isHidden = true
            let imgI = UIImage(named: "6_Messages_empty")!
            let img = UIImageView(image: imgI)
            img.frame.size = imgI.size
            img.center = self.view.center
            self.view.addSubview(img)
        }
    }
    
    @IBAction func buyGemsAction(_ sender: AnyObject) {
        let ss = SlideNavigationController.sharedInstance()
        (ss?.bottomMenu as! RBottomMenuViewController).hideMenu { () -> Void in
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "buyController")
            ss?.pushViewController(controller!, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myGems.text = "\(myData.gems)"
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
        let data = historyData[indexPath.row]
        cell.friendCountry.text = data["country"]
        cell.friendName.text = data["name"]
        let countryFlag = data["country"]!.replacingOccurrences(of: " ", with: "_").lowercased()
        cell.friendFlag.setImage(UIImage(named: countryFlag), for: UIControlState())
        MCImageCache.shared().loadImage(withURLPath: data["image"]! as String, index: UInt(indexPath.row)) { (image, index) -> Void in
            if index == UInt(indexPath.row) && image != nil{
                cell.frindImage.image = image
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return isIpad ? 60 : 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "headerID") as! FriendsHeader
        header.titleLabel.text = "Messages"
        return header
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ss = SlideNavigationController.sharedInstance()
        (ss?.bottomMenu as! RBottomMenuViewController).hideMenu { () -> Void in
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "messagesController") as! RMessagesViewController
            let data = self.historyData[indexPath.row]
            controller.id_human = data["id_human"]!
            let cell = self.myMessagesTableView.cellForRow(at: indexPath) as! FriendsTableViewCell
            let hum = Human(id:controller.id_human, name:data["name"]!, imagePath:data["image"]! as NSString!, country:data["country"]!, flagImage: cell.friendFlag.imageView?.image!)
            controller.human = hum
            self.selectedIndexPath = nil
            ss?.pushViewController(controller, animated: true)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}
