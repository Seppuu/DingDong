//
//  UIViewController+DD.swift
//  DingDong
//
//  Created by Seppuu on 16/6/21.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation

extension UIViewController {
    
    
    func changeBarItemTitle() {
        let backItem = UIBarButtonItem()
        backItem.title = "返回"
        navigationItem.backBarButtonItem = backItem
    }
    
    
    var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
