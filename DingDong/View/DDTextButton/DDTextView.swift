//
//  DDTextView.swift
//  DingDong
//
//  Created by Seppuu on 16/3/16.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

protocol DDTextViewDelegate {
    
    /**
     开始滑动"移动我"
     */
    func DDTextViewFadeBegin(_ currentIndex:Int)
    
    
    /**
     滑动"移动我"结束
     */
    func DDTextViewFadeEnded(_ currentIndex:Int)
    
    /**
     取消滑动"移动我"
    */
    func DDTextViewFadeCanceled(_ currentIndex:Int)
    
    /**
     文本框开始编辑
     */
    func DDTextViewBeginEdit(_ currentTextView:DDTextView)
    
    /**
     文本框在移动
     */
    func DDTextViewBeginMove(_ textView:DDTextView,left:CGFloat,right:CGFloat)
    
    /**
     文本框停止移动
     */
    func DDTextViewEndMove(_ textView:DDTextView)
    
    /**
     文本框被点击
     */
    func DDTextViewTapped(_ textView:DDTextView)
    
    /**
     文本框尺寸变化了
     */
    func DDTextViewSizeChanged(_ textView:DDTextView,height:CGFloat)
    
}


class DDTextView: UITextView  {
    
    var viewIndex = 0
    
    var singleLineMode = true
    
    var lineNumber = 1
    
    var hasShowTime = false
    
    var shouldRemove = false
    
    var moveDisable = false
    
    var originFrame = CGRect()
    
    var shimmerLabel = UIView()
    
    var loadingLabel = UILabel()
    
    var deleteKeyTap = false
    
    var showTime = DDShowTime()
    
    var DDdelegate: DDTextViewDelegate!
    
    var leftMargin: CGFloat  = screenWidth * 0.05
    
    var rgihtMargin: CGFloat = screenWidth * 0.95
    
    var positionLitmitted = false
    
    var maxWidth:CGFloat = screenWidth * 0.90
    
    var minWidth:CGFloat = 0
    
    var gradientLayer = CAGradientLayer() //渐变层
    
    var frameFixed:CGRect?
    
    var color:Colors = .Black  //默认是第一个颜色(black)
    
    var hasSuperView = false
    
    var textIsPasted = false
    
    //默认是第二个字号(14)
    var fontSize: FontSize = .one {
        //检测变化
        didSet{
            //防止在从数据库建立字号的时候,更改frame.(此时没有加到UI中.)
            guard hasSuperView else {return}
            fitSizeWithFontChange()
        }
        
    }
    
    var animeIndex:Int = 0 //没有默认值.此时是不支持录制时,滑动滑块,设置出现时间点.
    
    enum State {
        
        case edit
        case record
        case userPlaying
    }
    
    var state: State = .edit {
        
        willSet {
            
            switch newValue {
                
            case .edit:
                shimmerLabel.alpha = 0.0
                
            case .record:
                shimmerLabel.alpha = 1.0
                
            case .userPlaying:
                shimmerLabel.alpha = 0.0
                self.isUserInteractionEnabled = false
            }
            
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        //严格的说,这个方法在移除,移入都会触发.并不是最合适的时机.
        hasSuperView = true
        
        originFrame = self.frame
        
        delegate    = self
        
        makeSelf()
        
        makeUI()
        
        makeGesture()
    }
    
    func makeSelf() {
        
        self.isScrollEnabled       = false
        self.font                = UIFont.systemFont(ofSize: 18)
        self.backgroundColor     = UIColor.ddTextViewBackColor()
        
        self.layer.borderWidth   = 0.8
        self.clipsToBounds       = false
        self.layer.cornerRadius  = 8.0
        self.layer.borderColor   = UIColor.clear.cgColor
        
        self.textColor           = color.hexColor
        self.font                = fontSize.font
        
        if state != .userPlaying {
            self.center.x        = screenWidth/2
        }
        
    }
    
    func makeUI() {
        
        let shimmerFrame = CGRect(x: (bounds.size.width * (0.2)), y: 0, width: bounds.size.width * (0.8), height: bounds.size.height)
        
        shimmerLabel = UIView(frame: shimmerFrame)
        shimmerLabel.contentMode = .scaleAspectFit
        shimmerLabel.layer.cornerRadius = 8.0
        shimmerLabel.layer.masksToBounds = true
        addSubview(shimmerLabel)
        
        shimmerLabel.alpha = 0.0
        
        //设置渐变色
        gradientLayer.frame = shimmerLabel.bounds
        gradientLayer.cornerRadius = 8.0
        gradientLayer.masksToBounds = true
        shimmerLabel.layer.addSublayer(gradientLayer)
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0)
        
        gradientLayer.colors = [ UIColor ( red: 0.1299, green: 0.4966, blue: 0.8104, alpha: 0.8 ).cgColor,
                                 UIColor ( red: 0.149, green: 0.5765, blue: 0.8471, alpha: 1.0 ).cgColor ]
        
        gradientLayer.locations = [0,1]
        
        let loadingFrame = CGRect(x: 0, y: 0, width: 40, height:shimmerLabel.frame.size.height)
        loadingLabel = UILabel(frame:loadingFrame)
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 18, weight: 1)
        loadingLabel.textColor = UIColor.white
        loadingLabel.text = ">>"
        shimmerLabel.addSubview(loadingLabel)
        
        
    }
    
    func makeGesture() {
        let panSelf = UIPanGestureRecognizer(target: self, action: #selector(DDTextView.panSelf(_:)))
        addGestureRecognizer(panSelf)
        
        let panSlider = UIPanGestureRecognizer(target: self, action: #selector(DDTextView.panSlider(_:)))
        shimmerLabel.addGestureRecognizer(panSlider)
        
    }
    
    
    func panSelf(_ sender:UIPanGestureRecognizer) {
        
        guard moveDisable == false else { return }
        
        if sender.state == UIGestureRecognizerState.ended  && state == .edit {
            // pan end tell delegate
            DDdelegate.DDTextViewEndMove(self)
            
        }

        let p = sender.translation(in: self)
        
        let centerX = (sender.view?.center.x)! + p.x
        let centerY = (sender.view?.center.y)! + p.y
        
        //here have two kind of pan action
        if state == .edit {
            // could pan to any position except left and right 10% margin
            
            let x = self.frame.origin.x +  p.x
            let width = self.frame.size.width
            
           // if x >= leftMargin  &&  x + width <= rgihtMargin {
                
                sender.view?.center = CGPoint(x: centerX, y: centerY)
                DDdelegate.DDTextViewBeginMove(self, left: x, right: x + width)
            //}
            
            originFrame = self.frame
        }
        else if state == .record {

        }
        else if state == .userPlaying {
            
        }

        sender.setTranslation(CGPoint.zero, in:self)
    }
    
    func fixFrameAfterPan() {
        
        
        UIView.animate(withDuration: 0.3) {
            self.fixSelfXPositionIfNeed()
        }
        
        
    }
    
    
    func panSlider(_ sender:UIPanGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.ended  && state == .record {
            // animate self when pan end
            makeAnime()
            
        }
        
        let p = sender.translation(in: self)
        
        let centerX = (sender.view?.center.x)! + p.x
        
        let velocity = sender.velocity(in: self)
        
        if state == .record {
            
            // set only pan to right
            guard velocity.x > 0 else { return }
            
            // begin to assign displayTime
            DDdelegate.DDTextViewFadeBegin(viewIndex)
            
            shimmerLabel.center.x = centerX
            let percentage = (centerX + 100) / (screenWidth)
            let aplha1 = 1.0 - percentage
            
            self.alpha = aplha1
        }
        
        sender.setTranslation(CGPoint.zero, in:self)
        
    }
    
    

    func updateShimmerView() {
        
        let shimmerFrame = CGRect(x: (self.frame.size.width * (0.2)), y: 0, width:self.frame.size.width * (0.8), height: self.frame.size.height)
        shimmerLabel.frame = shimmerFrame
        
        gradientLayer.frame = shimmerLabel.bounds
        
        let loadingFrame = CGRect(x: 0, y: 0, width: 40, height:  shimmerLabel.frame.size.height)
        loadingLabel.frame = loadingFrame
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 18, weight: 1)
        loadingLabel.textColor = UIColor.white
        loadingLabel.text = ">>"
        
    }
    
    func makeAnime() {
        
        // touch end ,check self alpha
        guard self.alpha <= 0.5 else {
            
            // reset self to origin position
            let shimmerFrame = CGRect(x: (bounds.size.width * (0.2)), y: 0, width: bounds.size.width * (0.8), height: bounds.size.height)
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                
                self.alpha = 1.0
                self.shimmerLabel.frame = shimmerFrame
               
                }, completion: { (success) -> Void in
                    // textView will be uneditable
                    self.alpha = 1.0
                    // tell delegate ddTextView fade cancel
                    self.DDdelegate.DDTextViewFadeCanceled(self.viewIndex)
            })
            
            return
        }
        
        // animate dissmiss self
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
            self.alpha = 0.0
            
            self.shimmerLabel.frame.origin.x = screenWidth
            
            }, completion: { (success) -> Void in

                self.shimmerLabel.alpha = 0.0
                
                self.alpha = 1.0
               
                self.isEditable = false
               
                self.DDdelegate.DDTextViewFadeEnded(self.viewIndex)
        })

    }
    
    func displayTextViewByTime() {
        
        let animeHanler = DDTextAnimeHandler()
        animeHanler.animeStyle = DDTextAnimeHandler.AnimeStyle(rawValue: animeIndex)!
        animeHanler.chooseAnimationFor(self)
        
        animeHanler.animeDidStopHandler = {
            
            if self.animeIndex == 3 {
                self.layer.mask = nil
            }
            
        }
    
    }
    
    var highLight = true
    func highLightSelf() {
        
        self.layer.borderColor = UIColor.ddTextViewHighLightColor().cgColor
        
        highLight = true
    }
    
    func deHighLightSelf() {
        
        self.layer.borderColor = UIColor.clear.cgColor
        
        highLight = false
    }
    
    //根据字号变化,调整文本框大小
    func fitSizeWithFontChange() {
        
//        var frame2 = self.frame
//        frame2.size.height = self.contentSize.height
//        self.frame = frame2
//        
//        self.sizeToFit()
//        
//        if self.frame.size.width < 50 {
//            self.frame.size.width = 50
//        }
//        else if self.frame.size.width >=  rgihtMargin - self.frame.origin.x - 40  {
//            self.frame.size.width =  rgihtMargin - self.frame.origin.x
//        }
//        else if self.frame.size.width <= rgihtMargin - self.frame.origin.x - 40 {
//            self.frame.size.width =  self.frame.size.width + 40
//        }
        
        self.textViewDidChange(self)
        //fixSelfXPositionIfNeed()
        //updateShimmerView()
    }
    
}

extension DDTextView : UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        DDdelegate.DDTextViewTapped(self)
       
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //check which key tap , change some status
        
        deleteKeyTap = false
        if (range.length == 1 && text.isEmpty){
            //print("Used Backspace")
            deleteKeyTap = true
        }
        
        if text == "\n" {
            //print("Used Return")
            lineNumber += 1
        }
        
        // Here we check if the replacement text is equal to the string we are currently holding in the paste board
        if text == UIPasteboard.general.string {
            //user is using paste
            textIsPasted = true
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
       
        if textView.frame.size.width < 50 {
            textView.frame.size.width = 50
        }
        DDdelegate.DDTextViewBeginEdit(self)
        
    }

    
    func textViewDidChange(_ textView: UITextView) {
        
        // get current line index
        var rows = round((textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / (textView.font?.lineHeight)!)
        if rows == 0 {
            rows = 1
        }
        
        lineNumber = Int(rows)
        
        if lineNumber == 1 {
            singleLineMode = true
        }
        else {
            singleLineMode = false
        }
        
        if textIsPasted  {
            
            var frame2 = textView.frame
            
            frame2.size.width  = maxWidth
            textView.frame = frame2
            
            singleLineMode = false
            
            textIsPasted = false
            
        }
        
        
        if deleteKeyTap {
            //delete key tap　进入高度,宽度同时缩减.
            var frame2 = textView.frame
            frame2.size.height = textView.contentSize.height
            textView.frame = frame2
            
            textView.sizeToFit()
            
            if textView.frame.size.width < 50 {
                textView.frame.size.width = 50
            }
            else if textView.frame.size.width >=  rgihtMargin - textView.frame.origin.x - 40  {
                textView.frame.size.width =  rgihtMargin - textView.frame.origin.x
            }
            else if textView.frame.size.width <= rgihtMargin - textView.frame.origin.x - 40 {
                textView.frame.size.width =  textView.frame.size.width + 40
            }
            
            //fixSelfXPositionIfNeed()
            deleteKeyTap = false
            
            //return
            
        }
        
        
        guard textView.frame.size.width < (maxWidth) else {
            
            //限宽到了之后只进行高度自动.
            let fixedWidth = textView.frame.size.width
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            textView.frame = newFrame
            fixSelfXPositionIfNeed()
            updateShimmerView()
            return
        }
        
        
        if (singleLineMode) {
            //单行模式,或者多行模式下,文本宽度小于限定宽度,增加宽度
            
            let fixedHeight = textView.frame.size.height
            textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight))
            let newSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height:fixedHeight))
            var newFrame = textView.frame
            let minWidth = max(50, newSize.width)
            
            newFrame.size = CGSize(width:minWidth, height: max(newSize.height, fixedHeight))
            textView.frame = newFrame
            textView.frame.size.width += 40
            
            
        }
        else {
            
            //现在是多行模式,如果文本框宽度小于限定,默认还是增加宽度.
            if textView.frame.size.width < (maxWidth) {
                
                let fixedHeight = textView.frame.size.height
                textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight))
                let newSize = textView.sizeThatFits(CGSize(width:  CGFloat.greatestFiniteMagnitude, height:fixedHeight))
                var newFrame = textView.frame
                let minWidth = max(50, newSize.width)
                newFrame.size = CGSize(width:minWidth, height: max(newSize.height, fixedHeight))
                textView.frame = newFrame
                textView.frame.size.width =  textView.frame.size.width + 40
                
                

            }
            else {
                //多行模式,同时文本框已经达到限定,增加自动换行,增加高度
                let fixedWidth = textView.frame.size.width
                textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = textView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                textView.frame = newFrame
                
                
            }
            
            
        }
        
        //如果文本框超出了禁止区域,自动贴边.
        fixSelfXPositionIfNeed()
        
        frameFixed = textView.frame
        
        originFrame = self.frame

        updateShimmerView()
        
    }

    
    
    func fixSelfXPositionIfNeed() {
        
//        var frame2 = self.frame
//        frame2.size.height = self.contentSize.height
//        self.frame = frame2
//        
//        self.sizeToFit()
//        
//        if self.frame.size.width < 50 {
//            self.frame.size.width = 50
//        }
//        else if self.frame.size.width >=  rgihtMargin - self.frame.origin.x - 40  {
//            self.frame.size.width =  rgihtMargin - self.frame.origin.x
//        }
//        else if self.frame.size.width <= rgihtMargin - self.frame.origin.x - 40 {
//            self.frame.size.width =  self.frame.size.width + 40
//        }

    
        let x = self.frame.origin.x
        let width = self.frame.size.width
        
        if  x + width >= rgihtMargin {
            
            self.frame.origin.x  = rgihtMargin - width
        }
        
        if  x <= leftMargin {
            
            self.frame.origin.x  = leftMargin
        }
        
        if width > maxWidth {
            self.frame.size.width = maxWidth
        }
        
        
        DDdelegate.DDTextViewSizeChanged(self, height: self.ddHeight)
    }
    
    
   // func
    
    
    
}
