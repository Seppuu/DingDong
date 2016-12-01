//
//  ChannelCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/31.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {
    
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    

    @IBOutlet weak var detailLabel: UILabel!
    
    
    @IBOutlet weak var moreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func moreButtonTap(_ sender: UIButton) {
        
        
    }
}
