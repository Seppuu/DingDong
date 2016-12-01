//
//  DDFilterView.swift
//  DingDong
//
//  Created by Seppuu on 16/3/10.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

let kDDFilterViewWillShowNotification    = "DDFilterViewWillShowNotification";
let kDDFilterViewWillDismissNotification = "DDFilterViewWillDismissNotification";
let kDDFilterViewDidShowNotification     = "DDFilterViewDidShowNotification";
let kDDFilterViewDidDismissNotification  = "DDFilterViewDidDismissNotification";

let kDDFilterViewWidthMargin:CGFloat = 8.0
let kDDFilterViewWidth      :CGFloat = (320.0 - kDDFilterViewWidthMargin*2)

 protocol DDFilterViewDelegate  {
    
    func filterViewWillShow(_ filterView:DDFilterView)
    func filterViewWillDismiss(_ filterView:DDFilterView)
    func filterViewDidShow(_ filterView:DDFilterView)
    func filterViewDidDismiss(_ filterView:DDFilterView)
    
    func filterView(_ filterView:DDFilterView,buttonPressedWithTitle title:String,index:Int)
    
    func filterViewCancelled(_ filterView:DDFilterView)
}

class DDFilterView: UIView {

    enum DDFilterViewTransitionStyle : Int {
        case ddFilterViewTransitionStyleTop    = 0
        case ddFilterViewTransitionStyleCenter = 1
    }
    
    var showing = false
    
    var selectedIndex = 0
    
    var offset:CGPoint?
    var contentInset:UIEdgeInsets?
    var height:CGFloat = 0.0
    
    var separatorsVisible = false
    var separatorsColor:UIColor?
    var separatorsEdgeInsets:UIEdgeInsets?
   
    var titleColor:UIColor?
    var titleColorHighlighted:UIColor?
    var titleColorSelected:UIColor?
    
    var backgroundColorHighlighted:UIColor?
    var backgroundColorSelected:UIColor?
    
    var font:UIFont?
    var numberOfLines = 0
    var lineBreakMode:NSLineBreakMode?
    var textAlignment:NSTextAlignment?
    var adjustsFontSizeToFitWidth = false
    var minimumScaleFactor:CGFloat = 0.0
    
    var cornerRadius:CGFloat = 0.0
    var borderWidth:CGFloat = 0.0
    var borderColor:UIColor?
    
    var indicatorStyle:UIScrollViewIndicatorStyle?
    
    typealias willShowHandler    = (_ filterView:DDFilterView) -> Void
    typealias willDismissHandler = (_ filterView:DDFilterView) -> Void
    typealias didShowHandler     = (_ filterView:DDFilterView) -> Void
    typealias didDismissHandler  = (_ filterView:DDFilterView) -> Void
    
    typealias actionHandler = (_ filterView:DDFilterView,_ title:String,_ index:Int) -> Void
    typealias cancelHandler = (_ filterView:DDFilterView) -> Void
    
    var delegate:DDFilterViewDelegate?
    
    
    
    
}
