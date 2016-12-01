//
//  SubscriptionViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/30.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SwiftyJSON


class SubscriptionViewController: BaseViewController,RAReorderableLayoutDelegate,RAReorderableLayoutDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var parentNavigationController : UINavigationController?
    fileprivate let StaffPicksCardCellId = "StaffPicksCardCell"
    
    fileprivate let SubscriptionTopCellId = "SubscriptionTopCell"
    
    var lessons = [JSON]()
    
    var listOfAuthor = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.addChildViewController(self)
        
        setCollectionView()
        
        getMySubscribedAuthorList()
        
        getFirstPageData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setCollectionView() {
        
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        let layout = RAReorderableLayout()
        layout.scrollDirection = .vertical
        
        let nib = UINib(nibName: StaffPicksCardCellId, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: StaffPicksCardCellId)
        
        let nib2 = UINib(nibName: SubscriptionTopCellId, bundle: nil)
        collectionView.register(nib2, forCellWithReuseIdentifier: SubscriptionTopCellId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.ddViewBackGroundColor()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
        
        collectionView.addPullToRefreshHandler { [weak self] in
            
            if let strongSelf = self {
                
                strongSelf.getFirstPageData()
            }
            
            
        }
        
        collectionView.addInfiniteScrollingWithHandler {  [weak self] in
            
            if let strongSelf = self {
                strongSelf.footerRefresh()
            }
        }

    }
    
    func getMySubscribedAuthorList() {
        
        NetworkManager.sharedManager.subscribedAuthorList { (success, json, error) in
            
            if success {
                if let jsonArr = json?.array {
                    
                    if jsonArr.count > 0 {
                        
                        self.listOfAuthor = jsonArr
                        self.collectionView.reloadData()
                    }
                    else {
                        
                        
                    }
                    
                }
            }
            else {
                // failed do something
            }
        }
    }
    

    
    var textDisplayedWhenNoData = ""
    
    func getFirstPageData() {
        currentPageNumber = 1
        getDataFromServerWith(currentPageNumber, pageSize: pageSize) { (success, json, error) in
            
            if success {
                if let jsonArray = json!["rows"].array {
                    
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
                    
                    let hud = MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
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
    
    fileprivate func getDataFromServerWith(_ pageNumer:Int,pageSize:Int,completion: @escaping (_ success:Bool,_ json:JSON?,_ error:String?) -> Void) {
        
        
        NetworkManager.sharedManager.getSubscribeLessonListWith(pageNumer, pageSize: pageSize, completion: completion)
    }
    
    
    func insertMoreDataToViewWith(_ originalCount:Int ,count:Int) {
        
        var listOfIndexpath = [IndexPath]()
        
        for i in 0..<count {
            let itemInt = originalCount + i
            let indexpath = IndexPath(item: itemInt, section: 1)
            listOfIndexpath.append(indexpath)
        }
        
        collectionView.insertItems(at: listOfIndexpath)
        
    }
    
    fileprivate func openSheet() {
        
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
    
    func goToChannelList() {
        
        let vc = UIStoryboard(name: "ChannelList", bundle: nil).instantiateViewController(withIdentifier: "ChannelListViewController") as! ChannelListViewController
        vc.listOfAuthor = listOfAuthor
        self.parentNavigationController!.pushViewController(vc, animated: true)
    }
    
    func goToChannelWith(_ authorID:String,authorName:String) {
        
        let vc = UIStoryboard(name: "Channel", bundle: nil).instantiateViewController(withIdentifier: "ChannelViewController") as! ChannelViewController
        
        vc.authorID = authorID
        vc.authorName = authorName
        
        self.parentNavigationController!.pushViewController(vc, animated: true)
        
    }
    
    func goToPlayWith(_ lessonID:String) {
        
        let vc = UIStoryboard(name: "PlayLesson", bundle: nil).instantiateViewController(withIdentifier: "DDPlayingLessonViewController") as! PlayingLessonViewController
        
        vc.lessonID = lessonID
        vc.isAuthorSelfPlaying = false
        
        self.parentNavigationController!.pushViewController(vc, animated: true)

    }
    
    // MARK: - Navigation
    
    //MARK: RAReorderableLayout delegate datasource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            let screenWidth = UIScreen.main.bounds.width
            
            let width = screenWidth
            
            let height:CGFloat = 50
            //section 1
            return CGSize(width: width, height: height)
        }
        else {
            let screenWidth = UIScreen.main.bounds.width
            
            let width = (screenWidth - (3*15) )/2
            
            let height:CGFloat = 250
            //section 1
            return CGSize(width: width, height: height)
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 20.0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
        return UIEdgeInsetsMake(20, 15, 20, 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            
            if listOfAuthor.count == 0 {
                return 0
            }
            else {
                return 1
            }
            
        }
        return lessons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SubscriptionTopCellId, for: indexPath) as! SubscriptionTopCell
            
            cell.loadDataWith(listOfAuthor)
            
            cell.arrowTapHandler = {
               
                self.goToChannelList()
               
            }
            
            cell.authorTapHandler = { (authorID,authorName) in
                
                self.goToChannelWith(authorID, authorName: authorName)
            }
            
            return cell
        }
        else {
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
        
        
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let lessonID = lessons[indexPath.row]["course_id"].string!
            goToPlayWith(lessonID)
        
        }
        
    }

}

extension SubscriptionViewController:DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "欢迎在课程观看页面进行订阅"
        
        let attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
        
    }
    
    
}



















