//
//  TipsAnimeHandler.swift
//  DingDong
//
//  Created by Seppuu on 4/11/16.
//  Copyright © 2016 seppuu. All rights reserved.
//

import UIKit

class TipsAnimeHandler: NSObject {

    var timer:Timer!
    var autoDoAnimeHandler:(()->())?
    
    static var sharedHandler = TipsAnimeHandler()
    
    override init() {
        super.init()
        
        
    }
    
    func addTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(TipsAnimeHandler.shouldDoAnime), userInfo: nil, repeats: true)
        
    }

    func stopTimer() {
        
        timer.invalidate()
        //timer = nil
    }
    
    func shouldDoAnime() {
        autoDoAnimeHandler?()
    }
    
    func doAnime(_ label:UILabel,completion:@escaping (()->())) {
        var toLeftFrame  = label.frame
        var toRightFrame = label.frame
        //let lastFrame    = label.frame
        
        toLeftFrame.origin.x = -(label.frame.size.width)
        toRightFrame.origin.x = (label.frame.size.width)
    
        
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: UIViewAnimationOptions(), animations: {
            
            //label.frame = toLeftFrame
            label.alpha = 0.0
            
            }) { (Bool) in
                //label.frame = toRightFrame
                completion()
                UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: UIViewAnimationOptions(), animations: {
                    label.alpha = 1.0
                    //label.frame = lastFrame
                    
                    }, completion: nil)
        }
    }
    
}
