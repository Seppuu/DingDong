//
//  ConversationCell.swift
//  Yep
//
//  Created by NIX on 15/3/16.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import Kingfisher

class ConversationCell: UITableViewCell {

    //var conversation: Conversation!
    
    var color: UIColor?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarImageViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var redDotImageView: UIImageView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!

    deinit {

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageViewWidthConstraint.constant = DDConfig.ConversationCell.avatarSize
        
        //self.selectionStyle = .None

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarImageView.image = nil
        nameLabel.text = nil
        chatLabel.text = nil
        timeAgoLabel.text = nil

    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.avatarImageView.layer.cornerRadius =  avatarImageView.ddWidth/2
        self.avatarImageView.layer.masksToBounds = true
    }


}

