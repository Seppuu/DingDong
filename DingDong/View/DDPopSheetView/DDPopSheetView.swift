//
//  DDPopSheetView.swift
//  DingDong
//
//  Created by Seppuu on 16/5/20.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DDPopSheetView: UIView {

    fileprivate let DDTag = 887
    
    var containerView = UIView()
    
    var showDuration:TimeInterval = 0.3
    
    var dimView:UIView!
    
    // background
    var overlayColor = UIColor(white: 0, alpha: 0.2)
    
    //var sheetOpenHandler:(dd:String) -> Void?
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    init() {
        let frame = UIScreen.main.bounds
        super.init(frame: frame)
        
        if let window = UIApplication.shared.keyWindow {
            // if window.viewWithTag(DDTag) == nil {
            //   self.tag = DDTag
            window.addSubview(self)
            // }
        }
        self.backgroundColor = UIColor.clear
        
        containerView.backgroundColor = UIColor.white
        containerView.clipsToBounds = true
        
        dimView = UIView(frame: frame)
        dimView.backgroundColor = overlayColor
        dimView.alpha = 0.0
        addSubview(dimView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(DDPopSheetView.dismiss))
        dimView.isUserInteractionEnabled = true
        dimView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismiss() {
        
    
        UIView.animate(withDuration: showDuration, delay: 0.0, options: .curveEaseIn, animations: {
            self.dimView.alpha = 0.0
            self.containerView.frame.origin.y = self.bounds.height
            
        }) { (Bool) in
            
            for subView in self.containerView.subviews {
                subView.removeFromSuperview()
            }
            for subView in self.subviews {
                subView.removeFromSuperview()
            }
            
            self.removeFromSuperview()
        }
        

    }
    
    func show() {
        
        //make self
        initContainer()
        let containrtY = containerView.frame.origin.y
        containerView.frame.origin.y = self.bounds.height
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: { 
            self.dimView.alpha = 1.0
            self.containerView.frame.origin.y = containrtY
            
            }) { (Bool) in
                
        }
        
    }
    
    func initContainer() {
        
        self.addSubview(containerView)

    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    

}
