//
//  DDKeyboardListener.swift
//  DingDong
//
//  Created by Seppuu on 16/3/18.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import UIKit

class DDKeyboardListener: NSObject {
    
    var isActive:Bool = false
    
    override init() {
        super.init()
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(DDKeyboardListener.noticeShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        center.addObserver(self, selector: #selector(DDKeyboardListener.noticeHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func noticeShowKeyboard(_ noti:Notification) {
        
        isActive = true
    }
    
    func noticeHideKeyboard(_ noti:Notification) {
        
        isActive = false
    }
    
    
    
}
