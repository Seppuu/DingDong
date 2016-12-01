//
//  DDShowImagesView.swift
//  DingDong
//
//  Created by Seppuu on 16/3/24.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import Kingfisher

/// 展示图片集的类
class DDImagesAttachmentView: UIView {
    
    var collectionView:UICollectionView!
    
    var photos = List<Picture>() {
        
        didSet {
            //Prefetching Images
            guard dataFromServer == true else {return}
            prefetchImages()
        }
    }
    
    var imageResources = [Resource]()
    
    var dismissButton = UIButton()
    var imagePadding:CGFloat = 5.0
    let cellID = "cell"
    var currentPage = 0
    
    var dataFromServer = false
    
    var imageScorlledHandler: ((_ index:Int) -> ())?
    
    var dismissViewHandler: (() -> ())?
    
    var setDefaultImagePosition = false
    
    override func didMoveToSuperview() {
        superview?.didMoveToSuperview()
        
        makeUI()
    }
    
    func makeUI() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = imagePadding
        
        collectionView = UICollectionView(frame: CGRect(x: 0,y: 0, width: self.frame.size.width, height: self.frame.size.height), collectionViewLayout: layout)
        self.addSubview(collectionView)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor  = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0 )
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.register(photoCell.self, forCellWithReuseIdentifier: cellID)
        
        
        addSubview(dismissButton)
        dismissButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp_bottom).offset(-44)
            make.width.height.equalTo(50)
        }
        
        dismissButton.setTitle("返回", for: UIControlState())
        dismissButton.layer.cornerRadius = 25
        dismissButton.layer.masksToBounds = true
        dismissButton.backgroundColor = UIColor ( red: 0.9748, green: 0.4351, blue: 0.1996, alpha: 0.680099826388889 )
        dismissButton.addTarget(self, action: #selector(DDImagesAttachmentView.dismissSelf), for: UIControlEvents.touchUpInside)
        
    }
    
    func prefetchImages() {
        
        var urlStrings = [String]()
        guard photos.count >= 1 else {return}
        for photo in photos {
            let url = photo.imageURL
            urlStrings.append(url)
        }
        
        let urls = urlStrings.map { URL(string: $0)! }
        let prefetcher = ImagePrefetcher(urls: urls, options: nil, progressBlock: { (skippedResources, failedResources, completedResources) in
            
            
            
        }) { (skippedResources, failedResources, completedResources) in
            self.imageResources = completedResources
        }
            
        prefetcher.maxConcurrentDownloads = urls.count
        prefetcher.start()
        
        
    }
    
    func dismissSelf() {
        //通知总控制台,案例浏览页面已经关闭.
        dismissViewHandler!()
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.alpha = 0.0
            
            }) { (success) -> Void in
                //!!注意这里的处理,会在播放队列中,"关闭"动作之后,触发添加一个"移动"动作.所以添加一个bool来控制闭包触发.
                self.setDefaultImagePosition = true
                var toIndex = 0 //前往的页面
                if self.currentPage < self.photos.count - 1 {
                    
                    toIndex = self.currentPage + 1
                }
                else {
                    //已经到达最后一页,重置到第一页.
                    toIndex = 0
                }
                
                
                self.collectionView.scrollToItem(at: IndexPath(item: toIndex, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
        }
        
    }
    
}

extension DDImagesAttachmentView : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    //MARK: UICollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! photoCell
        
        if dataFromServer == true {
            //用户播放,使用服务器数据
            if imageResources.count != 0 {
                let resource = imageResources[indexPath.row]
                cell.imageView!.kf.setImage(with: resource)
            }
            else {
                let url = photos[indexPath.row].imageURL
                cell.imageView?.kf.setImage(with: URL(string: url)!)
            }

        }
        else {
            //录制播放,使用本地数据
           cell.imageView!.image = photos[indexPath.row].image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    //MARK:UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let previousPage = currentPage
        
        currentPage = Int(scrollView.contentOffset.x / self.ddWidth)
        
        if currentPage != previousPage {
            
            //图片发生了移动,通知总控制中心更新播放队列.
            
            guard setDefaultImagePosition else {
                
                let realm = try! Realm()
                try! realm.write {
                   self.photos[currentPage].willShow = true
                }
                
                imageScorlledHandler?(currentPage)
                
                return
            }
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.collectionView {
            var currentCellOffset = self.collectionView.contentOffset
            currentCellOffset.x += self.collectionView.frame.size.width / 2
            let indexPath = self.collectionView.indexPathForItem(at: currentCellOffset)
            
            self.collectionView.scrollToItem(at: indexPath!, at: .centeredHorizontally, animated: true)
        }
    }
    
    
}



