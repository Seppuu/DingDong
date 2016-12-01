//
//  SchoolViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/2/17.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import RealmSwift
import PageMenu

let ToChannelListNoti = "ToChannelListNoti"
let ToChannelNoti     = "ToChannelNoti"
let ToPlayLessonNoti  = "ToPlayLessonNoti"


class SchoolViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource,CAPSPageMenuDelegate{

    @IBOutlet weak var rightBarItem: UIBarButtonItem!

    
    @IBOutlet weak var userAvatarItem: UIBarButtonItem!
    
    var avatarImage = UIImage()
    
    var showDot = false
    
    var pageMenu : CAPSPageMenu?
   
    let popTip = AMPopTip()
    let tintView = UIView()
    var dot = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "充电"
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        
        let controller1 = UIStoryboard(name: "StaffPicks", bundle: nil).instantiateViewController(withIdentifier: "recommendVC") as! StaffPicksViewController
        
        controller1.parentNavigationController = self.navigationController
        controller1.title = "推荐"
        controllerArray.append(controller1)
        
        let controller2 = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "classificationVC") as! CategoriesViewController
        controller2.title = "分类"
        controller2.parentNavigationController = self.navigationController
        controllerArray.append(controller2)
        
        let controller3 = UIStoryboard(name: "Subscription", bundle: nil).instantiateViewController(withIdentifier: "vipLessonVC") as! SubscriptionViewController
        controller3.title = "订阅"
        controller3.parentNavigationController = self.navigationController
        controllerArray.append(controller3)
        
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(0.0),
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .bottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .selectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .menuMargin(20.0),
            .menuHeight(40.0),
            .selectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .unselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .menuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(false),
            .selectionIndicatorHeight(2.0),
            .menuItemSeparatorPercentageHeight(0.1)
        ]
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64), pageMenuOptions: parameters)
        
        // Optional delegate
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
        
        changeBarItemTitle()
        setNotification()
        
        setPushNoti()
        
        setPopTip()
        setTimView()
        setBatItem()
        
        
        setLeftBarAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        shouldShowDot()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dot.alpha = 0.0
    }

    func shouldShowDot() {
        
        let realm = try! Realm()
        let lessonResutls = realm.objects(Lesson).filter("released == false")
        if lessonResutls.count > 0 {
            showDot = true
            dot.alpha = 1.0
        }
        else {
            showDot = false
            dot.alpha = 0.0
        }
    }
    
    fileprivate let dotWidth:CGFloat = 6
    
    func setBatItem() {
        
        let barItem = navigationItem.rightBarButtonItem
        
        guard let view = barItem?.value(forKey: "view") as? UIView else {return}
        
        dot = UIView(frame: CGRect(x: view.center.x + 5 , y: 20 + 10, width: dotWidth, height: dotWidth))
        dot.layer.cornerRadius = dotWidth/2
        dot.layer.masksToBounds = true
        dot.backgroundColor = UIColor.red
        dot.alpha = 0.0
        self.navigationController?.view.addSubview(dot)
    }
    
    func setNotification() {
        let noti = NotificationCenter.default
        noti.addObserver(self, selector: #selector(SchoolViewController.goToMyAlbum(_:)), name: NSNotification.Name(rawValue: DDShouldGoToMyAlbumWithDelay), object: nil)
        
        noti.addObserver(self, selector:#selector(SchoolViewController.showCertificate), name: NSNotification.Name(rawValue: CertificateNoti), object: nil)
        
        noti.addObserver(self, selector:#selector(SchoolViewController.showHistory), name: NSNotification.Name(rawValue: HistoryNoti), object: nil)
        
        noti.addObserver(self, selector:#selector(SchoolViewController.showLessonsLiked), name: NSNotification.Name(rawValue: LessonsLikedNoti), object: nil)
        
        noti.addObserver(self, selector:#selector(SchoolViewController.showFeedBack), name: NSNotification.Name(rawValue: FeedBackNoti), object: nil)
        
        
        noti.addObserver(self, selector:#selector(SchoolViewController.hideLeftbarItem(_:)), name: NSNotification.Name(rawValue: RESideMenuDidOpen), object: nil)
        
        noti.addObserver(self, selector:#selector(SchoolViewController.showLeftBarItem(_:)), name: NSNotification.Name(rawValue: RESideMenuDidClose), object: nil)
        
        
        noti.addObserver(self, selector:#selector(SchoolViewController.changeLeftBarItemColor(_:)), name: NSNotification.Name(rawValue: RESideMenuPanRecognized), object: nil)
        
        
        noti.addObserver(self, selector:#selector(SchoolViewController.refeshLeftBarAvatarImage), name: NSNotification.Name(rawValue: UserAvatarUpdatedNoti), object: nil)
    }
    
    
    func setPushNoti() {
        
        let noti = NotificationCenter.default
        noti.addObserver(self, selector: #selector(SchoolViewController.goToChannelList(_:)), name: NSNotification.Name(rawValue: ToChannelListNoti), object: nil)
        
        noti.addObserver(self, selector: #selector(SchoolViewController.goToChannel(_:)), name: NSNotification.Name(rawValue: ToChannelNoti), object: nil)
        
        noti.addObserver(self, selector: #selector(SchoolViewController.goToPlayLesson(_:)), name: NSNotification.Name(rawValue: ToPlayLessonNoti), object: nil)
        
    }
    
    func setLeftBarAvatar() {
        
        let user = User.currentUser()
        
        let avatarImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        avatarImageView.layer.cornerRadius = avatarImageView.ddWidth/2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.kf.setImage(with: URL(string: (user?.avatarURL)!)!)
        
        avatarImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(SchoolViewController.userAvatarTap))
        avatarImageView.addGestureRecognizer(tap)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: avatarImageView)
        
    }
    
    func refeshLeftBarAvatarImage() {
        setLeftBarAvatar()
        self.navigationItem.leftBarButtonItem?.customView?.alpha = 0.0
    }
    
    func showLeftBarItem(_ sender:Notification) {
        
        let duration = sender.object as! TimeInterval
        
        UIView.animate(withDuration: duration, animations: {
            
            self.navigationItem.leftBarButtonItem?.customView?.alpha = 1.0
        }) 
    }
    
    func hideLeftbarItem(_ sender:Notification) {
        
        let duration = sender.object as! TimeInterval
        
        UIView.animate(withDuration: duration, animations: {
            
            self.navigationItem.leftBarButtonItem?.customView?.alpha = 0
        }) 
        
    }
    
    func changeLeftBarItemColor(_ sender:Notification) {
        let alpha = sender.object as! CGFloat
        
        self.navigationItem.leftBarButtonItem?.customView?.alpha = alpha
    }
    
    func setPopTip() {
        
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
        
        popTip.dismissHandler = { [weak self] in
            self?.tintView.alpha = 0.0
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
        self.blackOverlay.addTarget(self, action: #selector(SchoolViewController.blackOverlayTap), for: .touchUpInside)
        
    }
    
    func blackOverlayTap() {
        
        popTip.hide()
        self.blackOverlay.alpha = 0
    }

    func removeNotification() {
     
        NotificationCenter.default.removeObserver(self)
    }
    
    func goToMyAlbum(_ sender:Notification) {
        
        delay(1.0) {
            
            self.performSegue(withIdentifier: "toMyAlbum", sender: self)
        }
    }
    
    func goToChannelList(_ sender:Notification) {
        
        changeBarItemTitle()
        self.performSegue(withIdentifier: "ChannelListSegue", sender: self)
    }
    
    func goToChannel(_ sender:Notification) {
        
        changeBarItemTitle()
        //TODO:传值
        self.performSegue(withIdentifier: "ChannelViewSegue", sender: self)
    }
    
    func goToPlayLesson(_ sender:Notification) {
        
        
        let lessonID = sender.object as! String
        
        let vc = UIStoryboard(name: "PlayLesson", bundle: nil).instantiateViewController(withIdentifier: "DDPlayingLessonViewController") as! PlayingLessonViewController
        
        vc.lessonID = lessonID
        vc.isAuthorSelfPlaying = false
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    

    func userAvatarTap() {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: RESideMenuOpenLeftNoti), object: nil)
    }
    
    @IBAction func addBarTapped(_ sender: UIBarButtonItem) {
        
        let aView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        aView.tag = 100
        aView.delegate = self
        aView.dataSource = self
        aView.separatorInset = UIEdgeInsets.zero
        let nib = UINib(nibName: "SingleTapCell", bundle: nil)
        aView.register(nib, forCellReuseIdentifier: "SingleTapCell")
        
        aView.layer.cornerRadius = 4.0
        aView.layer.masksToBounds = true
        
        
        let item = sender
        if let view = item.value(forKey: "view") as? UIView {
            
            popTip.popoverColor = UIColor.white
            
            popTip.showCustomView(aView, direction: .down, in: UIApplication.shared.keyWindow!, fromFrame: view.frame)
        }
        
    }
    
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
            cell.middleLabel.text = "制作课程"
        }
        else if (indexPath.row == 1){
            cell.middleLabel.text  = "我的课程"
            //检查如果有未发布的课程,显示一个圆点.
            let v = UIView(frame: CGRect(x:100 - 10, y: 15, width: dotWidth, height: dotWidth))
            cell.contentView.addSubview(v)
            v.center.y = cell.contentView.center.y
            v.backgroundColor = UIColor.red
            v.layer.cornerRadius = dotWidth/2
            v.layer.masksToBounds = true
            if showDot {
                v.alpha = 1.0
            }
            else {
                v.alpha = 0.0
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0)
        {
            popTip.hide()
            
            performSegue(withIdentifier: "goToLesson", sender: self)
        }
        else if (indexPath.row == 1) {
            
            popTip.hide()
            performSegue(withIdentifier: "toMyAlbum", sender: self)
        }
        
        blackOverlay.alpha = 0.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToLesson") {
            
        }
        else if (segue.identifier == "toMyAlbum") {
            
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SchoolViewController {
    func showHistory() {
        changeBarItemTitle()
        performSegue(withIdentifier: "ViewHistory", sender: nil)
    }
    
    func showCertificate() {
        changeBarItemTitle()
        performSegue(withIdentifier: "CertificateViewSegue", sender: nil)
    }
    
    func showLessonsLiked() {
        changeBarItemTitle()
        performSegue(withIdentifier: "LessonsLiked", sender: nil)
    }
    
    func showFeedBack() {
        changeBarItemTitle()
        performSegue(withIdentifier: "ShowFeedBack", sender: nil)
    }
    
}

