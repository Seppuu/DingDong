//
//  SubscriptionTopView.swift
//  DingDong
//
//  Created by Seppuu on 16/5/30.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SwiftyJSON

class SubscriptionTopView: UIView,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellID = "SubscriptionDetailCell"
    
    var photos = [UIImage]()
    
    var listOfAuthor = [JSON]()
    
    var authorCellTapHandler:((_ authorID:String,_ authorName:String)->())?
    
    class func instanceFromNib() -> SubscriptionTopView {
        
        return UINib(nibName: "SubscriptionTopView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SubscriptionTopView
    }
    
    override func didMoveToWindow() {
        super.didMoveToSuperview()
        
        setCollectionview()
        
    }
    
    func setCollectionview() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        //collectionView.bounces = false
        let nib = UINib(nibName: cellID, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellID)
        
        collectionView.reloadData()
        
    }

    // MARK: UICollectionView Methods
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 50, height: 50)

        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfAuthor.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SubscriptionDetailCell
        
        let urlString = listOfAuthor[indexPath.row]["avator"].string!
        let url = URL(string: urlString)
        
        cell.avatarView.kf.setImage(with: url!)
        
        let newUpload = listOfAuthor[indexPath.row]["new_course"].bool!
        
        if (newUpload == true) {
            
            cell.unReadDot.alpha = 1.0
        }
        else {
            cell.unReadDot.alpha = 0.0
        }
        
        //设置时间
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let authorID = listOfAuthor[indexPath.row]["user_id"].string!
        let authorName = listOfAuthor[indexPath.row]["name"].string!
        
        authorCellTapHandler?(authorID,authorName)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}



