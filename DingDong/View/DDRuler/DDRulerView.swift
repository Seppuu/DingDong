//
//  DDRulerView.swift
//  DingDong
//
//  Created by Seppuu on 4/12/16.
//  Copyright © 2016 seppuu. All rights reserved.
//

import UIKit

let RulerPointerViewH:CGFloat  = 25.0
let RulerPointerViewW:CGFloat  = 1.0


protocol DDRulerViewDelegate {
    
    func getRulerValue(_ rulerValue:CGFloat)
}



class DDRulerView: UIView ,UIScrollViewDelegate{
    
    var delegate:DDRulerViewDelegate!
    
    var defaultValue:CGFloat = 0.0 {
        
        didSet {
            print(defaultValue)
            let ruleImage = UIImage(named: "ruler_width")
            
            let formlength = ruleImage!.size.width / self.rulerMultiple
            let gapValue  = (defaultValue - minValue + (CGFloat(rulerMultiple/2))) * formlength
            
            print(ruleImage!.size.width)
            if (self.rulerViewShowType == .rulerViewshowHorizontalType) {
                rulerView.contentOffset=CGPoint(x: gapValue, y: 0)
            }else{
                rulerView.contentOffset=CGPoint(x: 0, y: gapValue)
            }
        }
    }
    
    var minValue:CGFloat = 0.0
    var maxValue:CGFloat = 0.0
    var rulerImage:UIImage!
    var rulerMultiple:CGFloat = 0.0
    var rulerViewShowType:RulerViewShowType = .rulerViewshowHorizontalType
    var pointerView = UIView()
    var rulerView = DDRulerScrollView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setRulerData(_ maxValue:CGFloat,minValue:CGFloat,rulerViewShowType:(RulerViewShowType),rulerMultiple:CGFloat) {
        
        self.maxValue = maxValue
        self.minValue = minValue
        self.rulerViewShowType = rulerViewShowType
        self.rulerMultiple = rulerMultiple
        
        self.rulerView.setRulerData(maxValue, minValue: minValue, rulerViewShowType: rulerViewShowType, rulerMultiple: rulerMultiple)
        self.rulerView.delegate = self
        
        addSubview(rulerView)
        
        //添加红点的View
        self.pointerView.backgroundColor = UIColor.red
        addSubview(pointerView)
        
        
        
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        makeUI()
        
    }
    
    func makeUI() {
        if rulerViewShowType == .rulerViewshowHorizontalType {
            //水平方向
            let pointerViewH  = RulerPointerViewH
            let pointerViewW = RulerPointerViewW
            let pointerViewX  = (self.frame.size.width-pointerViewW)/2
            let pointerViewY:CGFloat = 0
            pointerView.frame = CGRect(x: pointerViewX, y: pointerViewY, width: pointerViewW, height: pointerViewH)
            rulerView.frame = CGRect(x: self.frame.size.width/2, y: 0, width: RulerPointerViewW, height: self.frame.size.height)
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    
    
    
    // MARK: Scroll Delegate Method
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //获取每一个表格的长度
        let image  = UIImage(named: "ruler_width")
        let length = image!.size.width / CGFloat(rulerMultiple)

        //指针指向的刻度
        var value:CGFloat = 0
        //滑动的刻度值
        var scrollValue:CGFloat = 0
        
        var contentOffsetValue:CGFloat = 0
        if rulerViewShowType == .rulerViewshowHorizontalType {
            
            contentOffsetValue = scrollView.contentOffset.x
        }
        else {
            contentOffsetValue = scrollView.contentOffset.y
        }
        
        scrollValue = (contentOffsetValue/length)-(CGFloat(rulerMultiple)/2)
        
        value = minValue + scrollValue
            
        self.delegate.getRulerValue(value)
        
        
    }
    
    
    
    //MARK: 
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let view = super.hitTest(point, with: event)
        if view!.isKind(of: DDRulerView.self) {
            return rulerView
        }
        else {
            return view
        }

    }
    
    
    
    
    
    
    
    
    
}
