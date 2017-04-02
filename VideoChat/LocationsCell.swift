//
//  LocationsCell.swift
//  VideoChat
//
//  Created by Farshx on 08/03/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class LocationsCell: UITableViewCell {

    @IBOutlet var selectionImageView: UIImageView!
    @IBOutlet var selectionsIndicator: UIButton!
    @IBOutlet var locationsNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
