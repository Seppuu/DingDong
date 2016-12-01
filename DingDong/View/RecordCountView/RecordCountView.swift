//
//  RecordCountView.swift
//  DingDong
//
//  Created by Seppuu on 16/6/1.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class RecordCountView: UIView {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var dotView: UIView!

    var showing = false
    
    class func instanceFromNib() -> RecordCountView {
        
        return UINib(nibName: "RecordCountView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RecordCountView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timeLabel.text = "0:00"
        timeLabel.textColor = UIColor.darkText
        
        dotView.layer.cornerRadius = dotView.ddWidth/2
        dotView.layer.masksToBounds = true
        dotView.alpha = 0.0
    }
    
    var timer = Timer()
    
    func startWarning() {
        
        if showing == false {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(RecordCountView.showDot), userInfo: nil, repeats: true)
            
            showing = true
        }
    }
    
    func stopWarning() {
        
        timer.invalidate()
        dotView.alpha = 0.0
        timeLabel.textColor = UIColor.darkText
        showing = false
    }
    
    @objc fileprivate func showDot() {
        
        timeLabel.textColor = UIColor.red
        UIView.animate(withDuration: 0.5, delay:0.0, options:.curveEaseOut, animations: {
            
            self.dotView.alpha = 1.0
            
        }) { (_) in
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options:.curveEaseOut , animations: { 
                self.dotView.alpha = 0.0
                }, completion: nil)
        }
        
    }
    
    
    
    
    
    
    
    
}
