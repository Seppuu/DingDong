//
//  DDTextFontEditView.swift
//  DingDong
//
//  Created by Seppuu on 16/4/7.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import StepSlider
import SnapKit

class DDTextFontEditView: UIView {

    
    @IBOutlet weak var slider: StepSlider!
    @IBOutlet weak var sliderWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftA: UILabel!

    @IBOutlet weak var leftAWidthConstarint: NSLayoutConstraint!
    @IBOutlet weak var rightA: UILabel!
    
    
    @IBOutlet weak var rightAWidthConstraint: NSLayoutConstraint!
    
    var size: FontSize = .two {
        
        didSet {
            slider.index = UInt(FontSize.allValues.index(of: size)!)
        }
    }
    
    var fontSizeChangeHandler:((_ sizeIndex:Int)->())?
    
    class func instanceFromNib() -> DDTextFontEditView {
        
        return UINib(nibName: "DDTextFontEditView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DDTextFontEditView
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        
       
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        makeUI()
    }
    
    func makeUI() {
        let margin = ( self.bounds.size.width / 5 ) / 2
        let width  = ( self.bounds.size.width / 5 ) * 4
        
        leftAWidthConstarint.constant = margin
        rightAWidthConstraint.constant = margin
        
        leftA.setNeedsUpdateConstraints()
        rightA.setNeedsUpdateConstraints()
       
        //将宽度增加两个半径的长度.
        sliderWidthConstraint.constant = width + 2*(slider.sliderCircleRadius)
        slider.setNeedsUpdateConstraints()
        
    }
    
    
    @IBAction func sliderValueChanged(_ sender: StepSlider) {
        
        guard sender.index < 5 else {return}
        
        fontSizeChangeHandler?(Int(sender.index))
    }
    
    
    
    
    
}
