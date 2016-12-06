//
//  DDTextAnimeHandler.swift
//  DingDong
//
//  Created by Seppuu on 16/4/8.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit



class DDTextAnimeHandler: NSObject {


    // 无 渐现 掉落 划变 放大 缩放
    enum AnimeStyle :Int {
        case none = 0
        case fadeIn
        case drop
        case sliderIn
        case pop
        case scaleBig
        
        //在服务器中的名字.
        var nameInback:String {
            switch self {
            case .none:
                return "none"
            case .fadeIn:
                return "fade-in"
            case .drop:
                return "slide-down"
            case .sliderIn:
                return "slide-left"
            case .pop:
                return "zoom-out"
            case .scaleBig:
                return "zoom-in"
            }
        }
        
    }
    
    var animeStyle: AnimeStyle = .none
    
    func chooseAnimationFor(_ view:UIView){
        
        
        switch animeStyle {
        case .fadeIn  : fadeIn(view)
        case .drop    : drop(view)
        case .sliderIn: sliderOut(view)
        case .pop     : pop(view)
        case .scaleBig: scaleBig(view)
        default: break
        }
        
        
    }
    
    //渐现
    fileprivate func fadeIn(_ animeView:UIView){
        animeView.alpha = 0.0
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () ->Void in
            
            animeView.alpha = 1.0
        
        }, completion: nil)
        
    }
    
    //掉落
    fileprivate func drop(_ animeView:UIView){
        
        let originFrame = animeView.frame
        animeView.frame = CGRect(x:animeView.frame.origin.x , y: -animeView.frame.size.height, width: animeView.frame.size.width, height: animeView.frame.size.height)
        let secondFrame = CGRect(x:animeView.frame.origin.x , y: originFrame.origin.y - (animeView.frame.size.height * 0.8), width: animeView.frame.size.width, height: animeView.frame.size.height)
        
        //第一次降落
        UIView.animate(withDuration: 0.2, delay: 0.0, options:.transitionFlipFromTop, animations: {
            
            animeView.frame  = originFrame
            
            
        }) { (Bool) in
            //上升
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                animeView.frame  = secondFrame
                }, completion: { (Bool) in
                    //第二次降落
                    UIView.animate(withDuration: 0.1, delay: 0.01, options: .curveEaseIn, animations: {
                        animeView.frame = originFrame
                        }, completion: nil)
                    
            })
        
    
        }
        
    }
    
    //划变
    fileprivate func sliderOut(_ animeView:UIView){
        
        //Create a shape layer that we will use as a mask for the waretoLogoLarge image view
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = animeView.bounds.size.height * 2
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: animeView.layer.bounds.origin.x, y: animeView.layer.bounds.origin.y))
        
        
        path.addRect(CGRect(x: animeView.layer.bounds.origin.x, y: animeView.layer.bounds.origin.y, width: animeView.layer.bounds.size.width, height: animeView.layer.bounds.size.height))
        
        maskLayer.path = path
        
        //Start with an empty mask path (draw 0% of the arc)
        maskLayer.strokeEnd = 0.0
        
        
        //Install the mask layer into out image view's layer.
        animeView.layer.mask = maskLayer
        
        //Set our mask layer's frame to the parent layer's bounds.
        animeView.layer.mask!.frame = animeView.layer.bounds
        
        
        let swipe = CABasicAnimation(keyPath: "strokeEnd")
        swipe.duration = 2
        swipe.delegate = self
        swipe.value(forKey: "swipeAnim")
        
        swipe.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        swipe.fillMode = kCAFillModeForwards
        swipe.isRemovedOnCompletion = false
        swipe.autoreverses = false
        
        swipe.toValue = NSNumber(value: 1.0 as Float)
        
        
        maskLayer.add(swipe, forKey: "strokeEnd")
        
    }
    

    
    //弹出pop
    fileprivate func pop(_ animeView:UIView){
        
        animeView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.7, delay: 0,
                                   usingSpringWithDamping: 0.6,
                                   initialSpringVelocity: 5,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    animeView.transform = CGAffineTransform.identity
        }){ _ in
            
        }
        
        
    }
    
    
    //缩放
    fileprivate func scaleBig(_ animeView:UIView){
        
        animeView.transform = CGAffineTransform(scaleX: 4.5, y: 4.5)
        UIView.animate(withDuration: 0.7, delay: 0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 3,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    animeView.transform = CGAffineTransform.identity
        }){ _ in
            
        }
        
    }
    
}


extension DDTextAnimeHandler:CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }

    
}
