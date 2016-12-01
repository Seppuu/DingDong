//
//  DDRulerScrollView.swift
//  DingDong
//
//  Created by Seppuu on 4/12/16.
//  Copyright © 2016 seppuu. All rights reserved.
//

import UIKit

enum RulerViewShowType :Int {
    case rulerViewshowHorizontalType = 0
    case rulerViewshowVerticalType = 1
}

let labelFont:CGFloat     =  12.0
let heightTolabel:CGFloat = 15.0

class DDRulerScrollView: UIScrollView {
    
    var minValue:CGFloat = 0.0
    var maxValue:CGFloat = 0.0
    var rulerImage:UIImage!
    var rulerMultiple:CGFloat = 0.0
    var rulerViewShowType:RulerViewShowType = .rulerViewshowHorizontalType
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRulerData(_ maxValue:CGFloat,minValue:CGFloat,rulerViewShowType:(RulerViewShowType),rulerMultiple:CGFloat){
        
        self.maxValue = maxValue
        self.minValue = minValue
        self.rulerViewShowType = rulerViewShowType
        self.rulerMultiple = rulerMultiple
        
        self.backgroundColor = UIColor.clear
        self.isPagingEnabled = false
        self.bounces = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.clipsToBounds  = false
        self.decelerationRate = 0.7
        
        
        //水平方向
        if rulerViewShowType == .rulerViewshowHorizontalType {
            self.rulerImage = UIImage(named: "ruler_width")
            self.contentSize = CGSize( width: rulerImage.size.width*((minus(self.maxValue, mixNuber: self.minValue) / self.rulerMultiple) + 1 ), height: self.frame.size.height )
        }
        
        addImageView()
        
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        makeUI()
    }
    
    func minus(_ maxNuber:CGFloat,mixNuber:CGFloat) -> CGFloat {
        
        return abs(maxNuber-mixNuber)
    }
    
    func addImageView() {
        
        let count = Int( abs(self.maxValue - self.minValue) / self.rulerMultiple )
        
        for i in 0..<count {
            
            let imageView = UIImageView.init(image: self.rulerImage)
            imageView.tag = i
            addSubview(imageView)
            
            //创建对应的数字的Label
            let rulerLabel = UILabel()
            rulerLabel.textAlignment = .center
            rulerLabel.text = String(describing: self.minValue + CGFloat(i) * rulerMultiple)
            rulerLabel.textColor = UIColor.ddRulerLabelColor()
            rulerLabel.font = UIFont.systemFont(ofSize: labelFont)
            addSubview(rulerLabel)
            
            
        }
    }
    
    func makeUI() {
        
        
        for sub in self.subviews {
            var centerPoint: CGPoint
            var imageViewH:CGFloat = 0.0
            var imageViewW:CGFloat = 0.0
            
            if sub.isKind(of: UIImageView.self) {
                imageViewW = sub.frame.size.width
                imageViewH = sub.frame.size.height
                var imageViewX:CGFloat = 0.0
                var imageViewY:CGFloat = 0.0
                //水平方向
                imageViewX = ( self.rulerViewShowType == .rulerViewshowHorizontalType) ? CGFloat(sub.tag) : 0
                imageViewY = ( self.rulerViewShowType == .rulerViewshowHorizontalType) ? 0 : CGFloat(sub.tag)
                sub.frame = CGRect(x: imageViewX, y: imageViewY, width: imageViewW, height: imageViewH)
                centerPoint = sub.center
            }
                
            else if sub.isKind(of: UIImageView.self) {
                
                var LableW:CGFloat = 0.0
                var LableH:CGFloat = 0.0
                var LableX:CGFloat = 0.0
                var LableY:CGFloat = 0.0
                
                if (rulerViewShowType == .rulerViewshowHorizontalType) {  //水平方向
                    LableW = 60
                    LableH = 20
                    LableX = LableW/2
                    LableY = imageViewH + heightTolabel
                }
        
                
                sub.frame = CGRect(x: LableX, y: LableY, width: LableW, height: LableH)
            }
        }
    }

    
    
    
    
    
    
}
