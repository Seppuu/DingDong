//
//  DDPlaypartRecordAlertView.swift
//  DingDong
//
//  Created by Seppuu on 16/3/25.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SnapKit

class DDPlaypartRecordAlertView: UIView {
    
    var timeTextLabel = UILabel()
    var imageView = UIImageView()
    var countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 10.0
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = true
        self.layer.shadowOpacity = 0.7
        self.layer.shadowColor = UIColor ( red: 0.6445, green: 0.6445, blue: 0.6445, alpha: 1.0 ).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: -4)
        self.layer.shadowRadius = 10
    }
    
    override func didMoveToSuperview() {
         super.didMoveToSuperview()
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func makeUI() {
        addSubview(timeTextLabel)
        timeTextLabel.snp_makeConstraints { (make) -> Void in
            make.left.top.right.equalTo(self)
            make.height.equalTo(30)
        }
        
        timeTextLabel.textAlignment = .center
        timeTextLabel.font = UIFont.systemFont(ofSize: 15)
        timeTextLabel.textColor = UIColor.black
        timeTextLabel.text = "00:00/00:00"
        
        addSubview(imageView)
        imageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(timeTextLabel.snp_bottom)
            make.left.right.bottom.equalTo(self)
        }
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        
        addSubview(countLabel)
        countLabel.snp_makeConstraints { (make) -> Void in
            make.left.right.top.bottom.equalTo(imageView)
        }
        
        countLabel.textAlignment = .center
        countLabel.textColor = UIColor.white
        countLabel.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1953125 )
        countLabel.font = UIFont.systemFont(ofSize: 100)
        
    }
    
    
    func changeImageViewImage(_ toImage:UIImage,imageIndex:Int) {
        
        //渐变隐藏imageview,更换图片,渐变显示imageview
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
            self.imageView.alpha = 0.0
            
            }) { (success) -> Void in
            
                self.imageView.image = toImage
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    
                    self.imageView.alpha = 1.0
                    self.countLabel.text = "\(imageIndex)"
                    }, completion: nil)
            
        }
        
//        self.imageView.image = toImage
//        self.countLabel.text = "\(imageIndex)"
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

}
