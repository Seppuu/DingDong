//
//  photoCell.swift
//  DingDong
//
//  Created by Seppuu on 16/2/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class photoCell: UICollectionViewCell {
    
    var imageView : UIImageView?//cell上的图片
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //初始化控件
        imageView = UIImageView(frame:self.bounds)
        imageView?.contentMode = UIViewContentMode.scaleAspectFit
        imageView?.clipsToBounds = true
        self.addSubview(imageView!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
