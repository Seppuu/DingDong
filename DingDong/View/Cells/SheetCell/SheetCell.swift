//
//  SheetCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/24.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class SheetCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
