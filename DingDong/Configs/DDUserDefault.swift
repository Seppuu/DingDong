//
//  DDUserDefault.swift
//  DingDong
//
//  Created by Seppuu on 16/6/3.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation



typealias Defaults = PalauDefaults
typealias Defaultable = PalauDefaultable
/// Your defaults are defined as extension of PalauDefaults
///
/// - The generic type of your PalauDefaultsEntry must conform
///   to the protocol PalauDefaultable.
/// - We provide support for the most common types.
/// - `value` is a helper function defined in PalauDefaults
/// - The String "backingName" is the key used in NSUserDefaults
/// - The empty `set` is used to please the compiler
extension PalauDefaults {
    
    
    public static var userToken: PalauDefaultsEntry<String> {
        get {
            return value("userToken").whenNil(use:defaultToken)
        }
        set {
            
        }
    }
    
    //登录的时候返回,设置
    public static var userSSID: PalauDefaultsEntry<String> {
        get {
            return value("userSSID").whenNil(use: "")
        }
        set {
            
        }
    }
    
    

    public static var hasLessonUpload: PalauDefaultsEntry<Bool> {
        get {
            return value("hasLessonUpload").whenNil(use: false)
        }
        set {
            
        }
    }
    
    public static var defaultTheme: PalauDefaultsEntry<String> {
        get {
            return value("defaultTheme").whenNil(use:DefaultThemeUrl )
        }
        set {
            
        }
    }
    
  
}
