//
//  DecibelObserver.swift
//  DingDong
//
//  Created by Seppuu on 16/4/5.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DecibelObserver: NSObject {
    
    var time = 0
    
    var decibels:Float = 0
    
    var level:Float!                   // The linear 0.0 .. 1.0 value we need.
    let minDecibels: Float = -80.0     // Or use -60dB, which I measured in a silent room.
   
    func covertDB() {
        
        if (decibels < minDecibels) {
            level = 0.0
        }
        else if (decibels >= 0.0) {
            level = 1.0
        }
        else {
            let root: Float            = 2.0
            let minAmp: Float          = powf(10.0, 0.05 * minDecibels)
            let inverseAmpRange: Float = 1.0 / (1.0 - minAmp)
            let amp:Float              = powf(10.0, 0.05 * decibels)
            let adjAmp:Float           = (amp - minAmp) * inverseAmpRange
            
            
            level = powf(adjAmp, 1.0 / root)
        }
        
        let readAbleValue = level * 120.0
        
        print(readAbleValue)
    }

    
}
