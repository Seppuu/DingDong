//
//  UIImage+DD.swift
//  DingDong
//
//  Created by Seppuu on 16/4/6.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func alpha(_ value:CGFloat)->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        ctx?.scaleBy(x: 1, y: -1)
        ctx?.translateBy(x: 0, y: -area.size.height)
        ctx?.setBlendMode(.multiply)
        ctx?.setAlpha(value);
        ctx?.draw(self.cgImage!, in: area);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    

    
}

