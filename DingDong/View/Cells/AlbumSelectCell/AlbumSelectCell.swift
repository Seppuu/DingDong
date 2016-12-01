//
//  AlbumSelectCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/20.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class AlbumSelectCell: UITableViewCell {
    
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var dimView: UIView!

    @IBOutlet weak var albumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
