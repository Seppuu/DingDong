//
//  leftSideViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/2/17.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import Proposer
import Kingfisher

let HistoryNoti = "HistoryNoti"
let LessonsLikedNoti = "LessonsLikedNoti"
let FeedBackNoti = "FeedBackNoti"

let CertificateNoti = "CertificateNoti"

let UserAvatarUpdatedNoti = "UserAvatarUpdatedNoti"

class LeftSideViewController: BaseViewController {

    @IBOutlet weak var userTableView: UITableView!
    
    fileprivate let AddUserAvatarCell = "UserAvatarCell"
    
    fileprivate let UserAvatarEditCellId = "UserAvatarEditCell"
    
    fileprivate let logOutCellId = "SingleTapCell"
    
    fileprivate var editUserInfo = false
    
    fileprivate var uploadingAvatar = false
    
    let section1 = ["认证"]
    let section2 = ["学习记录","赞过的课程"]
    let section3 = ["反馈","设置"]
    
    fileprivate var imageUploading = UIImage()
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        
    }
    
    func setTableView() {
        
        userTableView.delegate = self
        userTableView.dataSource = self
       
        
        userTableView.register(UINib(nibName: AddUserAvatarCell, bundle: nil), forCellReuseIdentifier: AddUserAvatarCell)
        
        userTableView.register(UINib(nibName: UserAvatarEditCellId, bundle: nil), forCellReuseIdentifier: UserAvatarEditCellId)
        
        
        userTableView.register(UINib(nibName: logOutCellId, bundle: nil), forCellReuseIdentifier: logOutCellId)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ViewHistory" {
            
        }
        else if segue.identifier == "LessonsLiked" {
            
        }
        
    }

}

extension LeftSideViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return section1.count
        }
        else if section == 2 {
            return section2.count
        }
        else if section == 3 {
            return section3.count
        }
        else {
            if editUserInfo == true {
                return 1
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 98
        }
        else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            //用户信息,编辑,展示切换
            let user = User.currentUser()
            
            let cell = tableView.dequeueReusableCell(withIdentifier: AddUserAvatarCell) as! UserAvatarCell
            
            cell.nameLabel.text = (user?.lastName)! + (user?.firstName)!
            cell.levelTextLabel.text = user?.levelText
            
            if uploadingAvatar {
                
                cell.complete()
                cell.dimView.alpha = 0.3
                cell.hudView.alpha = 1.0
                cell.avatarView.image = imageUploading
                cell.hudView.startAnimating()
                
            }
            
            if !self.uploadingAvatar {
                cell.dimView.alpha = 0.0
                cell.hudView.alpha = 0.0
                cell.hudView.stopAnimating()
                let url = URL(string: (user?.avatarURL)!)!
                cell.avatarView.kf.setImage(with: url)
            }
            
            cell.avatarTapHandler = { (cell) in
                self.avatarTap()
            }
            
            cell.editTapHandler =  { [weak self] in
                cell.firstNameField.text = user?.lastName
                cell.secondNameField.text = user?.firstName
                
                self?.insertLogOutCell()
                
            }
            
            cell.cancelTapHandler = { [weak self] in
                self?.removeLogOutCell()
            }
            
            cell.confirmTapHandler = { (firstName,secondName) in
                cell.nameLabel.text = firstName + secondName
                let currentFirstName = user?.lastName
                let currentSecondName = user?.firstName
                if currentFirstName == firstName &&
                    currentSecondName == secondName {
                    
                    return
                }
                
                user?.saveUserInfoInBack(with: secondName, lastName: firstName, avatar: nil, completion: { (success) in
                    
                })
                
                
            }
            
            cell.nameNoneHandler = {
                
                DDAlert.alert(title: "提示", message: "请输入完整姓名", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            }
            
            
            

            return cell
                
        }
        else if indexPath.section == 1 {
            //认证
            let cellID = "cellIDs1"
            let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
            
            cell.textLabel?.text = section1[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
            
        else if indexPath.section == 2 {
            let cellID = "cellIDs2"
            let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
            cell.imageView?.layer.cornerRadius = (cell.imageView?.ddWidth)!/2
            cell.imageView?.layer.masksToBounds = true
            cell.imageView?.backgroundColor = UIColor ( red: 1.0, green: 0.874, blue: 0.7309, alpha: 1.0 )
            cell.textLabel?.text = section2[indexPath.row]
            
            cell.selectionStyle = .none
            
            return cell
        }
        else if indexPath.section == 3 {
            let cellID = "cellIDs2"
            let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
            cell.imageView?.layer.cornerRadius = (cell.imageView?.ddWidth)!/2
            cell.imageView?.layer.masksToBounds = true
            cell.imageView?.backgroundColor = UIColor ( red: 1.0, green: 0.874, blue: 0.7309, alpha: 1.0 )
            cell.textLabel?.text = section3[indexPath.row]
            
            cell.selectionStyle = .none
            
            return cell
        }
        else {
            //退出
            let cell = tableView.dequeueReusableCell(withIdentifier: logOutCellId, for: indexPath) as! SingleTapCell
            
            cell.middleLabel.text = "退出"
            cell.middleLabel.textColor = UIColor.red
            
            return cell
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            //认证
            NotificationCenter.default.post(name: Notification.Name(rawValue: CertificateNoti), object: nil)
        }
        else if indexPath.section == 2 {
           if indexPath.row == 0 {
                //历史记录
                NotificationCenter.default.post(name: Notification.Name(rawValue: HistoryNoti), object: nil)
               
            }
            else if indexPath.row == 1{
                //赞过的课程
                NotificationCenter.default.post(name: Notification.Name(rawValue: LessonsLikedNoti), object: nil)
            
            }
        }
        else if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                //反馈
                NotificationCenter.default.post(name: Notification.Name(rawValue: FeedBackNoti), object: nil)
            }
            
        }
        else if indexPath.section == 4 {
            
            if indexPath.row == 0 {
                //退出
                userLogOut()
            }
            
        }
    }
    
    
    fileprivate func insertLogOutCell() {
        
        self.editUserInfo = true
        
        let indexPath = IndexPath(row: 0, section: 4)
        
        
        userTableView.insertRows(at: [indexPath], with: .fade)
    }
    
    fileprivate func removeLogOutCell() {
        
        self.editUserInfo = false
        
        let indexPath = IndexPath(row: 0, section: 4)
        
        
        userTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    fileprivate func userLogOut() {
        
        let user = User.currentUser()
        user?.logOut({ [weak self] (success,_,error) in
            if success {
                
                //show intro 
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.startIntroStory()
                
                //clean files
                cleanRealmAndCaches()
                
                cleanDingDongDocuments()
                
            }
            else {
                let hud = MBProgressHUD.showAdded(to: (self?.view)!, animated: true)
                hud.mode = .text
                hud.label.text = error
                
                hud.hide(animated: true, afterDelay: 1.5)
            }
        })

    }
    


}

extension LeftSideViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func avatarTap() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //选择照片
        let choosePhotoAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Choose Photo", comment: ""), style: .default) { action -> Void in
            
            let openCameraRoll: ProposerAction = { [weak self] in
                
                guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                    self?.alertCanNotAccessCameraRoll()
                    return
                }
                
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .photoLibrary
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }
            
            proposeToAccess(.photos, agreed: openCameraRoll, rejected: {
                self.alertCanNotAccessCameraRoll()
            })
        }
        alertController.addAction(choosePhotoAction)
        
        //拍照
        let takePhotoAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default) { action -> Void in
            
            let openCamera: ProposerAction = { [weak self] in
                
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    self?.alertCanNotOpenCamera()
                    return
                }
                
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .camera
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }
            
            proposeToAccess(.camera, agreed: openCamera, rejected: {
                self.alertCanNotOpenCamera()
            })
        }
        alertController.addAction(takePhotoAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        // touch to create (if need) for faster appear
        delay(0.2) { [weak self] in
            self?.imagePicker.hidesBarsOnTap = false
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        //save image to local and back
        self.uploadingAvatar = true
        self.imageUploading = image
        self.userTableView.reloadData()
       
        
        let imageData = UIImageJPEGRepresentation(image, 0.1)
        let user = User.currentUser()
        
        user?.saveUserInfoInBack(with: (user?.firstName)!, lastName: (user?.lastName)!, avatar: imageData) { (success,_,_) in
            
            if success {
                self.uploadingAvatar = false
                self.userTableView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserAvatarUpdatedNoti), object: nil)
            }
        }
        
    }
}
