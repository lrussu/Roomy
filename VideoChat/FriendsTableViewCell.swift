//
//  FriendsTableViewCell.swift
//  VideoChat
//
//  Created by Farshx on 22/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    @IBOutlet var frindImage: UIImageView!
    @IBOutlet var friendName: UILabel!
    @IBOutlet var friendFlag: UIButton!
    @IBOutlet var friendCountry: UILabel!
    @IBOutlet var chatButton: UIButton!
    @IBOutlet var dateLabel: UILabel!

    @IBOutlet var acceptFriendRequest: UIButton!
    @IBOutlet var rejectFriendRequest: UIButton!
    
    var friendRequestData = [String: String]()
    
    let specialColor = UIColor(red: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        acceptFriendRequest.isHidden = true
        rejectFriendRequest.isHidden = true
        dateLabel.isHidden = true
    }
    
    @IBAction func friendRequestButtonAction(_ sender: UIButton){
        SpecialLoading.SI.startLoad()
        let baseURL = URL(string: "http://vidlerr.com")!
        let manager = AFHTTPSessionManager(baseURL: baseURL)
        manager.post("applications/roomy/data.php",
            parameters: [
                "type": "acceptFriendRequest",
                "userID" : myData.code,
                "h_id_user" : friendRequestData["h_id_user"],
                "h_id_facebook" : friendRequestData["h_id_facebook"],
                "accept" : "\(sender.tag)"
            ],
            progress:nil,
            success: { (operation, result) -> Void in
                NC.post(name: Notification.Name(rawValue: "friendAdded"), object: self.tag)
                SpecialLoading.SI.stopLoadin()
            }) { (operation, error) -> Void in
                SpecialLoading.SI.stopLoadin()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
