//
//  photoGroupView.swift
//  DingDong
//
//  Created by Seppuu on 16/3/31.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class photoGroupView: UIView,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    @IBOutlet weak var startLabel: UILabel!
    
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var playButon: UIButton!

    @IBOutlet weak var playTextLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellID = "cell"
    
    var photos = [UIImage]()
    
    var intArr = [Int]() //应该高亮的cell index
    
    var sliderView = UIView()
    
    var start:Float?
    var end:Float?
    
    var playTapHandler:((_ start:Float,_ end:Float)->())?
    
    
    
    @IBAction func playButtonTap(_ sender: UIButton) {
        
        playTapHandler?(start!,end!)
    }
    
    class func instanceFromNib() -> photoGroupView {
        
        return UINib(nibName: "photoGroupView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! photoGroupView
    }
    
    override func didMoveToWindow() {
        super.didMoveToSuperview()
        
        setCollectionview()
        
        setSliderView()
    }
    
    func setCollectionview() {
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.register(photoGroupCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.backgroundColor = UIColor.white
        collectionView.reloadData()
        
    }
    
    func setSliderView() {
        
        addSubview(sliderView)
        sliderView.snp_makeConstraints { (make) in
            make.left.equalTo(collectionView)
            make.bottom.equalTo(self)
            make.width.equalTo(150)
            make.height.equalTo(2)
        }
        
        sliderView.backgroundColor = UIColor.ddCellBorderColor()
        
        sliderView.alpha = 0.0
    }
    
    // MARK: UICollectionView Methods
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! photoGroupCell
        
        //设置图片
        cell.imageView.image = photos[indexPath.item]
        
        //设置高亮
        if intArr.count > 0 {
            var shouldHighLight = false
            intArr.forEach {
                if $0 == indexPath.item { shouldHighLight = true }
                
            }
            
            if shouldHighLight {
                
                cell.layer.borderWidth = 3.0
                cell.layer.borderColor = UIColor.ddCellBorderColor().cgColor
            }
            else {
                cell.layer.borderWidth = 0.0
            }
        }
        
        //设置时间
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sliderView.alpha = 1.0
        let XoffSet = collectionView.contentOffset.x
        let XoffSetRatio = XoffSet / (collectionView.contentSize.width - collectionView.frame.size.width)
        let centerMoveWidth = collectionView.frame.size.width - 150
        //以滑块中心点 做移动过. (默认最起始位置 + 偏移长度.)
        sliderView.center.x  = collectionView.frame.origin.x + sliderView.frame.size.width/2 + centerMoveWidth * XoffSetRatio
        
        
        delay(0.8) {
            
            UIView.animate(withDuration: 0.4, animations: {
                self.sliderView.alpha = 0.0
            })
        }
    }
    
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//
//    }
    
}

class photoGroupCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        
        self.layer.cornerRadius = 6.0
        self.layer.masksToBounds = true
    }
}


