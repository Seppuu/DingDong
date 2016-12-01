//
//  DDKeyBoardHelper.swift
//  DingDong
//
//  Created by Seppuu on 16/4/6.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import KeyboardMan

class DDKeyBoardHelper: NSObject {

    let keyboardMan = KeyboardMan()
    
    override init() {
        super.init()
        
        setKeyboardMan()
    }
    
    var keyboardAppearHandler:(()->())?
    
    var keyboardDisappearhandler:(()->())?
    
    func setKeyboardMan() {
        
        keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            
            print("appear \(appearPostIndex), \(keyboardHeight), \(keyboardHeightIncrement)\n")
            
            if let strongSelf = self {
                strongSelf.keyboardAppearHandler?()
            }
        }
        
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            
            print("disappear \(keyboardHeight)\n")
            
            if let strongSelf = self {
                strongSelf.keyboardDisappearhandler?()
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
