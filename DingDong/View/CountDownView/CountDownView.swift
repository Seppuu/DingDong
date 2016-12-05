//
//  CountDownView.swift
//  DingDong
//
//  Created by Seppuu on 16/6/1.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class CountDownView: UIView {
    
    
    @IBOutlet weak var countLabel: UILabel!
    
    var countDownComplete:(()->())?
    
    class func instanceFromNib() -> CountDownView {
        
        return UINib(nibName: "CountDown", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CountDownView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    var countNumber = 3 {
        didSet {
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.countLabel.text = String(self.countNumber)
            }) 
        }
    }
    
    var timer = Timer()
    
    @objc fileprivate func beginCount() {
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(CountDownView.count), userInfo: nil, repeats: true)
    }
    
    
    func show(_ time:Int) {
        countNumber = time
        //开始动画+结束动画的时间是0.5 + 0.5 所以去掉
        //countNumber -= 1
        self.beginCount()
        self.transform = CGAffineTransform(scaleX: 3.5, y: 3.5)
        UIView.animate(withDuration: 0.5, delay: 0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 3,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                    self.alpha = 1.0
        }){ (success) in
           
        }
    }
    
    
    @objc fileprivate func count() {
        
        if countNumber == 0 {
            timer.invalidate()
            self.transform = CGAffineTransform.identity
            
            UIView.animate(withDuration: 0.5, delay: 0,
                                       usingSpringWithDamping: 0.7,
                                       initialSpringVelocity: 3,
                                       options: UIViewAnimationOptions(),
                                       animations: {
                                        self.transform = CGAffineTransform(scaleX: 3.5, y: 3.5)
                                        self.alpha = 0.0
            }){ (success) in
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }

            countDownComplete?()
            
            return
        }
        countNumber -= 1
        
    }

}
