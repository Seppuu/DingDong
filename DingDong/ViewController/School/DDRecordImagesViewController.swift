//
//  DDRecordImagesViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/3/24.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DDRecordImagesViewController: BaseViewController {

    var collectionView:UICollectionView!
    var images = [UIImage]()
    var dismissButton = UIButton()
    var imagePadding:CGFloat = 2.0
    let cellID = "cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
        addButton()
    }

    func setCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = imagePadding
        
        collectionView = UICollectionView(frame: CGRect(x: 0,y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor ( red: 0.9362, green: 0.9317, blue: 0.9407, alpha: 1.0 )
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.register(photoCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    func addButton() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DDRecordImagesViewController : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    //MARK: UICollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! photoCell

        cell.imageView!.image = images[indexPath.row]
        
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
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }

    
}
