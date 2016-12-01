//
//  NavigationTitleLabel.swift
//  DingDong
//
//  Created by Seppuu on 16/4/15.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class NavigationTitleLabel: UILabel {
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title:String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        
        text = title
        
        textAlignment = .center
        font = UIFont.navigationBarTitleFont() // make sure it's the same as system use
        textColor = UIColor.yepNavgationBarTitleColor()
        
        sizeToFit()
        
    }

}
