//
//  formCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class formCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var rightTextField: UITextField!
    
    
    var endEditHandler:((_ textField: UITextField)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    
    
    @IBAction func textFieldEndEdit(_ sender: UITextField) {
        
        endEditHandler?(sender)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
