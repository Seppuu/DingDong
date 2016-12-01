//
//  CertificateCell.swift
//  DingDong
//
//  Created by Seppuu on 16/6/3.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class CertificateCell: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
