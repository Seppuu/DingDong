//
//  BaseViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/4/21.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if  appDelegate.lessonID != "" {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: ToPlayLessonNoti), object: appDelegate.lessonID)
            
            appDelegate.lessonID = ""
        }
    }
    
}
