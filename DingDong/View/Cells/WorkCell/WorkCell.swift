//
//  WorkCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/31.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class WorkCell: UITableViewCell {
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var menuLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var menuTapHandler:(()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(WorkCell.menuTap))
        menuLabel.isUserInteractionEnabled = true
        menuLabel.addGestureRecognizer(tap)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc fileprivate func menuTap() {
        menuTapHandler?()
    }
    
}
