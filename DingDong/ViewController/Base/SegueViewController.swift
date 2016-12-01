//
//  SegueViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/4/21.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class SegueViewController: UIViewController {

    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        if let navigationController = navigationController {
            guard navigationController.topViewController == self else {
                return
            }
        }
        
        super.performSegue(withIdentifier: identifier, sender: sender)
    }

}
