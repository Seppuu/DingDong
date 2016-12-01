//
//  coverCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class coverCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var addLabel: UILabel!
    
    var coverImage = UIImage() {
        
        didSet {
            coverImageView.image = coverImage

        }
    }
    
    //var coverViewTapHandler:((cell:coverCell)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(coverCell.coverViewTap))
//        coverImageView.addGestureRecognizer(tap)
        
        coverImageView.layer.cornerRadius = coverImageView.ddWidth/2
        coverImageView.layer.masksToBounds = true
        coverImageView.backgroundColor = UIColor.white
        coverImageView.layer.borderColor = UIColor ( red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0 ).cgColor
        coverImageView.layer.borderWidth = 1.0
        
        
        self.selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
//    @objc private func coverViewTap() {
//    
//        coverViewTapHandler?(cell: self)
//    }
}

