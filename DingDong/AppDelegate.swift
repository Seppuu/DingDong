
//  AppDelegate.swift
//  DingDong
//
//  Created by Seppuu on 16/2/16.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import Alamofire


//LeanApp Id and Key
private let appId  = "kJuLgAcu6kdhM1K3GMHTBvq6-gzGzoHsz"
private let appKey = "i7dzPASNNLPc94Wfb76d8TLd"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var lessonID = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        checkRealmVersion()
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        
        //检查用户是否登录过.
        let currentUser = User.currentUser()
        //let currentUser = AVUser.currentUser()

        if currentUser != nil {

            startMainStory()
            
        }
        else {
            
            startIntroStory()
        }
        
    
    
        return true
    }
    
    var comeFromBack = false
    //这个方法只会在app,从后台进入前台是触发,第一次启动不会触发.
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        comeFromBack = true
    }
    
    
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        
        if url.scheme == DingDongScheme {
            
            let praramArray = url.absoluteString.chompLeft(DingDongScheme + "://").components(separatedBy: "/")
            
            //let key = praramArray[0] //lesson
            lessonID = praramArray[1] //lessonID
            
            if (comeFromBack == true) {
                //应用从后台进入,发送通知,结束之后,将lessonID,归零.
                NotificationCenter.default.post(name: Notification.Name(rawValue: ToPlayLessonNoti), object: lessonID)
                
                //在进入播放界面之后,重置lessonID.
            }

            return true
        }
        
        return false
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        
        
    }
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    
    //Mark:RemoteNotifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
    }
    
    
    func checkRealmVersion() {
        // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
        Realm.Configuration.defaultConfiguration = RealmConfig
        
        // 现在我们已经告诉了 Realm 如何处理架构的变化，打开文件之后将会自动执行迁移
        let _ = try! Realm()
    }
    
    // MARK: Public
    func startGuidePage()  {
        
        let guidePages = GuidePagesViewController()
        
        window?.rootViewController = guidePages
    }
    
    
    func startIntroStory() {
        
        let storyboard = UIStoryboard(name: "Intro", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "IntroNavigationController") as! UINavigationController
        
        window?.rootViewController = rootViewController
    }
    
    func startMainStory() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "SideMenuRootViewController") as! SideMenuRootViewController
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = rootViewController


    }
    
    //设置讯飞SDK
    func setiFlySDK() {
//        //设置sdk的log等级，log保存在下面设置的工作路径中
//        IFlySetting.setLogFile(.LVL_ALL)
//        
//        //打开输出在console的log开关
//        IFlySetting.showLogcat(false) //暂时关闭日志输出
//        
//        //设置sdk的工作路径
//        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
//        
//        let cachePath = paths[0]
//        IFlySetting.setLogFilePath(cachePath)
//        
//        //创建语音配置,appid必须要传入，仅执行一次则可
//        let initString = "appid=" + iFlyAppId
//        
//        //所有服务启动前，需要确保执行createUtility
//        IFlySpeechUtility.createUtility(initString)
    }

}

