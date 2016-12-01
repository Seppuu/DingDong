//
//  PersonalCertificateViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/6/2.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class PersonalCertificateViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate  {

    
    @IBOutlet weak var tableView: UITableView!
    
    let titles = ["上传头像","上传一段课程"]
    fileprivate let certificateCellId = "CertificateCell"
    fileprivate let singleTapCellId   = "SingleTapCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "个人认证"
        
        let nib = UINib(nibName: certificateCellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: certificateCellId)
        
        let nib2 = UINib(nibName: singleTapCellId, bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: singleTapCellId)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func hasAvatar() -> Bool {
        
        let user = User.currentUser()
        
        if user?.avatarURL == "" {
            return false
        }
        else {
            return true
        }
    }
    
    func hasLessonUpload() -> Bool {
        
        //TODO:获得bool来源.
        
        let bool = Defaults.hasLessonUpload.value!
        
        return bool
    }
    
    func confirmSubmit() {
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        
        NetworkManager.sharedManager.submitPersonalCertificate { (success, _, error) in
            
            if success {
                hud.hide(animated: true, afterDelay: 0.0)
            }
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: certificateCellId, for: indexPath) as! CertificateCell
            cell.leftLabel.text = titles[indexPath.row]
            
            func setRightLabel(_ showCheckMark:Bool) {
                if showCheckMark {
                    cell.accessoryType = .checkmark
                    cell.rightLabel.alpha = 0.0
                }
                else {
                    cell.accessoryType = .none
                    cell.rightLabel.alpha = 1.0
                    cell.rightLabel.text = "去上传"
                }
            }
            
            if indexPath.row == 0 {
                let show = hasAvatar()
                setRightLabel(show)
            }
            else if indexPath.row == 1 {
                let show = hasLessonUpload()
                setRightLabel(show)
            }
            
            return cell
        }
        
        else {
            //审核
            let cell = tableView.dequeueReusableCell(withIdentifier: singleTapCellId, for: indexPath) as! SingleTapCell
            
            //TODO:审核状态来源
            cell.middleLabel.text = "审核"
            cell.middleLabel.textColor = UIColor ( red: 0.0, green: 0.502, blue: 1.0, alpha: 1.0 )
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                guard hasAvatar() == false else {return}
                //TODO:上传头像
                
                
            }
            else {
                guard hasLessonUpload() == false else {return}
                //TODO:上传课程,跳转到录制界面
                performSegue(withIdentifier: "goToLesson", sender: nil)
            }
        }
        else if indexPath.section == 1 {
            //TODO:需要后台接口.
            guard hasAvatar() == true && hasLessonUpload() else {
                
                DDAlert.alert(title: "提示", message: "请先完成上传", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
                
                return
            }
            
            confirmSubmit()
            
        }
    }
    

}
