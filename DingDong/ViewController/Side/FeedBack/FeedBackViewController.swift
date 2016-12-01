//
//  FeedBackViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/29.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class FeedBackViewController: BaseViewController,UITextViewDelegate {
    
    
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var confirmButton: UIBarButtonItem!

    @IBOutlet weak var feedBackTextView: UITextView!
    
    var hud = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "反馈"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedBackViewController.topContainerTap))
        topContainer.isUserInteractionEnabled = true
        topContainer.addGestureRecognizer(tap)
        
        
    }
    
    func topContainerTap() {
        feedBackTextView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sendFeedBack(_ sender: UIBarButtonItem) {
        
        let content = feedBackTextView.text
        
        
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        self.hud.label.text = "提交中..."
        
        NetworkManager.sharedManager.submitFeedback(with: content!) { (success,_,_) in
            
            if success == true {
                self.hud.mode = .text
                self.hud.label.text = "提交成功,感谢您的意见!"
                self.hud.hide(animated: true, afterDelay: 2.5)
            }
        }
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            confirmButton.isEnabled = false
        }
        else {
            confirmButton.isEnabled = true
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

}
