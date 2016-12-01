//
//  WelcomeViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/4/14.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.showBottomHairline()
    }
    
    @IBAction func loginStart(_ sender: UIButton) {
        
        performSegue(withIdentifier: "showLoginByMobile", sender: self)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showLoginByMobile" {
            
        }
    }

}
