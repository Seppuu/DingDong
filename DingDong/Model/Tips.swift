//
//  Tips.swift
//  DingDong
//
//  Created by Seppuu on 16/6/1.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation

class Tips {
    
    static var sharedTips = Tips()
    
    enum tips:Int {
        case one = 0
        case two
        case three
        
        static var count: Int { return tips.three.hashValue + 1}
        
        var content:String {
            
            switch self {
            case .one:
                return "返回时，数据会自动保存"
            case .two:
                return "录音录制最长是60秒"
            case .three:
                return "录音开始前有3秒倒计时"
            }
        }
    }
    
    var index = 0
    
    var tip:String {
        return getTip().content
    }
    
    func getTip() -> tips {
        
        if index >= tips.count {
            index = 0
        }
        index += 1
        
        return tips(rawValue: index - 1)!
    }
}
