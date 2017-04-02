//
//  RHistoryViewController.swift
//  VideoChat
//
//  Created by Farshx on 23/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class RHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var myGems: UILabel!
    @IBOutlet var myName: UILabel!
    @IBOutlet var myFlag: UIButton!
    @IBOutlet var myCountry: UILabel!
    @IBOutlet var myImage: UIImageView!
    
    @IBOutlet var historyTableView: UITableView!
    var historyData = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myGems.text = "\(myData.gems)"
        myName.text = myData.name
        myCountry.text = myData.country
        myFlag.setImage(myData.flagImage, for: UIControlState())
        myImage.image = myData.image
        getOfflineMessages()
        

        let query = "SELECT * FROM `r_friends` WHERE `id_user` = ?"
        if let history = DB.si().selectRows(withQyery: query, andParams: [myData.id]) as? [[String: String]]{
            historyData = history
        }
        if historyData.count == 0{
            historyTableView.isHidden = true
            let imgI = UIImage(named: "6_History_empty")!
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
        cell.friendFlag.setImage(getCountryFlagImage(cell.friendCountry.text!), for: UIControlState())
        cell.frindImage.setImageWith(URL(string: data["image"]!)!)
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
        header.titleLabel.text = "History"
        return header
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ss = SlideNavigationController.sharedInstance()
        (ss?.bottomMenu as! RBottomMenuViewController).hideMenu { () -> Void in
            let controller = ss?.storyboard?.instantiateViewController(withIdentifier: "messagesController") as! RMessagesViewController
            let data = self.historyData[indexPath.row]
            controller.id_human = data["id_human"]!
            let cell = tableView.cellForRow(at: indexPath) as! FriendsTableViewCell
            let hum = Human(id:controller.id_human, name:data["name"]!, imagePath:data["image"]! as NSString!, country:data["country"]!, flagImage: cell.friendFlag.imageView?.image!)
            controller.human = hum
            ss?.pushViewController(controller, animated: true)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
