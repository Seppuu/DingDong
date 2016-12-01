//
//  DDTimeLabelCounter.swift
//  DingDong
//
//  Created by Seppuu on 16/3/12.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DDTimeLabelCounter : NSObject{
    
    class func audioDurationBy(audioSamlesCount count:Int) -> String {
        var timeString = ""
        let frequency = 4
        let minutes = count / frequency / 60
        let seconds = count / frequency - minutes * 60
        //let subSeconds = count - seconds * frequency - minutes * 60 * frequency
        
        timeString = String(format: "%d:%02d", minutes, seconds)
        
        return timeString
    }
    
}