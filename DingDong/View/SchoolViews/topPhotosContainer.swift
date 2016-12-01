//
//  topPhotosContainer.swift
//  DingDong
//
//  Created by Seppuu on 16/3/31.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import Photos

class topPhotosContainer:UIView,RAReorderableLayoutDelegate,RAReorderableLayoutDataSource{
    
    var collectionView: UICollectionView!
    var cancelHighLight = false
    
    var photos = [UIImage]()
    var photoAsst = [PHAsset]()
    let cellID = "cell"
    let maxPhotoCount = 8
    
    var imageCellSelectedHandler: ( (_ index:Int) -> () )?
    
    var addImageTapHandler: (()->())?
    
    var imageIndexChanged:((_ fromIndex:Int,_ toIndex:Int)->())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = RAReorderableLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame:self.bounds, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(topPhotoCell.self, forCellWithReuseIdentifier: cellID)
        addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        collectionView.reloadData()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

    }
    
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! topPhotoCell

            if (indexPath.row != photos.count) {

                cell.imageView.image = photos[indexPath.row]

            }
            else  {

                cell.imageView.image = UIImage(named: "addImage")!
            }
            if (photos.count == maxPhotoCount && indexPath.row == photos.count) {
                //照片到达规定数量之后,加号隐藏.
                cell.imageView.alpha = 0.0
            }

            if cancelHighLight {
                
                cell.checkView.alpha = 0.0
                
            }
            
            return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if photos.count < maxPhotoCount && indexPath.row == photos.count {
            //此处为添加按钮.通知上层打开相册
            addImageTapHandler?()
        }
        else {
            //高亮
            let cell = collectionView.cellForItem(at: indexPath) as! topPhotoCell
            cell.checkView.alpha = 1.0
            imageCellSelectedHandler?(indexPath.item)
            
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //使得未被点击的cell不高亮.
        let cell = collectionView.cellForItem(at: indexPath) as! topPhotoCell
        cell.checkView.alpha = 0.0

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let fourPiecesWidth = floor(screenWidth / 4.0 - ((1.0 / 4) * 3))
        
        return CGSize(width: fourPiecesWidth, height: fourPiecesWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    @objc(collectionView:canFocusItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if collectionView.numberOfItems(inSection: indexPath.section) <= 1 {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if (photos.count < maxPhotoCount && indexPath.row == photos.count ) {
            return false
        }
        
        return true
    }
    func collectionView(_ collectionView: UICollectionView, atIndexPath: IndexPath, canMoveToIndexPath: IndexPath) -> Bool {
        if (photos.count < maxPhotoCount && canMoveToIndexPath.row == photos.count ) {
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, atIndexPath: IndexPath, didMoveToIndexPath toIndexPath: IndexPath) {
        
        let photo = photos.remove(at: atIndexPath.item)
        photos.insert(photo, at: toIndexPath.item)
        
        imageIndexChanged?(atIndexPath.item,toIndexPath.item )
    }
    
    
}


class topPhotoCell: UICollectionViewCell {
    
    var imageView  = UIImageView()
    
    var checkView = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        checkView.frame = CGRect(x:self.frame.size.width - 22, y: 0, width: 22, height: 22)
        checkView.contentMode = .scaleAspectFit
        checkView.image = UIImage(named: "checkView")
        checkView.alpha = 0.0
        addSubview(checkView)
        
    }
    
    
    
}

