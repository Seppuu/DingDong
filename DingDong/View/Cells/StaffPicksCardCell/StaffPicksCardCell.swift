//
//  StaffPicksCardCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/24.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class StaffPicksCardCell: UICollectionViewCell {

    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var menuLabel: UILabel!
    
    var menuTapHandler:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(StaffPicksCardCell.menuTap))
        menuLabel.isUserInteractionEnabled = true
        menuLabel.addGestureRecognizer(tap)
        
        self.layer.cornerRadius = 5
        //self.layer.masksToBounds = false
        
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor ( red: 0.5622, green: 0.5622, blue: 0.5622, alpha: 1.0 ).cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowOpacity = 1.0
        
        
    }
    
    @objc fileprivate func menuTap() {
        menuTapHandler?()
    }

}
