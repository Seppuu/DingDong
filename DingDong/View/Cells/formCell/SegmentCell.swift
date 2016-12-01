//
//  switchCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class SegmentCell: UITableViewCell {

    @IBOutlet weak var permissionSegment: UISegmentedControl!
    
    var segmentChangeHandler:((_ selectedIndex:Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func segmentTap(_ sender: UISegmentedControl) {
        
        segmentChangeHandler?(sender.selectedSegmentIndex)
        
    }
    
    
}
