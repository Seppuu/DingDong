//
//  DDToolBar.swift
//  DingDong
//
//  Created by Seppuu on 16/3/22.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DDToolBar: UIView {
    
    var openThemeHandler:(() -> ())?
    
    class func instanceFromNib() -> DDToolBar {
        
        return UINib(nibName: "DDToolBar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DDToolBar
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func openTheme(_ sender: UIBarButtonItem) {
        
        openThemeHandler?()
    }
    

}
