//
//  LoginVerifyMobileViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/4/14.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import Ruler

class LoginVerifyMobileViewController: UIViewController {

    var mobile: String!
    var areaCode: String!
    var code:String!
    
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    @IBOutlet weak var topBackView: UIView!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var verifyCodeTextField: BorderTextField!
    
    @IBOutlet weak var phoneNumberLabelTopCons: NSLayoutConstraint!
    
    fileprivate lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title:"", style: .plain, target: self, action: #selector(LoginVerifyMobileViewController.next(_:)))
        return button
    }()
    
    @IBOutlet weak var callVerifyTextLabel: UILabel!
    @IBOutlet weak var callMeLabel: UILabel!
    fileprivate lazy var callMeTimer: Timer = {
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LoginVerifyMobileViewController.tryCallMe(_:)), userInfo: nil, repeats: true)
        return timer
    }()
    
    fileprivate var callMeInSeconds = DDConfig.callMeInSeconds()//60s
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        
        navigationItem.rightBarButtonItem = nextButton
        
        phoneNumberLabel.text = "+" + areaCode + " " + mobile
        
        tipsLabel.alpha = 0.0
        
        verifyCodeTextField.placeholder = " "
        verifyCodeTextField.backgroundColor = UIColor.white
        verifyCodeTextField.delegate = self
        verifyCodeTextField.addTarget(self, action: #selector(LoginVerifyMobileViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        phoneNumberLabelTopCons.constant = Ruler.iPhoneVertical(22, 52, 52, 52).value
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        verifyCodeTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        callMeTimer.fire()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        callMeTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addUserInfo" {
            
            let _ = segue.destination as! CreateUserInfoViewController

        }
        
    }
    
    
    //MARK :Action

    func next(_ sender:UIBarButtonItem) {
        
    }
    
    func tryCallMe(_ timer:Timer){
        
        if callMeInSeconds > 1 {
            
            UIView.performWithoutAnimation {
                self.callMeLabel.text = String(self.callMeInSeconds) + "秒"
                self.callMeLabel.layoutIfNeeded()
            }
                
        } else {
            UIView.performWithoutAnimation {
                
                self.tipsLabel.alpha = 1.0
                
                self.callMeLabel.alpha = 0.0
                self.callVerifyTextLabel.alpha = 0.0
                
                self.callMeLabel.layoutIfNeeded()
            }
            
            //call code phone
            timer.invalidate()
            CallMe()
        }
        
        if (callMeInSeconds > 1) {
            callMeInSeconds -= 1
        }
        
    }
    
    func CallMe() {
        
        NetworkManager.sharedManager.requestVerifyCodeWith(.voice, phone: mobile) { (success , _ , error) in
            
            if success {
                
                
            }
            else {
                
                DDAlert.alert(title: "提示", message:error! , dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            }
            
        }
        
    }
    
    func textFieldDidChange(_ textField:UITextField) {
        
        //检测code长度,如果达到设定长度,自动检测,登录.
        if textField.text?.characters.count == 6 {
            
            tryLogin(textField.text!)

        }
    }
    
    fileprivate func tryLogin(_ smsCode:String) {
        
        verifyCodeTextField.resignFirstResponder()
        
        
        User.signUpOrLogin(with: mobile, smsCode: smsCode) {[weak self] (user, error) in
            
            if (error == nil) {
                //print("登录成功")
                
                //检测用户是否有姓名,如果没有,则是第一次注册.前往.信息页面.
                
                if (user?.firstName == "") {
                    
                    self?.performSegue(withIdentifier: "addUserInfo", sender: nil)
                    
                }
                else {
                    //是已经注册用户,进入主页面
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.startMainStory()
                    }
                }
                
            }
            else {
                //TODO:错误提示,无效的验证码之类.
                DDAlert.alert(title: "提示", message:error, dismissTitle:"OK", inViewController: self, withDismissAction: nil)
            }
        }

        
    }
    
    func filterError(_ error: NSError?) -> Bool{
        if error != nil {
            print(error)
            return false
        } else {
            return true
        }
    }
    
    
}

extension LoginVerifyMobileViewController:UITextFieldDelegate {
    
}
