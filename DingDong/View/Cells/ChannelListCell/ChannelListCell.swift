//
//  ChannelListCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/30.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class ChannelListCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var channelNameLabel: UILabel!
    
    
    @IBOutlet weak var newUploadCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = avatarImageView.ddWidth/2
        avatarImageView.layer.masksToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
