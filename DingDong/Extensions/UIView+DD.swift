//
//  UIView+DD.swift
//  DingDong
//
//  Created by Seppuu on 16/3/15.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation

extension UIView {

    /// Shortcut for frame.origin.x
    var ddWidth :CGFloat {
        
        return self.frame.size.width
    }
    
    /// Shortcut for frame.origin.y
    var ddHeight :CGFloat {
        
        return self.frame.size.height
    }
    
    
    /// Shortcut for frame.origin.x
    var ddBoundsWidth :CGFloat {
        
        return self.bounds.size.width
    }
    
    /// Shortcut for frame.origin.y
    var ddBoundsHeight :CGFloat {
        
        return self.bounds.size.height
    }
    
}