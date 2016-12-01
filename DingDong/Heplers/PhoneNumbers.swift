//
//  PhoneNumbers.swift
//  DingDong
//
//  Created by Seppuu on 16/4/20.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation


//中国联通前3位
private let ChinaMobileNum  = [130,131,132,145,145,155,156,185,186,176]

//中国移动前3位
private let ChinaUnicomNum  = [134,135,136,137,138,139,150,151,152,157,158,159,147,182,183,184,187,188,178]

//中国电信前3位
private let ChinaTelecom = [133,153,180,181,189,177]

class PhoneNumbers: NSObject {

   static let phones = [ChinaMobileNum,ChinaUnicomNum,ChinaTelecom]
    
}