//
//  SubscriptionDetailCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/30.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class SubscriptionDetailCell: UICollectionViewCell {
    
    
    @IBOutlet weak var avatarView: UIImageView!
    
    
    @IBOutlet weak var unReadDot: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.backgroundColor = UIColor ( red: 0.9312, green: 0.9344, blue: 0.9368, alpha: 1.0 )
        avatarView.layer.cornerRadius = avatarView.ddWidth/2
        avatarView.layer.masksToBounds = true
        
        
        avatarView.alpha = 1.0
        
        unReadDot.backgroundColor = UIColor ( red: 0.4091, green: 0.6509, blue: 1.0, alpha: 1.0 )
        unReadDot.layer.cornerRadius = 4/2
        unReadDot.layer.masksToBounds = true
        
        
        self.layer.masksToBounds = true
        
    }

}
