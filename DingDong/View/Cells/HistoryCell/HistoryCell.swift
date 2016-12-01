//
//  HistoryCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/24.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {


    @IBOutlet weak var coverView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var menuLabel: UILabel!
    
    var menuTapHandler:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        menuLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(HistoryCell.meunTap))
        menuLabel.addGestureRecognizer(tap)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @objc fileprivate func meunTap() {
        menuTapHandler?()
        
    }
    
}
