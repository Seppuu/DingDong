//
//  DDRangeSlider.swift
//  DingDong
//
//  Created by Seppuu on 16/3/3.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

let DDRANGESLIDER_THUMB_SIZE: CGFloat = 10.0
class DDRangeSlider: UIControl {

    
    enum DDRangeSliderMode {
        
       case ddrsAudioRecordMode
       case ddrsAudioSetTrimMode
       case ddrsAudioPlayMode
    }
    
    var slider: UIImageView!
    var progressImage: UIImageView!
    var rangeImage: UIImageView!
    
    var leftThumb: UIImageView!
    var rightThumb: UIImageView!
    
    
    var leftValue: CGFloat = 0.0 {
        didSet {
            var value = leftValue
            if (oldValue < minValue) {
                value = minValue
            }
            
            
            if (oldValue > rightValue) {
                value = rightValue
            }
            
            leftValue = value
            
            self.setNeedsLayout()
        }
    }
    
    
    var rightValue: CGFloat = 0.0 {
        didSet {
            var value = rightValue
            if (oldValue > maxValue) {
                value = maxValue
            }
            
            if (oldValue < leftValue) {
                value = leftValue
            }
            
            rightValue = value
            
            self.setNeedsLayout()
        }
    }

    var currentProgressValue: CGFloat = 0.0 {
        didSet {
            var value = currentProgressValue
            if (value > maxValue) {
                value = maxValue
            }
            
            if (value < minValue) {
                value = minValue
            }
            currentProgressValue = value
            
            self.setNeedsLayout()
        }
    }
    
    var minValue: CGFloat = 0.0 {
        willSet {
            
            if (leftValue < newValue) {
                leftValue = newValue
            }
            
            if (rightValue < newValue) {
                rightValue = newValue
            }
            
            self.setNeedsLayout()
        }
    }
    
    var maxValue: CGFloat = 0.0 {
        willSet {
            
            if (leftValue > newValue) {
                leftValue = newValue

            }
            
            if (rightValue > newValue) {
                rightValue = newValue
            }
            
            
            self.setNeedsLayout()
        }
    }
    
    var showThumbs: Bool = false {
        didSet {
            leftThumb.isHidden = !showThumbs
            rightThumb.isHidden = !showThumbs

        }
    }
    
    func showthumbs() -> Bool {
        return !leftThumb.isHidden
    }
    
    var showProgress: Bool = false {
        didSet{
            progressImage.isHidden = !showProgress
        }
    }
    
    func showprogress() -> Bool {
        return !progressImage.isHidden
    }
    
    
    var showRange: Bool = false {
        didSet {
            rangeImage.isHidden = !showRange
        }
        
    }
    
    func showrange() -> Bool {
        return !rangeImage.isHidden
    }
    
    func handleLeftPan(_ gesture:UIPanGestureRecognizer){
        if (gesture.state == .began ||
            gesture.state == .changed){
                let translation:CGPoint = gesture.translation(in: self)
                let range = maxValue - minValue
                let availableWidth = self.frame.size.width - DDRANGESLIDER_THUMB_SIZE
                
                self.leftValue += translation.x / availableWidth * range
                
                gesture.setTranslation(CGPoint.zero, in: self)
                
                self.sendActions(for: .valueChanged)
        }
    }

    
    func handleRightPan(_ gesture:UIPanGestureRecognizer){
        if (gesture.state == .began ||
            gesture.state == .changed){
                let translation:CGPoint = gesture.translation(in: self)
                let range = maxValue - minValue
                let availableWidth = self.frame.size.width - DDRANGESLIDER_THUMB_SIZE
                
                self.rightValue += translation.x / availableWidth * range
                
                gesture.setTranslation(CGPoint.zero, in: self)
                
                self.sendActions(for: .valueChanged)
        }
    }
    
    func setup(){
        if (maxValue == 0.0) {
            maxValue = 100.0
        }
        
        leftValue = minValue
        rightValue = maxValue
        
        slider = UIImageView.init(image: UIImage(named: "BJRangeSlider.bundle/BJRangeSliderEmpty.png")?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 4))
        self.addSubview(slider)
        
//        rangeImage = UIImageView.init(image: UIImage(named: "BJRangeSlider.bundle/BJRangeSliderBlue.png")?.stretchableImageWithLeftCapWidth(5, topCapHeight: 4))
        
        rangeImage = UIImageView()
        self.addSubview(rangeImage)
        rangeImage.backgroundColor = UIColor ( red: 1.0, green: 0.87, blue: 0.5866, alpha: 0.601023706896552 )
        
        
        progressImage = UIImageView.init(image: UIImage(named: "BJRangeSlider.bundle/BJRangeSliderRed.png")?.stretchableImage(withLeftCapWidth: 5, topCapHeight:60))
        self.addSubview(progressImage)

        // left thumb is above
//        leftThumb = UIImageView(frame: CGRect(x: 0, y: -DDRANGESLIDER_THUMB_SIZE, width:  DDRANGESLIDER_THUMB_SIZE + 12, height: DDRANGESLIDER_THUMB_SIZE * 2))
        
        leftThumb = UIImageView(frame: CGRect(x: 0, y: 0, width:  DDRANGESLIDER_THUMB_SIZE + 12, height: DDRANGESLIDER_THUMB_SIZE * 2))
       
        leftThumb.image = UIImage(named: "BJRangeSlider.bundle/BJRangeSliderStartThumb.png")

        leftThumb.isUserInteractionEnabled = true
        leftThumb.contentMode = .scaleAspectFit
        self.addSubview(leftThumb)
        
        let leftPan = UIPanGestureRecognizer(target: self, action: #selector(DDRangeSlider.handleLeftPan(_:)))
        leftThumb.addGestureRecognizer(leftPan)

        //right thumb is still above
//        rightThumb = UIImageView(frame: CGRect(x: 0, y: -DDRANGESLIDER_THUMB_SIZE, width:  DDRANGESLIDER_THUMB_SIZE + 12, height: DDRANGESLIDER_THUMB_SIZE * 2))
        
        rightThumb = UIImageView(frame: CGRect(x: 0, y:0, width:  DDRANGESLIDER_THUMB_SIZE + 12, height: DDRANGESLIDER_THUMB_SIZE * 2))
        
//        rightThumb.image = UIImage(named: "BJRangeSlider.bundle/BJRangeSliderEndThumb.png")
        
        rightThumb.image = UIImage(named: "BJRangeSlider.bundle/BJRangeSliderStartThumb.png")
        
        rightThumb.isUserInteractionEnabled = true
        rightThumb.contentMode = .scaleAspectFit
        self.addSubview(rightThumb)
        
        let rightPan = UIPanGestureRecognizer(target: self, action: #selector(DDRangeSlider.handleRightPan(_:)))
        rightThumb.addGestureRecognizer(rightPan)
        
        leftThumb.backgroundColor = UIColor ( red: 1.0, green: 0.0, blue: 0.0, alpha: 0.763092672413793 )
        rightThumb.backgroundColor = UIColor ( red: 1.0, green: 0.0, blue: 0.0, alpha: 0.635479525862069 )
//        leftThumb.clipsToBounds = true
//        rightThumb.clipsToBounds = true
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        let availableWidth = self.frame.size.width - DDRANGESLIDER_THUMB_SIZE
        let inset = DDRANGESLIDER_THUMB_SIZE/2
        
        let range = maxValue - minValue
        
        var left = floor((leftValue - minValue) / range * availableWidth)
        var right = floor((rightValue - minValue) / range * availableWidth)
        
        if (left.isNaN){
            left = 0
        }
        
        if (right.isNaN){
            right = 0
        }
        
        
        
        slider.frame = CGRect(x: inset, y: self.frame.size.height / 2 - 5, width: availableWidth, height: 10)
        
        let  rangeWidth:CGFloat = right - left;
        if (self.showrange()) {
//            rangeImage.frame = CGRectMake(inset + left, self.frame.size.height / 2 - 5, rangeWidth, 10)
            //个性化修改
            rangeImage.frame = CGRect(x: inset + left, y: leftThumb.frame.size.height, width: rangeWidth, height: self.frame.size.height - leftThumb.frame.size.height)
        }
        
        if (self.showprogress()) {
            var progressWidth = floor((currentProgressValue - leftValue) / (rightValue - leftValue) * rangeWidth)
            
            if (progressWidth.isNaN) {
                progressWidth = 0
            }
            
            progressImage.frame = CGRect(x: inset + left, y: self.frame.size.height / 2 - 5, width: progressWidth, height: 10)
        }
        
//        leftThumb.center = CGPointMake(inset + left, self.frame.size.height / 2 - DDRANGESLIDER_THUMB_SIZE / 2)
//        rightThumb.center = CGPointMake(inset + right, self.frame.size.height / 2 - DDRANGESLIDER_THUMB_SIZE / 2)
        
        leftThumb.center = CGPoint(x: inset + left,y: leftThumb.frame.height/2)
        rightThumb.center = CGPoint(x: inset + right,y: rightThumb.frame.height/2)
    }
    
    func setDisplayMode(_ mode:DDRangeSliderMode) {
        switch mode {
        case .ddrsAudioRecordMode:
            self.showThumbs = false
            self.showRange = false
            self.showProgress = true
            progressImage.image = UIImage(named: "BJRangeSlider.bundle/BJRangeSliderRed.png")?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 4)
            
        case .ddrsAudioSetTrimMode:
            self.showThumbs = true
            self.showRange = true
            self.showProgress = false
            
        case .ddrsAudioPlayMode:
            self.showThumbs = false
            self.showRange = true
            self.showProgress = true
            progressImage.image = UIImage(named: "BJRangeSlider.bundle/BJRangeSliderGreen.png")?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 4)
        }
        
        self.setNeedsLayout()
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
