//
//  DDShowSubTitleViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/3/29.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DDShowSubTitleViewController: BaseViewController ,UITextViewDelegate{

    var textView = UITextView()
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        title = "字幕"
        
        setTextView()
        
        setNavBar()
    }

    func setTextView() {
        
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            
            make.left.top.right.bottom.equalTo(view)
        }
        
        textView.backgroundColor = UIColor.lightText
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 22)
    }
    
    
    func setNavBar() {
        
        let leftBarItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DDShowSubTitleViewController.cancelTap))
        self.navigationItem.leftBarButtonItem = leftBarItem
        
    }
    
    
    func cancelTap() {
        
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
