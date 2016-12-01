//
//  SwitchCell.swift
//  DingDong
//
//  Created by Seppuu on 16/6/2.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var switchButton: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func switchTap(_ sender: UISwitch) {
    }
    
    
}
