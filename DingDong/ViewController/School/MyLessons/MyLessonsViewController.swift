//
//  DDMyAlbumViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/3/13.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import PageMenu

let releasedVCTap = "releasedVCTap"
let UnreleasedVCTap = "UnreleasedVCTap"
let AlbumCellTap = "AlbumCellTap"

class MyLessonsViewController: BaseViewController,CAPSPageMenuDelegate {

    var pageMenu : CAPSPageMenu?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        
        let controller1 = UIStoryboard(name: "MyLessons", bundle: nil).instantiateViewController(withIdentifier: "LessonsReleasedVC") as!
        LessonsReleasedViewController
        
        controller1.parentNavigationController = self.navigationController
        controller1.title = "已发布"
        controllerArray.append(controller1)
        
        let controller2 = UIStoryboard(name: "MyLessons", bundle: nil).instantiateViewController(withIdentifier: "LessonsUnreleasedVC") as! LessonsUnreleasedViewController
        controller2.title = "待发布"
        controller2.parentNavigationController = self.navigationController
        controllerArray.append(controller2)
        
        
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
        
        addNoti()
        
    }

    
    func addNoti() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyLessonsViewController.goToPlay(_:)), name: NSNotification.Name(rawValue: releasedVCTap), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyLessonsViewController.goToEdit(_:)), name: NSNotification.Name(rawValue: UnreleasedVCTap), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(MyLessonsViewController.goWorksView(_:)), name: NSNotification.Name(rawValue: AlbumCellTap), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: releasedVCTap), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UnreleasedVCTap), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AlbumCellTap), object: nil)
    }
    
    func goToPlay(_ notification: Notification) {
        let lesson = notification.object as! Lesson
        self.performSegue(withIdentifier: "GoToPlayingLesson", sender: lesson)
    }
    
    func goToEdit(_ notification: Notification) {
        let lesson = notification.object as! Lesson
        self.performSegue(withIdentifier: "goToLesson", sender: lesson)
    }
    
    func goWorksView(_ notification: Notification) {
        let album = notification.object as! Album
        self.performSegue(withIdentifier: "WorksViewSegue", sender: album)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GoToPlayingLesson" {
            
            let newVC = segue.destination as! PlayingLessonViewController
            newVC.lesson = sender as! Lesson //传递专辑Data
            
        }
        else if segue.identifier == "goToLesson" {
            
            let newVC = segue.destination as! DDThemeBoardViewController
            newVC.lesson = sender as? Lesson
            
            
        }
        else if segue.identifier == "WorksViewSegue" {
            
            let newVC = segue.destination as! WorksViewController
            
            newVC.isUserSelf = true
            
            newVC.albumID = ((sender as? Album)?.id)!
            newVC.albumName = ((sender as? Album)?.title)!
            
        }
        
        
    }
    
    

}

