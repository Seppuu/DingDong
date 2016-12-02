//
//  NSFileManager+DD.swift
//  DingDong
//
//  Created by Seppuu on 16/2/29.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import UIKit

enum FileExtension:String {
    
    case M4A = "m4a"
    case JPG = "jpg"
    
    case plist = "plist"
}

extension FileManager {
    
    /**
    返回Documents URL目录
     */
    class func ddDocsURL() -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    /**
     返回DingDong URL目录
     */
    class func ddDingDongDocsURL() -> URL? {
        let fileManager = FileManager.default
        
        let dingDongDocsURL = ddDocsURL().appendingPathComponent("DingDong", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: dingDongDocsURL, withIntermediateDirectories: true, attributes: nil)
            return dingDongDocsURL
        } catch _ {
            
        }
        
        return nil
    }
    
    /**
     返回DingDong - School URL目录
     */
    class func ddSchoolDocsURL() -> URL? {
        let fileManager = FileManager.default
        
        let schoolDocsURL = ddDingDongDocsURL()!.appendingPathComponent("School", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: schoolDocsURL, withIntermediateDirectories: true, attributes: nil)
            return schoolDocsURL
        } catch _ {
            
        }
        
        return nil
    }
    
    
    /**
     返回DingDong - School - MakeLesson URL目录
     */
    class func ddMakeLessonDocsURL() -> URL? {
        let fileManager = FileManager.default
        
        let makeLessonDocsURL = ddSchoolDocsURL()!.appendingPathComponent("MakeLesson", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: makeLessonDocsURL, withIntermediateDirectories: true, attributes: nil)
            return makeLessonDocsURL
        } catch _ {
            
        }
        
        return nil
    }
    
    /**
     返回DingDong - School - MakeLesson - Records URL目录
     */
    class func ddRecordsDocsURL() -> URL? {
        let fileManager = FileManager.default
        
        let recordsDocsURL = ddMakeLessonDocsURL()!.appendingPathComponent("Records", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: recordsDocsURL, withIntermediateDirectories: true, attributes: nil)
            return recordsDocsURL
        } catch _ {
            
        }
        
        return nil
    }
    
    /**
     返回DingDong - School - MakeLesson - Photos URL目录
     */
    class func ddPhotosDocsURL() -> URL? {
        let fileManager = FileManager.default
        
        let photosDocsURL = ddMakeLessonDocsURL()!.appendingPathComponent("Photos", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: photosDocsURL, withIntermediateDirectories: true, attributes: nil)
            return photosDocsURL
        } catch _ {
            
        }
        
        return nil
    }
    

    // MARK: Transfer
    /**
    返回DingDong - School - MakeLesson - Transfer URL目录
    */
    class func ddTransferDocsURL() -> URL? {
        
        let fileManager = FileManager.default
        
        let transferDocsURL = ddMakeLessonDocsURL()!.appendingPathComponent("Transfer", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: transferDocsURL, withIntermediateDirectories: true, attributes: nil)
            return transferDocsURL
        } catch _ {
            
        }
        
        return nil
    
    }
    
    // MARK: SamplesArry
    /**
    返回DingDong - School - MakeLesson - SamplesArry URL目录
    */
    class func ddSamplesDocsURl() -> URL? {
        let fileManager = FileManager.default
        
        let samplesArry = ddMakeLessonDocsURL()!.appendingPathComponent("SamplesArry", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: samplesArry, withIntermediateDirectories: true, attributes: nil)
            return samplesArry
        } catch _ {
            
        }
        
        return nil
    }
    
    
    
    
    
    class func ddRecordURLWithNameInTransfer(_ name:String) -> URL? {
        
        if let transferFileURL = ddTransferDocsURL() {
            return transferFileURL.appendingPathComponent("\(name).\(FileExtension.M4A.rawValue)")
        }
        
        return nil
    }
    
    
    // MARK: Lesson
    class func ddLessonFileURL(_ uuidName:String) -> URL? {
        
        let fileManager = FileManager.default
        
        let lessonFileURL = ddRecordsDocsURL()!.appendingPathComponent(uuidName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: lessonFileURL, withIntermediateDirectories: true, attributes: nil)
            return lessonFileURL
        }catch _ {
            
        }
        
        return nil
    }
    
    class func ddPlistFileURlWithName(_ name:String) -> URL? {
        
        if let samplesFileURL = ddSamplesDocsURl()  {
            
              return samplesFileURL.appendingPathComponent("\(name).\(FileExtension.plist.rawValue)")
        }
        
        return nil
    }
        

    class func ddRecordURLWithName(_ lessonURL:URL,name:String) -> URL? {

        return lessonURL.appendingPathComponent("\(name).\(FileExtension.M4A.rawValue)")
 
    }
    
    
    /**
     返回DingDong - School - MyAlbums URL目录
     */
    class func ddMyAlbumsDocsURL() -> URL? {
        let fileManager = FileManager.default
        
        let myAlbumsDocsURL = ddSchoolDocsURL()!.appendingPathComponent("MyAlbums", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: myAlbumsDocsURL, withIntermediateDirectories: true, attributes: nil)
            return myAlbumsDocsURL
        } catch _ {
            
        }
        
        return nil
    }
    
    /**
     返回DingDong - School - MyAlbums - AlbumIndex URL目录
     */
    class func ddAlbumFileURL(_ index:Int) -> URL? {
        
        let fileManager = FileManager.default
        
        let albumIndexFileURL = ddMyAlbumsDocsURL()!.appendingPathComponent("Album\(index)", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: albumIndexFileURL, withIntermediateDirectories: true, attributes: nil)
            return albumIndexFileURL
        }catch _ {
            
        }
        
        return nil
    }
    
    
    /**
     返回DingDong - School - MyAlbums - AlbumIndex - Audios URL目录
     */
    class func ddAlbumIndexAudiosFileURL(_ index:Int) -> URL? {
        
        let fileManager = FileManager.default
        
        let albumAudiosFileURL = ddAlbumFileURL(index)!.appendingPathComponent("Audios", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: albumAudiosFileURL, withIntermediateDirectories: true, attributes: nil)
            return albumAudiosFileURL
        }catch _ {
            
        }
        
        return nil
    }
    
    /**
     返回DingDong - School - MyAlbums - AlbumIndex - Images URL目录
     */
    class func ddAlbumIndexImagesFileURL(_ index:Int) -> URL? {
        
        let fileManager = FileManager.default
        
        let albumImagesFileURL = ddAlbumFileURL(index)!.appendingPathComponent("Images", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: albumImagesFileURL, withIntermediateDirectories: true, attributes: nil)
            return albumImagesFileURL
        }catch _ {
            
        }
        
        return nil
    }
    
    
    
    /**
     返回 专辑Album - Audios - 具体存储audio的名字以及路径
     */
    class func ddAlbumAudioURLWithName(_ AlbumIndex:Int,name:String) -> URL? {
        
        if let audioFileURL = ddAlbumIndexAudiosFileURL(AlbumIndex) {
            return audioFileURL.appendingPathComponent("\(name).\(FileExtension.M4A.rawValue)")
        }
        
        return nil
    }
    
    /**
     返回 专辑Album - Images - 具体存储images的名字以及路径
     */
    class func ddAlbumImagesURLWithName(_ AlbumIndex:Int,name:String) -> URL? {
        
        if let imagesFileURL = ddAlbumIndexImagesFileURL(AlbumIndex) {
            return imagesFileURL.appendingPathComponent("\(name).\(FileExtension.JPG.rawValue)")
        }
        
        return nil
    }
    
    
    // MARK: Clean Documents
    /* 
    删除Document下的文件
    */
    class func cleanDocs() {
        let fileManager = FileManager.default
        
        if let fileURLs = (try? fileManager.contentsOfDirectory(at: ddDocsURL(), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())) {
            for fileURL in fileURLs {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch _ {
                    
                }
            }
        }
    }
    /**
     document中,子目录下的文件.
     
     - parameter docsDirectoryURL: 参数是子目录
     */
    class func cleanDocsDirectoryAtURL(_ docsDirectoryURL:URL) {
        let fileManager = FileManager.default
        
        if let fileURLs = (try? fileManager.contentsOfDirectory(at: docsDirectoryURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())) {
            for fileURL in fileURLs {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch _{
                    
                }
            }
            
        }
    }
    
    
    class func cleanMakeLessonFiles() {
        if let makeLessonURl = ddMakeLessonDocsURL() {
            cleanDocsDirectoryAtURL(makeLessonURl)
        }
    }
    
    class func cleanRecordFilesWithURL(_ url:URL) {
        
            cleanDocsDirectoryAtURL(url)
    
    }
    
    class func cleanTransferFiles() {
        if let transferURL = ddTransferDocsURL() {
            cleanDocsDirectoryAtURL(transferURL)
        }
    }
    
    class func cleanSamplesArryFile() {
        if let samplesArryURL = ddSamplesDocsURl() {
            cleanDocsDirectoryAtURL(samplesArryURL)
        }
        
    }
    
    
    //MARK:Count Record of Lesson
    class func recordCountInLessonIndex(_ lessonFileURL:URL) -> Int {
        let fileManager = FileManager.default
        
        if let urls = (try? fileManager.contentsOfDirectory(at: lessonFileURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())) {
            return urls.count
        }
        
        return 0
    }
    
    
    
    
    
}
