//
//  DDPlayingLessonViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/3/14.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import MonkeyKing
import RealmSwift

class PlayingLessonViewController: BaseViewController {

    var lagrgeCollectinView: UICollectionView?
    var imageWidth : CGFloat = 0.0
    var ImagePadding : CGFloat = 0.0
    var ImageDataSource = [UIImage]()
    
    var currentPageIndex:Int = 0
    var lesson = Lesson()
    
    var lessonID = ""
    
    var authorID = ""
    
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var topView: UIView!
    
    var timeLabel = UILabel()
    
    @IBOutlet weak var rightTopView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorImageView: UIImageView!
    
    var isAuthorSelfPlaying = true
    
    var statusBarIsHidden:Bool = false
    
    var authorAvatarURl = ""
    
    var liked = false
    
    var currentPage = Page() {
        didSet {
            currentPage.createTextView()
        }
    }
    var playAudioControl: DDPlayAudioControl!

    var imagesAttachView = DDImagesAttachmentView()
    
    var shareURLString:String?
    
    var hud = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLessonInfoFromServer()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appDelegate.lessonID = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTopView() {
        
        //set middle
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textAlignment = .center
        timeLabel.textColor = UIColor.gray
        topView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(topView)
            make.height.equalTo(21)
        }
        
        
        //set author image
        rightTopView.backgroundColor = UIColor.clear
        
        let url = URL(string: self.authorAvatarURl)
        authorImageView.kf.setImage(with: url!)
        authorImageView.backgroundColor = UIColor.red
        authorImageView.contentMode = .scaleAspectFill
        authorImageView.isUserInteractionEnabled = true
        authorImageView.layer.cornerRadius = authorImageView.ddWidth/2
        authorImageView.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayingLessonViewController.authorAvatarTap))
        authorImageView.addGestureRecognizer(tap)
        
        setPopView()
        
        setTimView()
        
    }
    
    fileprivate func setPopView() {
        
        popTip.edgeMargin = 5
        popTip.offset = 20
        popTip.actionDelayIn = 4
        popTip.edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        popTip.padding = 0.0
        popTip.borderColor = UIColor.red
        popTip.entranceAnimation = .custom
        
        popTip.entranceAnimationHandler = { [weak self] (completion) in
            
            self?.popTip.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
                self?.blackOverlay.alpha = 1.0
                self?.popTip.transform = CGAffineTransform.identity
                }, completion: nil)
        }
        popTip.actionAnimation = .none
        
        popTip.dismissHandler = {
            
        }
    }
    
    var blackOverlay = UIControl()
    
    func setTimView() {
        let inView = UIApplication.shared.keyWindow!
        self.blackOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blackOverlay.frame = inView.bounds
        
        self.blackOverlay.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        self.blackOverlay.alpha = 0
        
        inView.addSubview(self.blackOverlay)
        self.blackOverlay.addTarget(self, action: #selector(PlayingLessonViewController.blackOverlayTap), for: .touchUpInside)
        
    }
    
    func blackOverlayTap() {
        
        popTip.hide()
        self.blackOverlay.alpha = 0
    }
    
    let popTip = AMPopTip()
    
    func authorAvatarTap () {
        
        let aView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        aView.tag = 100
        aView.delegate = self
        aView.dataSource = self
        aView.separatorInset = UIEdgeInsets.zero
        let nib = UINib(nibName: "SingleTapCell", bundle: nil)
        aView.register(nib, forCellReuseIdentifier: "SingleTapCell")
        
        aView.layer.cornerRadius = 4.0
        aView.layer.masksToBounds = true
        
        popTip.popoverColor = UIColor.white
        
        if let view = rightBarItem.value(forKey: "view") as? UIView {
            
            popTip.showCustomView(aView, direction: .down, in: UIApplication.shared.keyWindow!, fromFrame: view.frame)
            
        }
    }
    
    func getLessonInfoFromServer() {
        
        NetworkManager.sharedManager.getLessonInfo(with: lessonID) { (success, data,error) in
            
            if success == true {
                
                //get autohr id 
                self.authorID = data!["author"]["id"].string!
                
                self.lesson =  JsonManager.sharedManager.makeLessonObject(with: data!)
                
                self.getShareURL(nil)
                
                self.titleLabel.text = self.lesson.name
                
                self.authorAvatarURl = data!["author"]["avator"].string!
                
                self.currentPage = self.lesson.pages[self.currentPageIndex]
                
                let likedStatus = data!["info"]["liked"].int!
                
                if likedStatus == 0 {
                    self.liked = false
                }
                else {
                    self.liked = true
                }
                
                self.setTopView()
                
                self.setCollectionView()
                
                self.setTextView()
                
                self.setImageAttachView()
                
                self.setPlayAudioControl()
                
            }
            
        }
        
    }
    
    func setTextView() {
        
        for textView in currentPage.ddTextViews {
            
            textView.state = .userPlaying
            view.addSubview(textView)
            if textView.animeIndex != 0 {
                textView.alpha = 0.0
            }
            
            textView.sizeToFit()
        }
        
    }
    
    func setImageAttachView() {
        
        imagesAttachView.frame = self.view.frame
        imagesAttachView.dataFromServer = true
        view.addSubview(imagesAttachView)
        
        self.imagesAttachView.alpha = 0.0
        imagesAttachView.photos = lesson.pages[currentPageIndex].recordPhotos
    }
    
    
    func setPlayAudioControl() {
        
        playAudioControl = DDPlayAudioControl.instanceFromNib()
        view.addSubview(playAudioControl)
        playAudioControl.snp.makeConstraints { (make) -> Void in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(64)
        }
        
        var remoteAudioURLs:[String] = [String]()
        
        lesson.pages.forEach { (page) in
            remoteAudioURLs.append(page.remoteAudioURL)
            
        }
        playAudioControl.remoteAduioURLs = remoteAudioURLs
        
        playAudioControl.duration = lesson.duration
        
        playAudioControl.hasLiked = self.liked
        playAudioControl.needShowAnime = true
        
        self.timeLabel.text = "0:00" + "/" + lesson.duration
        playAudioControlHanlers()
        
    }
    
    func playAudioControlHanlers() {
        
        playAudioControl.audioPlayBeginHandler = { [weak self] in
            
            self?.lagrgeCollectinView?.isScrollEnabled = false
            //self?.hud.hideAnimated(true)
            //如果没有动画显示的,默认一直出现.
            for textView in (self?.lesson.pages[(self?.currentPageIndex)!].ddTextViews)! {
                
                if textView.animeIndex != 0 {
                    textView.alpha = 0.0
                }
            }
            
        }
        
        playAudioControl.audioPlayLoadingHandler = { [weak self] in
            
            self?.hud = MBProgressHUD.showAdded(to: (self?.view)!, animated: true)
            self?.hud.mode = .indeterminate
            
        }
        
        playAudioControl.audioPlayPauseHandler = { 
            
           
        }
        
        playAudioControl.audioPlayPlaying =  { [weak self] (timeText) in
            
            self?.hud.hide(animated: true)
            
            self?.timeLabel.text = timeText
            
            self?.launchPlayQueue()
            
        }
        
        playAudioControl.audioPlayDidFinished = { [weak self] in
            
            //self?.lagrgeCollectinView?.scrollEnabled = true
            
            self?.playNextOrStop()
            
        }
        
        playAudioControl.shareButtonTap = { [weak self] in
            
            if self?.shareURLString == nil {
                self?.getShareURL({ (success) in
                    if success {
                        self?.shareToWeChat(with: (self?.shareURLString)!)
                    }
                    else {
                        //TODO:if failed
                    }
                })
            }
            else {
                self?.shareToWeChat(with: (self?.shareURLString)!)
            }
            
        }
        
        
        playAudioControl.likeButtonTap = { [weak self] in
            
            //点赞
            self?.likeLesson()
            
        }
        
        playAudioControl.unLikeButtonTap = { [weak self] in
            
            //取消点赞
            self?.unLikeLesson()
            
        }
        
    }
    
    func getShareURL(_ completion:((_ success:Bool)->())?) {
        
        let id = self.lesson.id.toInt()!
        NetworkManager.sharedManager.getLessonShareInfo(with:id , completion: { (success, json,error) in
            
            if success {
                
                let urlString = json!["webUrl"].string!
                 self.shareURLString = urlString
                completion?(true)
            }
            else {
                //TODO:if falied do something
            }
            
        })
    }
    
    func sunscribeAuthor() {
        
        if isAuthorSelfPlaying {
            authorSelfTap()
            return
        }
        
        NetworkManager.sharedManager.subscribeAuthor(with: authorID) { (success,_,_) in
            
            if success {
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .text
                hud.label.text = "已订阅该老师"
                
                hud.hide(animated: true, afterDelay: 1.2)
            }
        }
        
    }
    
    func cancelSunscribeAuthor() {
        
        if isAuthorSelfPlaying {
            authorSelfTap()
            return
        }
        
        NetworkManager.sharedManager.cancelSubscribeAuthor(with: authorID) { (success,_,_) in
            if success {
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .text
                hud.label.text = "取消订阅"
                
                hud.hide(animated: true, afterDelay: 1.2)
            }
        }
        
    }
    
    func authorSelfTap() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.label.text = "无法订阅自己"
        
        hud.hide(animated: true, afterDelay: 1.2)
    }
    
    func likeLesson() {
        
        NetworkManager.sharedManager.saveLessonLikedwith(lessonID) { (success,_,_) in
            
            if success {
                
                self.playAudioControl.hasLiked = true
                self.liked = true
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .text
                hud.label.text = "已经收藏"
                
                hud.hide(animated: true, afterDelay: 1.2)
            }
        }
    }
    
    func unLikeLesson() {
        NetworkManager.sharedManager.cancelSaveLessonLikedwith(lessonID) { (success,_,_) in
            if success {
                self.playAudioControl.hasLiked = false
                self.liked = false
                
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .text
                hud.label.text = "取消收藏"
                
                hud.hide(animated: true, afterDelay: 1.2)
            }
        }
    }
    
    
    func playNextOrStop() {
        
        if currentPageIndex == lesson.pages.count - 1 {
            
            //Over
            playOver()
        }
        else {
            
            //Next
            currentPageIndex += 1
            let previousIndex = currentPageIndex - 1
            playNext(currentPageIndex, previousCurrentPage: previousIndex)
        }
        
    }
    
    func playOver() {
        
        DispatchQueue.main.async{
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .text
            hud.label.text = "播放结束"
            
            hud.hide(animated: true, afterDelay: 2.0)
            
            //TODO:Back to first page
            self.backToFirst()
            
        }
        
    }
    
    func playNext(_ nextIndex:Int,previousCurrentPage:Int) {
        
        //move to next cell
        updateTextViewAndPhotos(previousCurrentPage, currentPage: nextIndex)
        
        let indexPath = IndexPath(item: nextIndex, section: 0)
        
        lagrgeCollectinView?.scrollToItem(at: indexPath, at: .right, animated: true)
        
        playAudioControl.playNextAuio()
        
    }
    
    func backToFirst() {
        
        //move to next cell
        let previousIndex = currentPageIndex
        
        currentPageIndex = 0
        
        updateTextViewAndPhotos(previousIndex, currentPage: currentPageIndex)
        
        let indexPath = IndexPath(item: 0, section: 0)
        
        lagrgeCollectinView?.scrollToItem(at: indexPath, at: .right, animated: true)
        
        playAudioControl.resetPlay()
        
    }
    
    func shareToWeChat(with shareURL:String) {
        
        let urlString = shareURL
        let title = self.lesson.name
        
        let shareURL = URL(string: urlString)!
        
        //图片换成logo.
        let info = MonkeyKing.Info(
            title: title,
            description: title,
            thumbnail: UIImage(named: "DingDonglogo"),
            media: .url(shareURL)
        )
        
        let sessionMessage = MonkeyKing.Message.weChat(.session(info: info))
        
        let weChatSessionActivity = WeChatActivity(
            type: .Session,
            message: sessionMessage) { (result) in
            
            print(result)
        }
        
        //let timelineMessage = MonkeyKing.Message.WeChat(.Timeline(info: info))
        
        let activityViewController = UIActivityViewController(activityItems: [shareURL,title,UIImage(named: "DingDonglogo")!], applicationActivities: [weChatSessionActivity])
       
        activityViewController.excludedActivityTypes = [
        
            UIActivityType.addToReadingList,
            UIActivityType.assignToContact,
            UIActivityType.print,
            UIActivityType.copyToPasteboard,
            UIActivityType.airDrop,
            UIActivityType.postToFacebook,
            UIActivityType.postToTwitter,
            UIActivityType.mail,
            UIActivityType.message,
            UIActivityType.openInIBooks,
        ]
        
        DispatchQueue.main.async { [weak self] in
            self?.present(activityViewController, animated: true, completion: nil)
        }

    }
    
    func updateTextViewAndPhotos(_ previousCurrentPage:Int,currentPage:Int) {
        
        for textView in self.currentPage.ddTextViews {
            textView.removeFromSuperview()
        }
        
        self.playAudioControl.closeAudioPlay()
        
        self.currentPage = self.lesson.pages[currentPageIndex]
        
        for textView in self.currentPage.ddTextViews {
            
            view.addSubview(textView)
            if textView.animeIndex != 0 {
                textView.alpha = 0.0
            }
            
            textView.state = .userPlaying
            textView.sizeToFit()
            
        }
        
        self.imagesAttachView.collectionView.reloadData()
    }
    
    func setCollectionView() {
        
        imageWidth = self.view.bounds.size.width
        ImagePadding = 10
        
        let lagrgeLayout = UICollectionViewFlowLayout()
        lagrgeLayout.scrollDirection = .horizontal

        lagrgeCollectinView = UICollectionView(frame: CGRect(x: 0,y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), collectionViewLayout: lagrgeLayout)
        self.view.addSubview(lagrgeCollectinView!)
        lagrgeCollectinView!.showsHorizontalScrollIndicator = false
        lagrgeCollectinView!.delegate = self
        lagrgeCollectinView!.dataSource = self
        lagrgeCollectinView!.isPagingEnabled = true
        lagrgeCollectinView!.isScrollEnabled = true

        lagrgeCollectinView!.backgroundColor = UIColor.white
        
        lagrgeCollectinView!.register(photoCell.self, forCellWithReuseIdentifier: "cell")

        lagrgeCollectinView!.isScrollEnabled = false
        
        lagrgeCollectinView!.reloadData()
        
        
    }



}

extension PlayingLessonViewController {
    
    //MARK: 播放队列.每0.25秒检测一次
    func launchPlayQueue() {

        currentPage.playQueue.forEach { [unowned self] (p) in
            
            //print(ddAudioPlayTimelyObserver)
            guard p.time == ddAudioPlayTimelyObserver else { return }
            //匹配成功
            print("时间戳\(p.time),动作是\(p.launchType.action)")
            
            switch p.launchType {
                
            case .defaultMode:       break
            case .showText:      self.showText(p.indexShowText.value!)    //显示 文本框
            case .openImage:     self.openImagesView()             //打开 浏览页面
            case .closeImage:    self.closeImagesView()            //关闭 浏览页面
            case .moveImagePage: self.moveImage(p.indexShowImage.value!)  //图片滚动
                print("展示第\(p.indexShowImage.value!)张图片")
                
            }
            //TODO:这里需要改变已经发射吗
            //p.launched = true
        }
        
        
    }
    
    //MARK: 播放队列 时相关的方法
    func showText(_ index:Int) {
        print(index)
        let textView = self.currentPage.ddTextViews[index]
        //print("集中文本框\(index)")
        textView.alpha = 1.0
        textView.displayTextViewByTime()
    }
    
    func openImagesView() {
        hideNavBar()
        imagesAttachView.photos = currentPage.recordPhotos
        imagesAttachView.dismissButton.alpha = 0.0
        imagesAttachView.collectionView.isScrollEnabled = false
        imagesAttachView.collectionView.reloadData()
        view.bringSubview(toFront: imagesAttachView)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.imagesAttachView.alpha = 1.0
            }, completion: nil)
    }
    
    func closeImagesView() {
        
        showNavBar()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.imagesAttachView.alpha = 0.0
            }){ (success) -> Void in
            self.imagesAttachView.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
        }
        

    }
    
    
    
    func moveImage(_ index:Int) {
        self.imagesAttachView.collectionView.scrollToItem(at: IndexPath(item:index, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    
    
    func hideNavBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        statusBarIsHidden = true
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
        }) 
    }
    
    func showNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        statusBarIsHidden = false
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
        }) 
    }
    
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    override var prefersStatusBarHidden : Bool {
        return statusBarIsHidden
    }
}

extension PlayingLessonViewController:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    //MARK: UICollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lesson.pages.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! photoCell
        
        cell.backgroundColor = UIColor.white
        let backImageView = UIImageView(frame: cell.bounds)
        let url = lesson.theme.imageUrl
        backImageView.kf.setImage(with: url)
        backImageView.contentMode = .scaleToFill
        cell.contentView.addSubview(backImageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    //MARK:UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
       // let onePieceWidth = floor(screenWidth)
        
        return CGSize(width: screenWidth, height: screenHeight)
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}

extension PlayingLessonViewController:UITableViewDelegate,UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleTapCell", for: indexPath) as! SingleTapCell
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.middleLabel.font = UIFont.systemFont(ofSize: 16)
        if (indexPath.row == 0){
            cell.middleLabel.text = "订阅"
        }
        else {
            cell.middleLabel.text = "取消订阅"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if (indexPath.row == 0) {
            //订阅
            self.sunscribeAuthor()
            self.popTip.hide()
            blackOverlay.alpha = 0.0
            
        }
        else {
            //取消订阅
            self.cancelSunscribeAuthor()
            popTip.hide()
            blackOverlay.alpha = 0.0
        }
    }
    
    
    
}

