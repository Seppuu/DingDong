//
//  AddFriendMoreCell.swift
//  DingDong
//
//  Created by Seppuu on 16/4/21.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class AddFriendMoreCell: UITableViewCell {

    
    @IBOutlet weak var annotationLabel: UILabel!
    
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        accessoryImageView.tintColor = UIColor.ddCellAccessoryImageViewTintColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
