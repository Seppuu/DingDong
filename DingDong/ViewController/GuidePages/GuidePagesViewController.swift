//
//  GuidePagesViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/7/1.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import EAIntroView

class GuidePagesViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setIntroPage()
    }
    
    func setIntroPage() {
        
        let page1 = EAIntroPage()
        page1.title = "Hello world"
        page1.desc = "sampleDescription1"
        
        let page2 = EAIntroPage()
        page2.title = "Hello world"
        page2.desc = "sampleDescription1"
        
        let page3 = EAIntroPage()
        page3.title = "Hello world"
        page3.desc = "sampleDescription1"
        
        let introView = EAIntroView(frame: view.bounds, andPages: [page1,page2,page3])
        
        introView?.show(in: view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func skip() {
        
        startMainView()
    }
    
    func startMainView() {
        
        
    }
}
