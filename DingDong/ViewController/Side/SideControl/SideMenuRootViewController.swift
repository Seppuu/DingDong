//
//  SideMenuRootViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/2/17.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

let RESideMenuOpenLeftNoti = "RESideMenuOpenLeftNoti"

let RESideMenuDidOpen = "RESideMenuDidOpen"

let RESideMenuDidClose = "RESideMenuDidClose"

let RESideMenuPanRecognized = "RESideMenuPanRecognized"


class SideMenuRootViewController: RESideMenu,RESideMenuDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNoti()
        
    }

    override func awakeFromNib() {
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.lightContent
        self.contentViewShadowColor = UIColor ( red: 0.6726, green: 0.6726, blue: 0.6726, alpha: 1.0 )
        self.contentViewShadowOffset = CGSize(width: 0, height: 0)
        self.contentViewShadowOpacity = 0.4
        self.contentViewShadowRadius = 8
        self.contentViewShadowEnabled = true
        self.contentViewScaleValue = 1.0
        //let f = self.view.frame.size.width/3
        self.scaleContentView = false
        
        //当这个值设置为0时,contentViewController的x位置为screenWidth/2. 通过这个来得出一个方程.
        let centerX =  ( screenWidth / 2) - 50
        
        self.contentViewInPortraitOffsetCenterX = centerX
        
        self.delegate = self
        
        self.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "contentViewController")
        
        self.leftMenuViewController = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuViewController")
        
    }
    
    func setNoti() {
        
        let noti = NotificationCenter.default
        noti.addObserver(self, selector: #selector(SideMenuRootViewController.openLeftSide), name: NSNotification.Name(rawValue: RESideMenuOpenLeftNoti), object: nil)
        
        noti.addObserver(self, selector:#selector(SideMenuRootViewController.hideViewController), name: NSNotification.Name(rawValue: CertificateNoti), object: nil)
        
        noti.addObserver(self, selector:#selector(SideMenuRootViewController.hideViewController), name: NSNotification.Name(rawValue: HistoryNoti), object: nil)
        
        noti.addObserver(self, selector:#selector(SideMenuRootViewController.hideViewController), name: NSNotification.Name(rawValue: LessonsLikedNoti), object: nil)
        
        noti.addObserver(self, selector:#selector(SideMenuRootViewController.hideViewController), name: NSNotification.Name(rawValue: FeedBackNoti), object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: RESideMenuOpenLeftNoti), object: nil)
    }
    
    // MARK: RESide Delegate Methods
    func openLeftSide() {
        self.presentLeftMenuViewController()
    }
    
    func closeLeftSide() {
        self.hideViewController()
    }

    func sideMenu(_ sideMenu: RESideMenu!, didShowMenuViewController menuViewController: UIViewController!) {
        
        //NSNotificationCenter.defaultCenter().postNotificationName(RESideMenuDidOpen, object: nil)
        
        let animeDuration = sideMenu.animationDuration
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: RESideMenuDidOpen), object: animeDuration)
        
    }
    
    func sideMenu(_ sideMenu: RESideMenu!, didHideMenuViewController menuViewController: UIViewController!) {
        
        let animeDuration = sideMenu.animationDuration
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: RESideMenuDidClose), object: animeDuration)
    }

    
    func sideMenu(_ sideMenu: RESideMenu!, didRecognizePanGesture recognizer: UIPanGestureRecognizer!) {
        
        let point = recognizer.translation(in: sideMenu.leftMenuViewController.view)
        
        let alpha = point.x / (300 - 60)
        
        guard  alpha >= 0 || alpha <= 1.0 else {
            
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: RESideMenuPanRecognized), object: 1 - alpha)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
