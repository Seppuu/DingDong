//
//  SubscriptionTopCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/30.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SwiftyJSON

class SubscriptionTopCell: UICollectionViewCell {

    
    @IBOutlet weak var leftView: UIView!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    
    var arrowTapHandler:(()->())?
    
    var authorTapHandler:((_ authorID:String,_ authorName:String)->())?
    
    var subView: SubscriptionTopView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subView = SubscriptionTopView.instanceFromNib()
        
        subView.authorCellTapHandler = { (authorID,authorName) in
            
            self.authorTapHandler?(authorID,authorName)
        }
        
        leftView.addSubview(subView)
        
        
        arrowImageView.backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer(target: self, action: #selector(SubscriptionTopCell.arrowTap))
        arrowImageView.isUserInteractionEnabled = true
        arrowImageView.addGestureRecognizer(tap)
    }
    
    func loadDataWith(_ list:[JSON]) {
        
        subView.listOfAuthor = list
        
        subView.collectionView.reloadData()
    }
    
    
    @objc fileprivate func arrowTap() {
        
        arrowTapHandler?()
        
    }
    
    
    
}
