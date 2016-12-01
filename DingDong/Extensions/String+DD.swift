//
//  String+DD.swift
//  DingDong
//
//  Created by Seppuu on 16/3/16.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

extension String {
    
    mutating func removeCharsFromEnd(_ count:Int) -> String {
        
        for _ in 0..<count {
            
            self.remove(at: self.characters.index(before: self.endIndex))
            
        }
        
        return self
    }
    
    func textSizeWithFont(_ font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        
        var textSize:CGSize!
        
        if size.equalTo(CGSize.zero) {
            
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
            
            textSize = self.size(attributes: attributes as! [String : AnyObject] as [String : AnyObject])
            
        } else {
            
            let option = NSStringDrawingOptions.usesLineFragmentOrigin
            
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
            
            let stringRect = self.boundingRect(with: size, options: option, attributes: attributes as! [String : AnyObject] as [String : AnyObject], context: nil)
            
            textSize = stringRect.size
            
        }
        
        return textSize
        
    }
    
    var md5: String! {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String)
    }
    
    
    func tokenByPassword() -> String {
        //demo直接使用username作为account，md5(password)作为token
        //接入应用开发需要根据自己的实际情况来获取 account和token
        return md5
    }
    
    //下标取子字符串
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound)
            
            return self[Range(startIndex..<endIndex)]
        }
    }
    
    func isPhoneNumber() -> Bool {
        
        var isPhone = false
        let threeNum = self.substring(0, length: 3)
        PhoneNumbers.phones.forEach { (numbers) in
            
            for i in 0..<numbers.count {
                
                if threeNum == String(numbers[i]) {
                    isPhone =  true
                    
                }
                
            }
            
        }
        
        
        return isPhone
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    
    
    func removeSpecialCharsFromString() -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=().:!_".characters)
        return String(self.characters.filter {okayChars.contains($0) })
    }
    
}
