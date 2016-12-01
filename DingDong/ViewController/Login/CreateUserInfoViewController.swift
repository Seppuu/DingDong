//
//  CreateUserInfoViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/4/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import Proposer
import IQKeyboardManagerSwift

class CreateUserInfoViewController: UIViewController {

    @IBOutlet weak var topBackView: UIView!
    
    @IBOutlet weak var avatarView: UIImageView!
    
    @IBOutlet weak var lastNameTextField: BorderTextField!
    
    @IBOutlet weak var firstNameTextField: BorderTextField!
    
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    var hasAvatar = false {
        didSet {
            if hasAvatar == true {
                addPhotoLabel.alpha = 0.0
                
            }
            else {
                addPhotoLabel.alpha = 1.0
            }
        }
    }
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    
    fileprivate lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title:"下一步", style: .plain, target: self, action: #selector(CreateUserInfoViewController.next(_:)))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = nextButton
        
        setNavBar()
        
        setAvatarView()
        
    }

    
    func setAvatarView() {
        
        let width = avatarView.frame.size.width
        
        
        avatarView.layer.cornerRadius = width/2
        avatarView.layer.masksToBounds = true
        avatarView.backgroundColor = UIColor.white
        avatarView.layer.borderColor = UIColor ( red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0 ).cgColor
        avatarView.layer.borderWidth = 1.0
        
        addPhotoLabel.textColor =  UIColor ( red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0 )
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateUserInfoViewController.avatarTap))
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(tap)
        
        
    }
    
    func next(_ sender:UIBarButtonItem) {
        
        guard lastNameTextField.text != "" && firstNameTextField.text != ""  else {
            
            DDAlert.alert(title: "提示", message: "请输入完整姓名", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            
            return
        }
        
        guard hasAvatar == true else {
            
            DDAlert.alert(title: "提示", message: "请添加头像", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return
        }
        
        let currentUser = User.currentUser()
        let imageData = UIImageJPEGRepresentation(self.avatarView.image!, 0.1)
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        
        currentUser?.saveUserInfoInBack(with: firstNameTextField.text!, lastName:lastNameTextField.text!, avatar:imageData ) { [weak self] (success,_,error) in
            
            if success {
                hud.hide(animated: true)
                currentUser?.firstName = (self?.firstNameTextField.text!)!
                currentUser?.lastName  = (self?.lastNameTextField.text!)!
                
                //设置姓名成功,进入主页面
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    
                    appDelegate.startMainStory()
                }
            }
            else {
                
                hud.mode = .text
                hud.label.text = error
                hud.hide(animated: true, afterDelay: 1.2)
                
            }
            
        }
        
    }
    
    func setNavBar() {
        self.navigationController?.navigationBar.hideBottomHairline()
        
        let toolBar = UIToolbar()
        toolBar.frame = topBackView.bounds
        topBackView.addSubview(toolBar)
        topBackView.layer.shadowColor = UIColor ( red: 0.698, green: 0.698, blue: 0.698, alpha: 1.0 ).cgColor
        topBackView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        topBackView.layer.shadowRadius = 0.5
        topBackView.layer.shadowOpacity = 1
        
        lastNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CreateUserInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc fileprivate func avatarTap() {
        
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
        avatarView.image = image
        hasAvatar = true
        
    }
}
