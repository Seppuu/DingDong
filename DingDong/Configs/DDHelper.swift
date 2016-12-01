//
//  DDHelper.swift
//  DingDong
//
//  Created by Seppuu on 16/4/15.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import RealmSwift

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func cleanRealmAndCaches() {
    
    // clean Realm
    
    guard let realm = try? Realm() else {
        return
    }
    
    let _ = try? realm.write {
        realm.deleteAll()
    }
    
    realm.refresh()
    
}
func cleanDingDongDocuments() {
    
    FileManager.cleanMakeLessonFiles()
    
}

func isAppAlreadyLaunchedOnce()->Bool{
    
    let defaults = UserDefaults.standard
    
    if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
        print("App already launched : \(isAppAlreadyLaunchedOnce)")
        return true
    }else{
        defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
        print("App launched first time")
        return false
    }
}


func cleanDiskCacheFolder() {
    
    let folderPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    let fileMgr = FileManager.default
    
    guard let fileArray = try? fileMgr.contentsOfDirectory(atPath: folderPath) else {
        return
    }
    
    for filename in fileArray  {
        do {
            try fileMgr.removeItem(atPath: folderPath.stringByAppendingPathComponent(filename))
        } catch {
            print(" clean error ")
        }
        
    }
}


