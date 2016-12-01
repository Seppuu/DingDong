//
//  Dictionary+DD.swift
//  DingDong
//
//  Created by Seppuu on 16/5/3.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation


func += <K,V> (left: inout Dictionary<K,V>, right: Dictionary<K,V>?) {
    guard let right = right else { return }
    right.forEach { key, value in
        left.updateValue(value, forKey: key)
    }
}

 
