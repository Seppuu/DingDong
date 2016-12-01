//
//  CoverAddCell.swift
//  DingDong
//
//  Created by Seppuu on 16/6/2.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class CoverAddCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var addLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        coverImageView.layer.cornerRadius = coverImageView.ddWidth/2
        coverImageView.layer.masksToBounds = true
        
        coverImageView.backgroundColor = UIColor ( red: 0.9043, green: 0.9003, blue: 0.9082, alpha: 1.0 )
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
