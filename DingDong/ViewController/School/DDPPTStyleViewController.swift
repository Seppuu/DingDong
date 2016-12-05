//
//  DDPPTStyleViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/3/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import RealmSwift

class DDPPTStyleViewController: BaseViewController {

    var collectionView:UICollectionView!
    let cellID = "cell"
    
    var listOfTheme = [Theme]()
    
    var listOfImageURL = [String]()
    
    var themeSelected = Theme()
    
    var themeView = ThemeSettingView()
    
    var styleSelectedHandler:((_ theme:Theme) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "背景"
        //setNavBarItem()
        setCollection()
        getTheme()
        
        addThemeSettingView()
        
    }
    
    func setCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(DDPPTStyleCell.self, forCellWithReuseIdentifier: cellID)
        view.addSubview(collectionView)
        collectionView.reloadData()
        
    }
    
    
    func getTheme() {
        let realm = try! Realm()
        //try get theme from realm then update theme from back
        let result = realm.objects(Theme.self)
        //将主题保存进realm数据库
        if result.count > 0 {
            listOfTheme = Array(result)
            collectionView.reloadData()
        }
        else {
            //数据中无主题
            
        }
        
        getThemeDataFromBack()
    }
    
    func getThemeDataFromBack() {
        
        NetworkManager.sharedManager.getThemes { (success, json,errorMsg) in
            
            if success {
                
                if let arr = json?.array {
                    
                    var themes = [Theme]()
                    
                    for dict in arr {
                        let theme = Theme()
                        theme.nameValue = dict["value"].string!
                        theme.imageURLString = dict["image"].string!
                        themes.append(theme)
                    }
                    
                    if themes.count == self.listOfTheme.count {
                        //不需要做任何动作.
                    }
                    else {
                        //需要更新主题数据库
                        self.updateListOfThemeInRealmWith(themes)
                        self.listOfTheme = themes
                        self.collectionView.reloadData()
                    }
                    
                }
                
            }
            else {
                //TODO:error handler
                
            }
        }

    }
    
    func updateListOfThemeInRealmWith(_ newListOfTheme:[Theme]) {
        
        let realm = try! Realm()
        
        self.listOfTheme.forEach { (theme) in
            realm.delete(theme)
        }
        
        newListOfTheme.forEach { (theme) in
            
            try! realm.write{
                realm.add(theme)
            }
            
        }
        
    }
    
    func addThemeSettingView() {
        
        
        themeView = ThemeSettingView.instanceFromNib()
        themeView.frame = (self.navigationController?.view.bounds)!
        self.navigationController?.view.addSubview(themeView)
        
        themeView.frame.origin.y = themeView.frame.size.height
        themeView.imageView.kf.setImage(with: themeSelected.imageUrl)
        
        themeView.cancelTapHandler = { [weak self] in
            
            if let strongSelf = self {
                strongSelf.dismissViewFromWindow(strongSelf.themeView)
            }
            
        }
        
        themeView.confirmTapHandler = { [weak self] in
            
            if let strongSelf = self {
                strongSelf.dismissViewFromWindow(strongSelf.themeView)
                strongSelf.styleSelectedHandler?(strongSelf.themeSelected)
                strongSelf.collectionView.reloadData()
            }
            
        }
        
    }
    
    var statusBarIsHidden = false
    
    fileprivate func dismissViewFromWindow(_ view:UIView) {
        
        statusBarIsHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
        //UIApplication.sharedApplication().statusBarHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            
            view.frame.origin.y = view.frame.size.height
            view.setNeedsLayout()
            
            
        }) 
  
    }
    
    fileprivate func showViewOutOfWindow(_ view:UIView) {
        //UIApplication.sharedApplication().statusBarHidden = true
        statusBarIsHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        UIView.animate(withDuration: 0.5, animations: {
            
            view.frame.origin.y = 0
            view.setNeedsLayout()
            
        }) 
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DDPPTStyleViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return listOfTheme.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DDPPTStyleCell
        
        let url = listOfTheme[indexPath.row].imageUrl
        cell.imageView.kf.setImage(with: url)
       
        if url == themeSelected.imageUrl {
            
            cell.innerView.alpha = 1.0
            
        }
        else {
            cell.innerView.alpha = 0.0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        themeSelected = listOfTheme[indexPath.row]
        
        themeView.imageView.kf.setImage(with: themeSelected.imageUrl)
        self.showViewOutOfWindow(themeView)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        //let threePiecesWidth = floor(screenWidth / 2.0 - ((2.0 / 3) * 1))
        let threePiecesWidth = floor((screenWidth - 4.0*2)/3)
        
        return CGSize(width: threePiecesWidth, height: threePiecesWidth * (1.6))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    
}


class DDPPTStyleCell:UICollectionViewCell {
    var imageView = UIImageView()
    var innerView = UIImageView()
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = self.bounds
        innerView.frame = self.bounds
        
        innerView.image = UIImage(named: "pptStyleInner")
        innerView.alpha = 0.0
        addSubview(imageView)
        addSubview(innerView)
    }
}

