//
//  DDConfigs.swift
//  DingDong
//
//  Created by Seppuu on 16/3/2.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import CoreLocation


let DDMakeLessonSamplesArrPlist = "samplesArr" //录音备课时存储的波形数组[[CGFloat]] name.plist

let DDShouldGoToMyAlbumWithDelay = "ddShouldGoToMyAlbumWithDelay"

let DingDongScheme = "dingdongscheme"


let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

let DDTimeNeverReach = 12000


//iFly Configs
let iFlyAppId = "56fa0f58"

//RLY Configs

let RLYServerVersion = "2013-12-26"
let RLYServerIP      = "sandboxapp.cloopen.com" //开发IP:"app.cloopen.com"
let RLYServerPort    = "8883"
let RLYAccountSid    = "8a48b55153eae511015413aa3b4640ef"
let RLYAuthToken     = "6b85213120a84367a568d4adb7df86d4"

let RLYAppID         = "8a48b55153eae511015413ab008140fd"
let RLYAppToken      = "fc458ce33dff0027f59ff987a87be6c5"


//NIM SDK 
let NIMAppKey = "581381e6c1bb53bef32c0a10babb7724"
let APNsCerName = "DingDongAPNS"


let DDBaseUrl = "http://dingdong.sosys.cn:8080"
let DefaultThemeUrl = "http://dingdong.sosys.cn:8080/themes/common/background/default.png"

///用户API(sign in 是注册意思:) )
let loginURL          = DDBaseUrl + "/user/index/rest?returnDataType=json&action=signin"

//用户登出
let logOutURL         = DDBaseUrl + "/user/index/rest?returnDataType=json&action=signout"

//完善用户资料
let updateUserInfoURL = DDBaseUrl + "/user/index/rest?returnDataType=json&action=updateUserInfo"

//发送短信验证码
let sendSmsCodeURL    = DDBaseUrl + "/user/index/rest?returnDataType=json&action=sendSmsCode"

//验证验证码
let verifySmsCodeURL  = DDBaseUrl + "/user/index/rest?returnDataType=json&action=verifySmsCode"

//个人认证(讲师),提交审核
let personalCertificateSubmitURL = DDBaseUrl + "/user/index/rest?returnDataType=json&action=submitCheckInfo"

//个人认证(讲师),获取用户审核状态
let personalCertificateStatusURL = DDBaseUrl + "/user/index/rest?returnDataType=json&action=getCheckStatus"


///课程管理API
let GetThemesURL      = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getAllTheme"

let CreateAlbumURL    = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=createAlbum"

//获取我的专辑列表
let MyAlbumListURL    = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getMyAlbumList"

//某专辑的课程列表
let MyAlbumLessonsListURL  = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getMyCourseList"

//上传课件
let uploadLessonURL   = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=uploadCourse"
//某课件数据
let getLessonURL      = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getCourseInfo"

//获取某课程分享地址
let LessonShareURL    = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getCourseShareInfo"

//订阅老师
let SubscribeAuthorURL = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=saveSubscribeAuthor"

//取消订阅
let CancelSubscribeAuthorURL = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=cancelSubscribeAuthor"

//点赞课程
let SaveLessonLikedURL = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=saveLikeCourse"

//取消点赞
let CancelSaveLessonLikedURL = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=cancelLikeCourse"

//点赞列表
let GetLessonLikedListURL = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getLikeCourseList"

//订阅老师列表
let SubscribedAuthorListURL = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getSubscribeAuthorList"

//老师专辑列表
let AuthorAlbumListURL =  DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getAuthorAlbumList"

//专辑课程列表
let SomeAlbumCourseListURL =  DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getAlbumCourseList"

//获取订阅课程列表
let SubscribeLessonList = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getSubscribeCourseList"

//推荐
let recommandlessonListURL = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getRecommandCourseList"

//侧边 历史记录
let historyRecordListURL = DDBaseUrl + "/workset/files/rest?returnDataType=json&action=getHistoryCourseList"


/// 系统管理
let submitFeedBackURL = DDBaseUrl + "/system/index/rest?returnDataType=json&action=submitFeedback"

//用户协议
let userArgeementURL = DDBaseUrl + "/user/signup/agreement"

//暂时的固定的token
let defaultToken = "94a08da1fecbb6e8b46990538c7b50b2"

class DDConfig {

    static let appGroupID: String = "group.Catch-Inc.DingDong"
    
    
    struct AudioRecord {
        static let shortestDuration: TimeInterval = 1.0
        static let longestDuration: TimeInterval = 60
    }
    
    
    class func callMeInSeconds() -> Int {
        return 60
    }
    
    struct ConversationCell {
        static let avatarSize: CGFloat = 60
    }
    
    struct ContactsCell {
        static let separatorInset = UIEdgeInsets(top: 0, left: 85, bottom: 0, right: 0)
    }
    
    
    struct ChinaSocialNetwork {
        
        struct WeChat {
            
            static let appID = "wx47766648815d0676"
            static let appKey = "b6ff0679de7b11e20ef84806f9c54749"
            
            static let sessionType = "com.Catch-Inc.DingDong.WeChat.Session"
            static let sessionTitle = NSLocalizedString("WeChat Session", comment: "")
            static let sessionImage = UIImage(named: "wechat_session")!
            
            static let timelineType = "com.Catch-Inc.DingDong.WeChat.Timeline"
            static let timelineTitle = NSLocalizedString("WeChat Timeline", comment: "")
            static let timelineImage = UIImage(named: "wechat_timeline")!
        }
    }
    
}

