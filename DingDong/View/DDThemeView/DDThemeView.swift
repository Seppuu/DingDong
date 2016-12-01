//
//  DDThemeView.swift
//  DingDong
//
//  Created by Seppuu on 16/3/22.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DDThemeView: UIView,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    var collectionView:UICollectionView!

    var listOftheme = [Theme]()
    
    var cellID = "themeCell"
    
    typealias CellSelectedHandler = (_ themeIndex:Int) -> Void
    
    var cellSelectedHandler:CellSelectedHandler?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame:self.bounds, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        addSubview(collectionView)
        collectionView.backgroundColor = UIColor.ddViewBackGroundColor()
        collectionView.reloadData()

    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
    }
    
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOftheme.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(frame: cell.bounds)
        let url = listOftheme[indexPath.item].imageUrl
        imageView.kf.setImage(with: url)
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        self.cellSelectedHandler!(indexPath.item)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let threePiecesWidth = floor(screenWidth / 3.0 - ((2.0 / 3) * 2))
        
        return CGSize(width: self.ddHeight, height: self.ddHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
}



class DDThemeViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = self.bounds
        
        addSubview(imageView)
    }
    
}
