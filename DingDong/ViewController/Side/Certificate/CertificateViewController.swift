//
//  CertificateViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/6/2.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class CertificateViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    let titles = ["个人认证","机构认证"]
    
    let toPersonal     = "PersonalCertificateSegue"
    let toOrganization = "OrganizationCertificateSegue"
    
    fileprivate let certificateCellId = "CertificateCell"
    
    var statusText = ""
    var hasAvator = false
    var statusValue = ""
    var hasCourse = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "认证"
        
        let nib = UINib(nibName: certificateCellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: certificateCellId)
        
        checkCertificateStatus()
    }
    
    
    func checkCertificateStatus() {
        
        NetworkManager.sharedManager.getPersonalCertificateStatus { [weak self](success, json, error) in
            
            if success {
                if let strongSelf = self {
                    
                    strongSelf.statusText  = json!["statusText"].string!
                    strongSelf.hasAvator   = json!["hasAvator"].bool!
                    strongSelf.statusValue = json!["statusValue"].string!
                    strongSelf.hasCourse   = json!["hasCourse"].bool!
                    
                    strongSelf.tableView.reloadData()
                }
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if statusValue != "" {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: certificateCellId, for: indexPath) as! CertificateCell
        
        cell.leftLabel.text = titles[indexPath.row]
        
        //"0" 为 "待审核"
        if statusValue == "0" {
            cell.rightLabel.text = ""
            cell.accessoryType = .disclosureIndicator
        }
        else {
            cell.rightLabel.text = statusText
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            //个人认证
            guard statusValue == "0" else {return}
            
            self.performSegue(withIdentifier: toPersonal, sender: nil)
        }
        else {
            //机构认证
            self.performSegue(withIdentifier: toOrganization, sender: nil)
        }
        
    }

}
