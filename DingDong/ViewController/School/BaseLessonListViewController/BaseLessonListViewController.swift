//
//  BaseLessonListViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/6/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SwiftyJSON
import DZNEmptyDataSet


class BaseLessonListViewController: BaseViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var parentNavigationController : UINavigationController?
    
    fileprivate let StaffPicksCardCellId = "StaffPicksCardCell"
    
    var lessons:[JSON] =  [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionView()
        
        getFirstPageData()
    }

    func setCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let nib = UINib(nibName: StaffPicksCardCellId, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: StaffPicksCardCellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.ddViewBackGroundColor()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        collectionView.addInfiniteScrollingWithHandler {
            
            self.footerRefresh()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    var textDisplayedWhenNoData = ""
    
    func getFirstPageData() {
        
        collectionView.pullToRefreshView?.startAnimating()
        
        getDataFromServerWith(1, pageSize: pageSize) { (success, json, error) in
            
            if success {
                if let jsonArray = json!["rows"].array {
                    
                    if jsonArray.count == 0 {
                        self.textDisplayedWhenNoData = "暂无公开推荐的课程"
                    }
                    
                    self.totalPageNumber = json!["totalPage"].int!
                    self.lessons = jsonArray
                    self.collectionView.reloadData()
                }
                
            }
            else {
                self.textDisplayedWhenNoData = error!
                self.collectionView.reloadData()
            }
            
            self.collectionView.pullToRefreshView?.stopAnimating()
        }
        
    }
    
    var currentPageNumber = 1
    
    var pageSize = 15
    
    var totalPageNumber = 0
    
    func footerRefresh() {
        
        currentPageNumber += 1
        
        if currentPageNumber <= totalPageNumber {
            loadMoreDatawith(currentPageNumber, pageSize: pageSize)
        }
        else {
            //no more data
            delay(1.0, closure: {  [weak self] in
                
                if let strongSelf = self {
                    strongSelf.collectionView.infiniteScrollingView?.stopAnimating()
                    
                    strongSelf.currentPageNumber = strongSelf.totalPageNumber
                    
                    let hud = MBProgressHUD.showAdded(to: strongSelf.view.superview!, animated: true)
                    hud.mode = .text
                    hud.label.text = "没有更多内容了"
                    
                    hud.hide(animated: true, afterDelay: 1.0)
                }
                
                })
            
            
            
            
        }
        
    }
    
    //底部刷新
    func loadMoreDatawith(_ pageNumber:Int,pageSize:Int) {
        
        getDataFromServerWith(pageNumber, pageSize: pageSize) { (success, json, error) in
            
            if success {
                if let jsonArray = json!["rows"].array {
                    
                    if jsonArray.count == 0 {
                        self.textDisplayedWhenNoData = "暂无公开推荐的课程"
                    }
                    let originalCount = self.lessons.count
                    self.lessons += jsonArray
                    let insertCount = jsonArray.count
                    self.insertMoreDataToViewWith(originalCount, count: insertCount)
                    
                    print("self.currentPageNumber : \(self.currentPageNumber)")
                }
                
            }
            else {
                self.textDisplayedWhenNoData = error!
                self.collectionView.reloadData()
            }
            
            self.collectionView.infiniteScrollingView?.stopAnimating()
        }
    }
    
    //顶部刷新
    func tryGetNewData() {
        
        getFirstPageData()
    }
    
    fileprivate func getDataFromServerWith(_ pageNumer:Int,pageSize:Int,completion: @escaping DDResultHandler) {
        
        NetworkManager.sharedManager.getLessonListFromStaffPickWith(pageNumer, pageSize: pageSize, completion: completion)
    }
    
    
    func insertMoreDataToViewWith(_ originalCount:Int ,count:Int) {
        
        var listOfIndexpath = [IndexPath]()
        
        for i in 0..<count {
            let itemInt = originalCount + i
            let indexpath = IndexPath(item: itemInt, section: 0)
            listOfIndexpath.append(indexpath)
        }
        
        collectionView.insertItems(at: listOfIndexpath)
        
    }
    
    func openSheet() {
        
        let sheet = DDPopSheetView()
        let menuView = PicksSheetView(frame: CGRect(x: 0, y: screenHeight - 88, width: screenWidth, height: 88))
        sheet.containerView = menuView
        
        sheet.show()
        
        //        menuView.deleteRecordHandler = {
        //            sheet.dismiss()
        //            //TODO:
        //        }
        //
        //        menuView.shareTapHandler = {
        //            sheet.dismiss()
        //            //TODO:
        //
        //        }
        //
        //        menuView.cancelHandler = {
        //            sheet.dismiss()
        //            //TODO:
        //        }
        
    }

}

extension BaseLessonListViewController:DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = textDisplayedWhenNoData
        
        let attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
        
    }
    
    
}

extension BaseLessonListViewController {
    
    //MARK: RAReorderableLayout delegate datasource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        //let twoPiecesWidth = floor(screenWidth / 2.0 - ((2.0 / 2) * 2))
        
        let width = (screenWidth - (3*15) )/2
        
        let height:CGFloat = 250
        //section 1
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(20, 15, 0, 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return lessons.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: StaffPicksCardCellId, for: indexPath) as! StaffPicksCardCell
        
        let json = lessons[indexPath.row]
        
        let urlString = json["cover"].string!
        let url = URL(string: urlString)
        cell.coverImageView.kf.setImage(with: url!)
        cell.titleLabel.text = json["name"].string!
        cell.authorLabel.text = json["author"]["name"].string
        cell.countLabel.text = json["total"].string! + "播放"
        cell.backgroundColor = UIColor.white
        cell.menuTapHandler = {
            
            self.openSheet()
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let lessonID = lessons[indexPath.row]["course_id"].string!
        
        let vc = UIStoryboard(name: "PlayLesson", bundle: nil).instantiateViewController(withIdentifier: "DDPlayingLessonViewController") as! PlayingLessonViewController
        
        vc.lessonID = lessonID
        vc.isAuthorSelfPlaying = false
        
        self.parentNavigationController?.pushViewController(vc, animated: true)
        
    }

    
}
