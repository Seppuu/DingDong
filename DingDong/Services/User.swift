//
//  User.swift
//  DingDong
//
//  Created by Seppuu on 16/6/20.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation


class User {
    
    fileprivate static var sharedUser : User?
    
    class func currentUser() -> User! {
        // change class to final to prevent override
        guard let uwShared = sharedUser else {
            
            //use disk data to create a user if we can
            if let id = Defaults.userId.value {
                
                sharedUser = User()
                sharedUser!.id = id
                sharedUser!.phone = Defaults.userPhone.value!
                sharedUser!.firstName = Defaults.userFirstName.value!
                sharedUser!.lastName = Defaults.userLastName.value!
                sharedUser!.levelText = Defaults.userLevelText.value!
                sharedUser!.avatarURL = Defaults.userAvatarURL.value!
                return sharedUser!
                
            }
            else {
                return nil
            }
            
            
        }
        return uwShared
    }
    
    
    //property
    var id = "" {
        didSet {
            Defaults.userId.value = id
        }
    }
    var phone = "" {
        didSet {
            Defaults.userPhone.value = phone
        }
    }
    
    var firstName = "" {
        didSet {
            Defaults.userFirstName.value = firstName
        }
    }
    
    var lastName = "" {
        didSet {
            Defaults.userLastName.value = lastName
        }
    }
    
    var avatarURL = ""{
        didSet {
            Defaults.userAvatarURL.value = avatarURL
        }
    }
    
    var levelText = "" {
        
        didSet {
            Defaults.userLevelText.value = levelText
        }
    }
    
    
    //Action
    class func signUpOrLogin(with mobile:String,smsCode:String, completion:@escaping ((_ user:User?,_ error:String?)->())) {
        
        
        NetworkManager.sharedManager.verifySmsCode(with: mobile, smsCode: smsCode) { (success,data,error) in
            
            if success {
                if let id = data!["user_id"].string {
                    Defaults.userId.value = id
                }
                if let  phone = data!["username"].string {
                    Defaults.userPhone.value = phone
                }
                if let avatarURL = data!["avator"].string  {
                    Defaults.userAvatarURL.value = avatarURL
                }
                if let firstName = data!["first_name"].string {
                    Defaults.userFirstName.value = firstName
                }
                
                if let lastName = data!["last_name"].string {
                    Defaults.userLastName.value = lastName
                }
                
                if let levelText = data!["level_text"].string {
                    Defaults.userLevelText.value = levelText
                }
                
                let currentUser = User.currentUser()
                completion(currentUser, nil)
            }
            else {
                completion(nil, error)
            }
            
        }
        
        
        
    }
    
    
    
    func saveUserInfoInBack(with firstName:String,lastName:String,avatar:Data?,completion:@escaping DDResultHandler) {
        
        //TODO:
        NetworkManager.sharedManager.updateUserInfo(with: firstName, lastName: lastName, avatarData: avatar) { (success, json,error) in
            
            if success {
                let user = User.currentUser()
                //TODO:这里应该要获取,用户是否是认证讲师,帮助我判断认证界面.
                user?.firstName = json!["first_name"].string!
                user?.lastName  = json!["last_name"].string!
                user?.avatarURL = json!["avator"].string!
                
                completion(true,nil,nil)
            }
            else {
                completion(false,nil,nil)
            }
            
        }
        
    }
    
    func logOut(_ completion:@escaping DDResultHandler) {
        
        NetworkManager.sharedManager.userLogOut { [weak self](success,json,error) in
            
            if success {
                self?.clearUserDefaults()
                completion(true,nil,nil)
            }
            else {
                completion(false,nil,error)
            }
            
        }
        
    }
    
    fileprivate func clearUserDefaults() {
        
//        Defaults.userId.clear()
//        Defaults.userPhone.clear()
//        Defaults.userFirstName.clear()
//        Defaults.userLastName.clear()
//        Defaults.userAvatarURL.clear()
        
        if let bid = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bid)
        }
    }
    
}

extension PalauDefaults {
    
    
    public static var userId: PalauDefaultsEntry<String> {
        get {
            return value("userId")
        }
        set {
            
        }
    }
    
    public static var userPhone: PalauDefaultsEntry<String> {
        get {
            return value("userPhone").whenNil(use: "")
        }
        set {
            
        }
    }
    
    public static var userFirstName: PalauDefaultsEntry<String> {
        get {
            return value("userFirstName").whenNil(use: "")
        }
        set {
            
        }
    }
    
    public static var userLastName: PalauDefaultsEntry<String> {
        get {
            return value("userLastName").whenNil(use: "")
        }
        set {
            
        }
    }
    
    
    
    public static var userAvatarURL: PalauDefaultsEntry<String> {
        get {
            return value("userAvatarURL").whenNil(use: "")
        }
        set {
            
        }
    }
    
    public static var userLevelText: PalauDefaultsEntry<String> {
        get {
            return value("userLevelText").whenNil(use: "普通用户")
        }
        set {
            
        }
    }
    
    public static var lessonIdFromScheme: PalauDefaultsEntry<String> {
        get {
            return value("lessonIdFromScheme").whenNil(use: "")
        }
        set {
            
        }
    }
    
}
