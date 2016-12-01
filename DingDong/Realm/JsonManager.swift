//
//  JsonManager.swift
//  DingDong
//
//  Created by Seppuu on 16/6/6.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftyJSON

class JsonManager: NSObject {
    
    static var sharedManager = JsonManager()
    
    //turn realm object to post json
    func getWholeLessonDict(with lesson:Lesson) -> (JSONDictionary,JSONDictionary?,JSONDictionary)  {
        
        return (
            getJsonDict(with: lesson),
            getImageDict(with: lesson),
            getAudioDict(with: lesson)
        )
 
    }
    
    fileprivate func getJsonDict(with lesson:Lesson) -> JSONDictionary {
        
        let screen = [
            "width":screenWidth,
            "height":screenHeight]
        
        let info: JSONDictionary = [
            "album_id":"\(lesson.album!.id)" as AnyObject,
            "duration":lesson.duration as AnyObject,
            "name"    :lesson.name as AnyObject,
            "theme"   :lesson.theme.nameValue as AnyObject
        
        ]
        
        var pagesDict = [JSONDictionary]()
        for page in lesson.pages {
            let dict = getPageDictArray(with: page)
            pagesDict.append(dict)
        }
        
        let jsonDict: JSONDictionary = [
            "screen":screen,
            "info"  :info,
            "data"  :pagesDict,
        ]
        
        return jsonDict
    }
    
    fileprivate func getImageDict(with lesson:Lesson) -> JSONDictionary? {
        var dict: JSONDictionary = JSONDictionary()
        
        for page in lesson.pages {
            
            let pageIndex = lesson.pages.index(of: page)!
            
            for photo in page.recordPhotos {
                
                let imageIndex = page.recordPhotos.index(of: photo)!
                
                let key = "image-\(pageIndex)-\(imageIndex)"
                
                let data = photo.imageData
                print("image\(imageIndex)size:\(data.count)")
                dict[key] = data
            }
            
            
        }
        
        if dict.keys.count == 0 {
            return nil
        }
        else {
            return dict
        }
        
    }
    
    fileprivate func getAudioDict(with lesson:Lesson) -> JSONDictionary {
        var dict: JSONDictionary =  JSONDictionary()
        
        for page in lesson.pages {
            let pageIndex = lesson.pages.index(of: page)!
            let key = "audio-\(pageIndex)"
            
            let data = NSData(contentsOf: page.audioURLWithName)!
            
            dict[key] = data
        }
        
        return dict
    }
    
    
    fileprivate func getPageDictArray(with page:Page) -> JSONDictionary {
        
        
        //TODO: content : text anime
        var dicts = [JSONDictionary]()
        
        for timeStamp in page.playQueue {
            var dict = JSONDictionary()
            switch timeStamp.action {
            case "text":
                
                let textView = page.textViews[timeStamp.indexShowText.value!]
                
                //根据ios的情况加上几个参数
                let textPosition = [
                    "x":textView.xPercent * Float(screenWidth),
                    "y":textView.yPercent * Float(screenHeight),
                    
                    "xRatio":textView.xPercent,
                    "yRatio":textView.yPercent,
                    "widthRatio":textView.widthPercent,
                    "heightRatio":textView.heightPercent,
                    
                ]
                
                dict = [
                    "time"    :timeStamp.time,
                    "action"  :timeStamp.action,
                    "position":textPosition,
                    "content" :textView.text,
                    "color"   :textView.colorHex,
                    "fontsize":textView.fontSize,
                    "animate" :textView.animeBackName,
                    "duration":0.5,
                    
                    "viewIndex" :textView.viewIndex,
                    "animeIndex":textView.anime
                ]
            case "openImage":
                dict = [
                    "time"    :timeStamp.time,
                    "action"  :timeStamp.action,
                    
                    "content" :"",
                    "animate" :"",
                    "duration":0
                ]
                case "image":
                    dict = [
                        "time"    :timeStamp.time,
                        "action"  :timeStamp.action,
                        
                        "content" :timeStamp.indexShowImage.value!,
                        "animate" :"slide-left",
                        "duration":1
                ]
            case "closeImage":
                dict = [
                    "time"    :timeStamp.time,
                    "action"  :timeStamp.action,
                    
                    "content" :"",
                    "animate" :"",
                    "duration":0
                ]
                
            default:break;

            }
            
            dicts.append(dict)
            
        }
        
        return ["timeline":dicts as AnyObject]
    }
    
    
    
    //generate album list dict to user 
    func saveAlbumListInRealm(with jsons:[JSON]) -> [Album] {
        
        let realm = try! Realm()
        
        //delelte old data
        try! realm.write {
            let result = realm.objects(Album)
            realm.delete(result)
        }
        
        for json in jsons {
            let album = Album()
            album.id    = json["album_id"].string!.toInt()!
            album.title = json["name"].string!
            album.intro = json["description"].string!
            album.type  = json["category"].string!.toInt()!
            album.coverUrl = json["cover"].string!
            album.permissionType = json["privacy"].string!.toInt()!
            
            try! realm.write {
                realm.add(album)
            }
            
        }
        
        
        let result = realm.objects(Album.self)
        
        return Array(result)
    }
    
    func makeLessonObject(with data:JSON) -> Lesson {
        
        let lesson = Lesson()
        
        lesson.id = data["info"]["id"].string!
        lesson.name = data["info"]["name"].string!
        lesson.duration = data["info"]["duration"].string!
        
        let theme = Theme()
        theme.nameValue = data["info"]["theme"].string!
        theme.imageURLString = data["data"][0]["resources"]["background"].string!
        
        lesson.theme = theme
        
        let pagesData = data["data"].array!
        
        for pageData in pagesData {
            let page = makePage(with: pageData)
            lesson.pages.append(page)
        }
        
        return lesson
    }
    
    fileprivate func makePage(with data:JSON) -> Page {
        
        let page = Page()
        
        //音频地址
        page.remoteAudioURL = data["resources"]["audio"].string!
        
        //设置图片对象,如果有
        if let imagesetDict = data["resources"]["imageset"].dictionary {
            
            let sortedKeys = Array(imagesetDict.keys).sorted(by: { (key1, key2) -> Bool in
               return key1 < key2
            })
            
            for key in sortedKeys {
                
                let picture = Picture()
                picture.imageURL = imagesetDict[key]!["content"].string!
                
                page.recordPhotos.append(picture)
            }
            
        }

        
        //设置文本框对象,如果有.
        if let timeStampsData = data["timeline"].array {
            
            let textViews = makeTextView(with: timeStampsData)
            page.textViews = textViews
        }
        
        
        //时间戳对象集合,如果有
        if let timeStampsData = data["timeline"].array {
            
            let playQueue = makePlayQueue(with: timeStampsData)
            page.playQueue = playQueue
        }
        
        return page
    }
    
    fileprivate func makeTextView(with data:[JSON]) -> List<TextViewModel> {
        
        let textViews = List<TextViewModel>()
        
        for content in data {
            
            switch content["action"].string! {
                case "text":
                let textView = TextViewModel()
                
                textView.xPercent = content["position"]["xRatio"].float!
                textView.yPercent = content["position"]["yRatio"].float!
                textView.widthPercent = content["position"]["widthRatio"].float!
                textView.heightPercent = content["position"]["heightRatio"].float!
                
                
                textView.text = content["content"].string!
                textView.showTime = content["time"].float!
                textView.colorHex = content["color"].string!
                textView.fontSize = CGFloat(content["fontsize"].int!)
                textView.viewIndex = content["viewIndex"].int!
                textView.anime = content["animeIndex"].int!
                textViews.append(textView)
            default: break;
            
            }
            
        }
        
        return textViews
    }
    
    fileprivate func makePlayQueue(with data:[JSON]) -> List<TimeStamp> {
        
        let playQueue = List<TimeStamp>()
        
        for content in data {
            
            let timeStamp = TimeStamp()
            
            timeStamp.time = content["time"].float!
            
            switch content["action"].string! {
            case "openImage"  : timeStamp.launchTypeInt = 2
                
            case "image"  : timeStamp.launchTypeInt = 4 ; timeStamp.indexShowImage.value = content["content"].int!
                
            case "closeImage" : timeStamp.launchTypeInt = 3
                
            case "text"       : timeStamp.launchTypeInt = 1 ; timeStamp.indexShowText.value = content["viewIndex"].int!
                
            default: timeStamp.launchTypeInt = 0
                break;
            }
            
            playQueue.append(timeStamp)
        }
        
        return playQueue
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
