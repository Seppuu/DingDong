//
//  LoginByMobileViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/4/14.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import Ruler
import KeyboardMan
import IQKeyboardManagerSwift

class LoginByMobileViewController: UIViewController {

    @IBOutlet weak var topBackView: UIView!
    @IBOutlet weak var areaCodeTextField: BorderTextField!
    
    @IBOutlet weak var codeLabelBottomCons: NSLayoutConstraint!
    
    @IBOutlet weak var mobileNumberTextField: BorderTextField!
    
    @IBOutlet weak var mobileNumberTextFieldTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var codeVerifyView: UIView!
    
    fileprivate lazy var skipButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "跳过", style: .plain, target: self, action: #selector(LoginByMobileViewController.skipLogin(_:)))
        return button
    }()
    
    @IBOutlet weak var agreementLabel: UILabel!
    
    
    let keyboardMan = KeyboardMan()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        areaCodeTextField.text = TimeZone.areaCode
        areaCodeTextField.backgroundColor = UIColor.white
        
        areaCodeTextField.delegate = self
        areaCodeTextField.addTarget(self, action: #selector(LoginByMobileViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        mobileNumberTextField.placeholder = "手机号"
        mobileNumberTextField.backgroundColor = UIColor.white
        mobileNumberTextField.delegate = self
        mobileNumberTextField.addTarget(self, action: #selector(LoginByMobileViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        mobileNumberTextFieldTopConstraint.constant = Ruler.iPhoneVertical(20, 90, 90, 90).value
        
        setkeyBoardHelper()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginByMobileViewController.tryShowLoginVerifyMobile))
        codeVerifyView.addGestureRecognizer(tap)
        
        enAbleCodeVerifyView(false)
        
        //add gesture to argeement label
        agreementLabel.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(LoginByMobileViewController.argeementLabelTap))
        agreementLabel.addGestureRecognizer(tap2)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavBar()
        mobileNumberTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setNavBar() {
        self.navigationController?.navigationBar.hideBottomHairline()
        //TODO:暂时隐藏"跳过"
        //navigationItem.rightBarButtonItem = skipButton
        
        let toolBar = UIToolbar()
        toolBar.frame = topBackView.bounds
        topBackView.addSubview(toolBar)
        topBackView.layer.shadowColor = UIColor ( red: 0.698, green: 0.698, blue: 0.698, alpha: 1.0 ).cgColor
        topBackView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        topBackView.layer.shadowRadius = 0.5
        topBackView.layer.shadowOpacity = 1
        
    }
    
    func enAbleCodeVerifyView(_ bool:Bool){
        let codeLabell = codeVerifyView.viewWithTag(11) as! UILabel
        let codeArrow  = codeVerifyView.viewWithTag(12) as! UIImageView
        if bool {
            codeLabell.textColor = UIColor ( red: 0.0, green: 0.4627, blue: 1.0, alpha: 1.0 )
            codeArrow.image? = (codeArrow.image?.withRenderingMode(.alwaysTemplate))!
            codeArrow.tintColor = UIColor ( red: 0.0, green: 0.4627, blue: 1.0, alpha: 1.0 )
        }else {
            codeLabell.textColor = UIColor ( red: 0.747, green: 0.747, blue: 0.747, alpha: 1.0 )
            codeArrow.image? = (codeArrow.image?.withRenderingMode(.alwaysTemplate))!
            codeArrow.tintColor = UIColor ( red: 0.747, green: 0.747, blue: 0.747, alpha: 1.0 )
        }
    }
    
    //MARK :Action
    func argeementLabelTap() {
        
        let vc = BaseWebViewController()
        vc.webTitle  = "协议"
        vc.urlString = userArgeementURL
        
        self.navigationController?.navigationBar.showBottomHairline()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    fileprivate func adjustAreaCodeTextFieldWidth() {
        guard let text = areaCodeTextField.text else {
            return
        }
        
        let _ = text.size(attributes: areaCodeTextField.isEditing ? areaCodeTextField.typingAttributes : areaCodeTextField.defaultTextAttributes)
        

        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: { _ in
            //self.areaCodeTextFieldWidthConstraint.constant = max(width, 100)
            self.view.layoutIfNeeded()
            }, completion: { finished in
        })
    }

    
    func textFieldDidChange(_ textField: UITextField) {
        
        guard let areaCode = areaCodeTextField.text, let mobile = mobileNumberTextField.text else {
            return
        }
        
        let bool = !areaCode.isEmpty && !mobile.isEmpty
        
        if mobile.characters.count == 11 {
            enAbleCodeVerifyView(bool)
        }
        
        
        if textField == areaCodeTextField {
            adjustAreaCodeTextFieldWidth()
        }
        
        if areaCode != "86" {
            areaCodeTextField.text = "86"
        }
    }
    
    //TODO:跳过,跳过的也要注册,以便使用机器人聊天.
    func skipLogin(_ sender:UIBarButtonItem) {
        
        
        //TODO:跳过用户的注册方式是什么
        DDAlert.alert(title: "提示", message: "TODO:为了让跳过用户使用一部分聊天功能,app自动注册", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
        
//        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
//            appDelegate.startMainStory()
//        }
    }

    //验证码>>
    func tryShowLoginVerifyMobile() {
        
        guard let _ = areaCodeTextField.text, let mobile = mobileNumberTextField.text else {
            return
        }
        
        
        //检测是否是手机号码.
        if mobile.characters.count != 11  {
            
            DDAlert.alert(title: "提示", message: "请输入11位手机号码", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            
            return
        }
        
        if mobile.isPhoneNumber() == false {
            
            DDAlert.alert(title: "提示", message: "请输入正确的手机号码", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            
            return
        }
        
        NetworkManager.sharedManager.requestVerifyCodeWith(.sms, phone: mobile) { (success,_,error) in
            
            
            if success {
                
                self.showLoginVerifyMobile()
            }
            else {
                
                DDAlert.alert(title: "提示", message:error! , dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            }
            
        }

        
    }
    
    
    
    func showLoginVerifyMobile() {
        guard let areaCode = areaCodeTextField.text, let mobile = mobileNumberTextField.text else {
            return
        }
        
        self.performSegue(withIdentifier: "showLoginVerifyMobile", sender: ["mobile" : mobile, "areaCode": areaCode])
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLoginVerifyMobile" {
            
            if let info = sender as? [String: String] {
                let vc = segue.destination as! LoginVerifyMobileViewController
                
                vc.mobile = info["mobile"]
                vc.areaCode = info["areaCode"]
            }
        }
    }
}

extension LoginByMobileViewController {
    
    func setkeyBoardHelper() {
        
        
        keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            
            // print("appear \(appearPostIndex), \(keyboardHeight), \(keyboardHeightIncrement)\n")
            
            if let strongSelf = self {
                let v = keyboardHeight + 23
                strongSelf.codeLabelBottomCons.constant = Ruler.iPhoneVertical(v - 13, v, v, v).value
                
            }
        }
        
    }
}

extension LoginByMobileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == areaCodeTextField {
            adjustAreaCodeTextFieldWidth()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == areaCodeTextField {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: { _ in
                //self.areaCodeTextFieldWidthConstraint.constant = 60
                self.view.layoutIfNeeded()
                }, completion: { finished in
            })

        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let areaCode = areaCodeTextField.text, let mobile = mobileNumberTextField.text else {
            return true
        }
        
        if !areaCode.isEmpty && !mobile.isEmpty {
            //tryShowLoginVerifyMobile()
        }
        
        return true
    }
}
