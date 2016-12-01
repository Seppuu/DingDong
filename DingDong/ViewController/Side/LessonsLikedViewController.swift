//
//  HistoryViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/24.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SwiftyJSON
import DZNEmptyDataSet


class LessonsLikedViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var likedTableView: UITableView!
    
    fileprivate let historyCellId = "HistoryCell"
    
    var lessons = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "赞过的课程"
        setTableView()
        
        getFirstPageData()
        
    }
    
    func setTableView() {
        likedTableView.delegate = self
        likedTableView.dataSource = self
        
        likedTableView.register(UINib(nibName: historyCellId, bundle: nil), forCellReuseIdentifier: historyCellId)
        
        likedTableView.emptyDataSetSource = self
        likedTableView.emptyDataSetDelegate = self
        
        
        likedTableView.addInfiniteScrollingWithHandler {  [weak self] in
            
            if let strongSelf = self {
                strongSelf.footerRefresh()
            }
        }
        
    }
    
    var textDisplayedWhenNoData = ""
    
    func getFirstPageData() {
        
        getDataFromServerWith(1, pageSize: pageSize) { (success, json, error) in
            
            if success {
                if let jsonArray = json!["rows"].array {
                    
                    self.totalPageNumber = json!["totalPage"].int!
                    self.lessons = jsonArray
                    self.likedTableView.reloadData()
                }
                
            }
            else {
                self.textDisplayedWhenNoData = error!
                self.likedTableView.reloadData()
            }
            
            self.likedTableView.pullToRefreshView?.stopAnimating()
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
                    strongSelf.likedTableView.infiniteScrollingView?.stopAnimating()
                    
                    strongSelf.currentPageNumber = strongSelf.totalPageNumber
                    
                    let hud = MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
                    hud.mode = .text
                    hud.offset.y = 250.0
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
                self.likedTableView.reloadData()
            }
            
            self.likedTableView.infiniteScrollingView?.stopAnimating()
        }
    }
    
    fileprivate func getDataFromServerWith(_ pageNumer:Int,pageSize:Int,completion:@escaping (_ success:Bool,_ json:JSON?,_ error:String?) -> Void) {
        
        NetworkManager.sharedManager.getLikedLessonListWith(pageNumer, pageSize: pageSize, completion: completion)
    }
    
    
    func insertMoreDataToViewWith(_ originalCount:Int ,count:Int) {
        
        var listOfIndexpath = [IndexPath]()
        
        for i in 0..<count {
            let itemInt = originalCount + i
            let indexpath = IndexPath(item: itemInt, section: 0)
            listOfIndexpath.append(indexpath)
        }
        
        likedTableView.insertRows(at: listOfIndexpath, with: .fade)
        
    }
    
    
    
    func goToPlayWith(_ lessonID:String) {
        
        let vc = UIStoryboard(name: "PlayLesson", bundle: nil).instantiateViewController(withIdentifier: "DDPlayingLessonViewController") as! PlayingLessonViewController
        
        vc.lessonID = lessonID
        vc.isAuthorSelfPlaying = false
        
        self.navigationController!.pushViewController(vc, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    fileprivate func openSheet() {
        
        let sheet = DDPopSheetView()
        let menuView = MenuSheetView(frame: CGRect(x: 0, y: screenHeight - 132, width: screenWidth, height: 132))
        sheet.containerView = menuView
        
        sheet.show()
        
        menuView.shareTapHandler = {
            sheet.dismiss()
            //TODO:
            
        }
        
        menuView.cancelHandler = {
            sheet.dismiss()
            //TODO:
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: historyCellId) as! HistoryCell
        cell.selectionStyle = .none
        
        let json = lessons[indexPath.row]
        
        let urlString = json["cover"].string!
        let url = URL(string: urlString)
        cell.coverView.kf.setImage(with: url!)
        cell.coverView.contentMode = .scaleAspectFill
        cell.coverView.clipsToBounds = true
        cell.titleLabel.text = json["name"].string!
        cell.authorLabel.text = json["author"]["name"].string
        cell.countLabel.text = json["total"].string! + "播放"
        
        cell.timeLabel.text = json["duration"].string!
        cell.timeLabel.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3 )
        cell.timeLabel.sizeToFit()
        
        cell.menuLabel.alpha = 0.0
        cell.menuTapHandler = {
            //menu tap
            self.openSheet()
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let lessonID = lessons[indexPath.row]["course_id"].string!
        goToPlayWith(lessonID)
  
    }
}

extension LessonsLikedViewController:DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "暂无点赞记录"
        
        let attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
        
    }
    
    
}
