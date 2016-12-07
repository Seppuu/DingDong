//
//  NetworkManager.swift
//  DingDong
//
//  Created by Seppuu on 16/6/3.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift


enum  VerifyCodeType: String{
    
    case sms = "sms"
    case voice = "voice"
    
}

///网络请求基本回调
typealias DDResultHandler = (_ success:Bool,_ json:JSON?,_ error:String?) -> Void

public typealias JSONDictionary = [String: Any]


class NetworkManager {
    
    static var sharedManager = NetworkManager()
    
    var baseDict: JSONDictionary = [
        "token":Defaults.userToken.value!,
        "ssid" :Defaults.userSSID.value!
    ]
    
    //MARK:用户
    //发送验证码
    func requestVerifyCodeWith(_ type:VerifyCodeType,phone:String,completion:@escaping DDResultHandler) {
        
        let dict: JSONDictionary = [
            "token":Defaults.userToken.value!,
            "mobile":phone,
            "type":type.rawValue
        ]
        
        let newDict = addSignTo(dict)
        
        let urlString = sendSmsCodeURL
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
        
    }
    
    //验证验证码,成功后保存ssid
    func verifySmsCode(with mobile:String,smsCode:String,completion:@escaping DDResultHandler) {
        
        let dict: JSONDictionary = [
            "token":Defaults.userToken.value!,
            "mobile":mobile,
            "code":smsCode
        ]
        
        let newDict = addSignTo(dict)
        
        let urlString = verifySmsCodeURL
        
        Alamofire.request(urlString, method: .post, parameters: newDict)
                .responseJSON { (response) in
                    switch response.result {
                    case .success:
                        let json = JSON(response.result.value!)
                        if json["status"].int! == 1 {
                            let data = json["dataInfo"]
                            let ssid = json["ssid"].string!
                            Defaults.userSSID.value = ssid
                            completion(true,data,nil)
                            
                        }
                        else {
                            let msg = self.getErrorMsgFrom(json)
                            completion(false,nil,msg)
                        }
                        
                    case .failure(let error):
                        completion(false,nil,error.localizedDescription)
                    }
        }
    }
    
    //登出
    func userLogOut(_ completion:@escaping DDResultHandler) {
        
        let newDict = generatePostDictWithBaseDictOr(nil)
        let urlString = logOutURL
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
    }
    
    //完善用户信息
    func updateUserInfo(with firstName:String,lastName:String,avatarData:Data?,completion:@escaping DDResultHandler) {
        
        let dict = [
            "first_name":firstName,
            "last_name" :lastName
        ]
        
        let newDict = generatePostDictWithBaseDictOr(dict as JSONDictionary?)
        
        let urlString = updateUserInfoURL
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            //json dict
            for (key, value) in newDict {
                if let str = value as? String {
                    multipartFormData.append(str.data(using: String.Encoding.utf8)!, withName: key)
                }
                
                
            }
            
            //add iamge data if need
            if avatarData != nil {
                multipartFormData.append(avatarData!, withName: "avator", fileName: "avator.jpg", mimeType: "image/jpg")
                
                
            }
            
            
        }, to: urlString) { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _ ):
                
                upload.responseJSON(completionHandler: { (response) in
                    
                    let json = JSON(response.result.value!)
                    
                    if json["status"].int == 1 {
                        let dataInfo = json["dataInfo"]
                        completion(true, dataInfo,nil)
                    }
                    else {
                        let msg = self.getErrorMsgFrom(json)
                        completion(false, nil,msg)
                    }
                    
                })
                
                
            case .failure(_):
//                print("Failure")
//                print(encodingError)
                completion(false, nil,"请求失败")
            }
            
        }
        
    }
    
    //个人认证 提交审核
    func submitPersonalCertificate(_ completion:@escaping DDResultHandler) {
        
        let urlString = personalCertificateSubmitURL
        
        let newDict = generatePostDictWithBaseDictOr(nil)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
        
    }
    
    //获取审核状态
    func getPersonalCertificateStatus(_ completion:@escaping DDResultHandler) {
        
        let urlString = personalCertificateStatusURL
        
        let newDict = generatePostDictWithBaseDictOr(nil)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
        
    }
    
    //MARK:课程管理
    
    //专辑创建
    func createAlbum(_ dict:JSONDictionary,coverImage:UIImage,completion:@escaping ((_ success:Bool,_ data:JSON)->())) {
        
        
        let newDict = addSignTo(dict)
        
        let urlString = CreateAlbumURL

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            //json dict
            for (key, value) in newDict {
                let str = String(describing: value)
                multipartFormData.append(str.data(using: String.Encoding.utf8)!, withName: key)
                
            }
            
            //add iamge data
            if let imageData = UIImagePNGRepresentation(coverImage) {
                multipartFormData.append(imageData, withName: "cover", fileName: "cover.png", mimeType: "image/png")
            }
            
            
        }, to: urlString) { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _ ):
                
                upload.responseJSON(completionHandler: { (response) in
                    
                    let json = JSON(response.result.value!)
                    
                    if json["status"].int == 1 {
                        completion(true,json)
                    }
                    else {
                        completion(false,json)
                    }
                    
                })
                
                
            case .failure(_): break
//                print("Failure")
//                print(encodingError)
            }
            
        }
    }
    
    
    func getMyAlbumList(_ completion:@escaping DDResultHandler){
        
        let urlString = MyAlbumListURL
        
        let newDict = addSignTo(baseDict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
    }
    
    
    func getOneAlbumLessonListwith(_ isUserSelf:Bool,albumID:Int,completion:@escaping DDResultHandler) {
        
        if isUserSelf {
            //获取我的某张专辑中的课程列表
            requestAlbumLessonListWith(MyAlbumLessonsListURL, albumId: albumID, completion: completion)
        }
        else {
            //获取其他老师某张专辑中的课程列表
            requestAlbumLessonListWith(SomeAlbumCourseListURL, albumId: albumID, completion: completion)
        }
        
    }
    
    func requestAlbumLessonListWith(_ urlString:String,albumId:Int,completion:@escaping DDResultHandler) {
        
        let urlString = urlString
        
        let dict: JSONDictionary = [
            "album_id":albumId as AnyObject
        ]
        
        let newDict = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
        
    }
}


// 课程课件Json上传,下载.
extension NetworkManager {
    
    /**
     上传录制的课程
     
     - parameter dict:       基本json数据结构,最重要的key是时间戳
     - parameter imageDict:  图片集本体 以及 key name
     - parameter audioDict:  音频本体   以及 key name
     - parameter progress:   上传进程回调
     - parameter completion: 完成回调
     */
    func uploadLesson(_ dict:JSONDictionary,imageDict:JSONDictionary?,audioDict:JSONDictionary,progress:@escaping ((_ progress:Float)->()),completion:@escaping ((_ success:Bool)->())) {
  
        //json 序列化,加入dict.
        let paramsJSON = JSON(dict)
        guard  let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: .prettyPrinted) else {return}
        
        let fullDict:JSONDictionary = [
            "data"  :paramsString
        ]
        
        let newDict = generatePostDictWithBaseDictOr(fullDict)
        
        let urlString = uploadLessonURL
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            //json dict
            for (key, value) in newDict {
                let str = String(describing: value)
                multipartFormData.append(str.data(using: String.Encoding.utf8)!, withName: key)
                
            }
            
            for (key,value) in audioDict {
                
                    if let data = value as? Data {
                        multipartFormData.append(data, withName: key, fileName: "record0.mp3", mimeType: "audio/mp3")
                
                    }
                
                
            }
            
            if let imagedict = imageDict {
                for (key,value) in imagedict {
                    if let data = value as? Data {
                        //print("Size of Image(bytes):\(data.length)")
                        multipartFormData.append(data, withName: key, fileName: "\(key).jpg", mimeType: "image/jpg")
                        
                    }


                }
            }
            

            }, to: urlString) { (encodingResult) in
                
                switch encodingResult {
                case .success(let upload, _, _ ):
                    
                    upload.uploadProgress(closure: { (pro) in
                        DispatchQueue.main.async {
                            
                            print("上传进度: \(pro.fractionCompleted)")
                            let p = Float(pro.fractionCompleted)
                            progress(p)
                            
                        }
                    })
                    
                    upload.responseJSON(completionHandler: { (response) in
                        
                        switch response.result {
                        case .success:
                            let json = JSON(response.result.value!)
                            let status = json["status"].int!
                            //print(json)
                            if status == 1 {
                                completion(true)
                            }
                            else {
                                completion(false)
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                            completion(false)
                        }
                        
                    })
                    
                    
                case .failure(_):
//                    print("Failure")
//                    print(encodingError)
                    completion(false)
                }
                
        }
        
        

        
    }
    
    /**
     获取某课程的数据
     
     - parameter lessonId:   课程ID
     - parameter completion: 回调
     */
    func getLessonInfo(with lessonId:String,completion:@escaping DDResultHandler) {
        
        let urlString = getLessonURL
        
        let dict: JSONDictionary = [
            "id"   :lessonId as AnyObject
        ]
        
        //带有签名的dict
        let dictSigned = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: dictSigned, completion: completion)
    }
    
    //获取微信分享的地址.
    func getLessonShareInfo(with lessonID:Int, completion:@escaping DDResultHandler) {
        
        let urlString = LessonShareURL
        
        let dict: JSONDictionary = [
            "course_id" :lessonID as AnyObject
        ]
        
        let newDict = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
    }
    
    
}

//订阅，老师
extension NetworkManager {
    
    //订阅
    func subscribeAuthor(with id:String,completion:@escaping DDResultHandler) {
        
        let urlString = SubscribeAuthorURL
        
        let dict:JSONDictionary = [
            "author_id":id as AnyObject
        ]
        
        let newDict = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
        
    }
    
    
    //取消订阅
    func cancelSubscribeAuthor(with id:String,completion:@escaping DDResultHandler) {
        
        let urlString = CancelSubscribeAuthorURL
        
        let dict:JSONDictionary = [
            "author_id":id as AnyObject
        ]
        
        let newDict = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
    }
    
    //获取订阅老师列表
    func subscribedAuthorList(_ completion:@escaping DDResultHandler) {
        
        let urlString = SubscribedAuthorListURL
        
        let newDict = generatePostDictWithBaseDictOr(nil)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
    }
    
    //获取订阅老师的专辑列表
    func getAuthorAlbumListWith(_ authorID:Int,completion:@escaping DDResultHandler){
        
        let urlString = AuthorAlbumListURL
        
        let dict: JSONDictionary = [
            "author_id":authorID as AnyObject
        ]
        
        let newDict = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
        
    }
    
}

//点赞,取消点赞
extension NetworkManager {
    
    //点赞
    func saveLessonLikedwith(_ lessonId:String,completion:@escaping DDResultHandler) {
        
        let urlString = SaveLessonLikedURL
        
        let dict:JSONDictionary = [
            "course_id":lessonId as AnyObject
        ]
        
        let newDict = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
        
    }
    
    
    //取消点赞
    func cancelSaveLessonLikedwith(_ lessonId:String,completion:@escaping DDResultHandler) {
        
        let urlString = CancelSaveLessonLikedURL
        
        let dict:JSONDictionary = [
            "course_id":lessonId as AnyObject
        ]
        
        let newDict = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
    }
    
}

//MARK:课程展示列表(推荐,订阅,历史记录..)
extension NetworkManager {
    
    //获取首页推荐
    func getLessonListFromStaffPickWith(_ pageNumber:Int,pageSize:Int,completion:@escaping DDResultHandler) {
        
        let urlString = recommandlessonListURL
        
        requestForLessonListWith(urlString, pageNumber: pageNumber, pageSize: pageSize, completion: completion)
    }
    
    //获取历史记录
    func getHistoryLessonListWith(_ pageNumber:Int,pageSize:Int,completion:@escaping DDResultHandler) {
        
        let urlString = historyRecordListURL
        
        requestForLessonListWith(urlString, pageNumber: pageNumber, pageSize: pageSize, completion: completion)
    }
    
    //获取订阅老师的课程列表
    func getSubscribeLessonListWith(_ pageNumber:Int,pageSize:Int,completion:@escaping DDResultHandler) {
        
        let urlString = SubscribeLessonList
        
        requestForLessonListWith(urlString, pageNumber: pageNumber, pageSize: pageSize, completion: completion)
    }
    
    //获取点赞课程列表(默认当前用户,可查询其他用户)
    func getLikedLessonListWith(_ pageNumber:Int,pageSize:Int,completion:@escaping DDResultHandler) {
        
        let urlString = GetLessonLikedListURL
        
        requestForLessonListWith(urlString, pageNumber: pageNumber, pageSize: pageSize, completion: completion)
    }
    
    fileprivate func requestForLessonListWith(_ urlString:String,pageNumber:Int,pageSize:Int,completion:@escaping DDResultHandler) {
    
        let dict: JSONDictionary = [
            "pageNumber":pageNumber as AnyObject,
            "pageSize"  :pageSize as AnyObject
        ]

        let newDict = generatePostDictWithBaseDictOr(dict)
        
        baseRequestWith(urlString, dict: newDict, completion: completion)
    }
    
}


extension NetworkManager {
    
    
    //获取主题库
    func getThemes(_ completion:@escaping DDResultHandler) {
        
        let urlString = GetThemesURL
        
        let dict = generatePostDictWithBaseDictOr(nil)
        
        baseRequestWith(urlString, dict: dict, completion: completion)
    }
    
}

//MARK:系统管理
extension NetworkManager {
    
    //发送反馈
    func submitFeedback(with content:String, completion:@escaping DDResultHandler) {
        
        let urlString = submitFeedBackURL
        let jsonDict:JSONDictionary = [
            "content":content as AnyObject
        ]
        let dict = generatePostDictWithBaseDictOr(jsonDict)

        baseRequestWith(urlString, dict: dict, completion: completion)
    }
}


//MAKR:基本请求方法
extension NetworkManager {
    
    fileprivate func addSignTo( _ dict:JSONDictionary) -> JSONDictionary {
        
        let keys = dict.keys
        
        let sortedKeys = keys.sorted { (value1, value2) -> Bool in
            return value1 < value2
        }
        
        var parameter = ""
        
        for key in sortedKeys {
            parameter += key + "\(dict[key]!)"
        }
        
        let md5 = parameter.md5
        
        var newDict = dict
        
        newDict["sign"] = md5
        
        return newDict
    }
    
    fileprivate func getErrorMsgFrom(_ json:JSON) -> String {
        var msg = ""
        msg = json["errorInfo"]["message"].string!
        
        return msg
    }
    
    //生成post参数.
    fileprivate func generatePostDictWithBaseDictOr(_ dict:JSONDictionary?) -> JSONDictionary {
        
        var d = JSONDictionary()
        
        for (key,value) in baseDict {
            
            d[key] = value
            
        }
        if dict != nil {
            
            for (key,value) in dict! {
                
                d[key] = value
                
            }
        }
        else {
            //不需要其他参数了.
        }
        
        
        return addSignTo(d)
        
    }
    //REQUEST
    //基本请求,返回 status dataInfo errorMsg
    fileprivate func baseRequestWith(_ urlString:String,dict:JSONDictionary,completion:@escaping DDResultHandler) {
        
        let parameters:Parameters = dict
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    if json["status"].int! == 1 {
                        let dataInfo = json["dataInfo"]
                        completion(true,dataInfo,nil)
                        
                    }
                    else {
                        let msg = self.getErrorMsgFrom(json)
                        completion(false, nil, msg)
                    }
                case .failure(let error):
                    completion(false, nil, error.localizedDescription)
                    
                }
        }
    }
    
    
    //UPLOAD
    
}


