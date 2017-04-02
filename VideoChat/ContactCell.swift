//
//  ContactCell.swift
//  VideoChat
//
//  Created by Farshx on 27/04/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet var contactImageView: UIImageView!
    @IBOutlet var contactNameLabel: UILabel!
    @IBOutlet var contactPhoneLabel: UILabel!
    
    @IBOutlet var selectionIndicatorButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}