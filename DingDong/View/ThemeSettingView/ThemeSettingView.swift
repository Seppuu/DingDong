//
//  ThemeSettingView.swift
//  DingDong
//
//  Created by Seppuu on 16/6/21.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class ThemeSettingView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    
    class func instanceFromNib() -> ThemeSettingView {
        
        return UINib(nibName: "ThemeSettingView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ThemeSettingView
    }
    
    override func awakeFromNib() {
        
    }
    
    
    var cancelTapHandler:(()->())?
    
    @IBAction func cancelTap(_ sender: UIButton) {
        
        cancelTapHandler?()
    }
    
    var confirmTapHandler:(()->())?
    
    @IBAction func confirmTap(_ sender: UIButton) {
        confirmTapHandler?()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
