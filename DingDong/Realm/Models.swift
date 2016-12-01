//
//  Models.swift
//  DingDong
//
//  Created by Seppuu on 16/3/12.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import Foundation
import RealmSwift
import Photos



// TODO:总是在这个队列里使用 Realm
//let realmQueue = dispatch_queue_create("com.Yep.realmQueue", DISPATCH_QUEUE_SERIAL)

//let realmQueue =     DispatchQueue(label: , attributes: DispatchQoS(_FIXME_useThisWhenCreatingTheQueueAndRemoveFromThisCall: DispatchQueue.Attributes(), qosClass: DispatchQoS.QoSClass.utility, relativePriority: 0))


    
    
/// 录音录制时的同步计时
var ddRecordTimelyObserver:Float = 0
/// 录音播放时的同步计时
var ddAudioPlayTimelyObserver:Float = 0


enum  PermissionType: Int{
    case indoor = 0
    case outdoor
    
}

enum AlbumType: Int {
    case first = 0
    case second
    case third
    case forth
    case fifth
    case sixth
    case seventh
}

class Album: Object {
    
    dynamic var id = 0
    
    dynamic var title = ""
    
    dynamic var type  = AlbumType.first.rawValue
    
    dynamic var intro = ""
    
    dynamic var permissionType = PermissionType.outdoor.rawValue //默认外部权限
    
    dynamic var coverUrl = ""
    
    fileprivate dynamic var imageData: Data = Data()
    
    var image: UIImage {
        
        get {
            if let image = UIImage(data: imageData) {
                return image
            }
            
            return UIImage()
        }
        
        set {
            
            self.imageData = UIImageJPEGRepresentation(newValue, 1.0)!
            
            
        }
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["image"]
    }
    
}

///课程表
class Lesson: Object {
    
    dynamic var id = UUID().uuidString
    
    dynamic var created: Date = Date()
    
    dynamic var name = ""
    
    dynamic var released = false
    
    dynamic var duration = ""
    
    dynamic var imageData: Data = Data()
    
    dynamic var album: Album? = nil
    
    var pages = List<Page>()
    
    //非持久化属性
    //社会化分享的内容地址.
    var shareURL = ""
    
    //反向链接.返回Album集合,一般只有一个元素在里面.
    //let albums = LinkingObjects(fromType: Album.self, property: "lessons")
    
    var theme = Theme()
    
    var image: UIImage {
        
        get {
            if let image = UIImage(data: imageData) {
                return image
            }
            
            return UIImage()
        }
        
        set {
            
            self.imageData = UIImageJPEGRepresentation(newValue, 1.0)!
            
        }
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["theme","image"]
    }
    
    //联级删除关联对象
    func cascadingDeleteInRealm(_ realm:Realm) {
        
        pages.forEach {
            $0.cascadingDeleteInRealm(realm)
        }
        
        realm.delete(pages)
        realm.delete(self)
    }
    
}

///课程页面表
class Page: Object {
    
    dynamic var id = UUID().uuidString
    dynamic var duration = "00:00"
    
    var samples = List<sampleModel>()
    var textViews = List<TextViewModel>()
    var recordPhotos = List<Picture>() //案例图片
    var playQueue = List<TimeStamp>() //播放队列
    
    
    //非持久化属性
    var remoteAudioURL = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var ddTextViews =  [DDTextView]()
    
    //TODO:Text文本框,向textViewModel中转数据
    func saveTextData() {
        let realm = try! Realm()
        
        let tViews =  List<TextViewModel>()
        for textview in ddTextViews {
            let textViewModel = TextViewModel()
            textViewModel.xPercent = Float(textview.frame.origin.x / screenWidth)
            textViewModel.yPercent = Float(textview.frame.origin.y / screenHeight)
            textViewModel.widthPercent = Float(textview.frame.size.width / screenWidth)
            textViewModel.heightPercent = Float(textview.frame.size.height / screenHeight)
            
            textViewModel.showTime = textview.showTime.time
            textViewModel.text = textview.text
            textViewModel.hasShowTime = textview.hasShowTime
            textViewModel.editable = textview.isEditable
            textViewModel.viewIndex = textview.viewIndex
            textViewModel.moveDisable = textview.moveDisable
            
            textViewModel.anime = textview.animeIndex
            textViewModel.colorHex = textview.color.rawValue
            textViewModel.fontSize = textview.fontSize.rawValue
        
            tViews.append(textViewModel)
        }
        
        try! realm.write {
            self.textViews.removeAll()
            self.textViews.append(objectsIn: tViews)
        }
        
    }
    
    func createTextView() {
        
        var ddTVS = [DDTextView]()
        for textViewModel in textViews {
            let x      = CGFloat(textViewModel.xPercent) * screenWidth
            let y      = CGFloat(textViewModel.yPercent) * screenHeight
            let width  = CGFloat(textViewModel.widthPercent) * screenWidth
            let height = CGFloat(textViewModel.heightPercent) * screenHeight
            
        
            let textView = DDTextView()
            textView.frame = CGRect(x: x, y: y, width: width, height: height)
        
            textView.text = textViewModel.text
        
            textView.showTime.time = textViewModel.showTime
            textView.hasShowTime = textViewModel.hasShowTime
            textView.isEditable = textViewModel.editable
            textView.moveDisable = textViewModel.moveDisable
            textView.viewIndex = textViewModel.viewIndex
            textView.animeIndex = textViewModel.anime
        
            textView.color = Colors(rawValue: textViewModel.colorHex)!
            textView.fontSize = FontSize(rawValue: textViewModel.fontSize)!
            
                        
            ddTVS.append(textView)
        }
        
        ddTextViews = ddTVS
    }
    
    
    var audioDocURL:URL? {
        
        if let url =  FileManager.ddLessonFileURL(id) {
            return url
        }
        
        return nil
        
    }
    
    //带有record0.m4a后缀的路径.
    var audioURLWithName:URL {
        get {
            
            return FileManager.ddRecordURLWithName(audioDocURL!, name: "record0")!
        }
    }
    
    
    func deleteAudioFile() {
        
        //delete the record file
        do {
            
            try  FileManager.default.removeItem(at: audioDocURL!)
            
        }catch _{
            
        }
    }
    
    
    // 存储图片播放集合
    var imageQueues = [[TimeStamp]]()
    
    
    override static func ignoredProperties() -> [String] {
        return ["ddTextViews","audioDocURL","audioURLWithName","imageQueues"]
    }
    
    func updateImageQueuesWithPlayQueue() {
        
        var points = [TimeStamp]()
        var queues = [[TimeStamp]]()
        
        for i in 0..<playQueue.count {
            let point = playQueue[i]
            
            if point.launchType ==  LaunchType.openImage || point.launchType == LaunchType.moveImagePage {
                points.append(point)
            }
            
            if point.launchType ==  LaunchType.closeImage {
                points.append(point)
                queues.append(points)
                points.removeAll()
            }
            
        }
        
        imageQueues = queues
        
        checkImageQueues()
    }
    
    //检查队列集合,如果某个集合中没有了"打开",则"关闭"的时间戳.
    func checkImageQueues() {
        
        imageQueues.forEach {
            
            var noOpenPoint = true
            
            for point in $0 {
                
                if  point.launchType == LaunchType.openImage {
                    noOpenPoint = false
                }
                
                
            }
            
            if noOpenPoint {
                //从队列中删除"关闭"时间戳
                $0.forEach {
                    if let index = playQueue.index(of: $0) {
                        playQueue.remove(at: index)
                    }
                    
                }
            }
            
        }
        
    }
    
    func updatePointShowImageIndex() {
        
        for i in 0..<playQueue.count {
            
            if playQueue[i].launchType == .moveImagePage {
                let photo = playQueue[i].imageInStamp!
                let index = recordPhotos.index(of: photo)!
                playQueue[i].indexShowImage.value = index
            }
            
            
        }
        
    }
    
    //联级删除关联对象
    func cascadingDeleteInRealm(_ realm:Realm) {
        
        self.deleteAudioFile()
        
        realm.delete(recordPhotos)
        realm.delete(textViews)
        realm.delete(playQueue)
        realm.delete(samples)
        
        realm.delete(self)
    }
    
}


class Theme: Object {
    
    //默认主题和keyName
    dynamic var nameValue = "default"
    
    dynamic var imageURLString = DefaultThemeUrl
    
    var imageUrl: URL  {
        
        if let url = URL(string: imageURLString) {
            return url
        }
        
        return URL(string: DefaultThemeUrl)!
    }
    
    override static func ignoredProperties() -> [String] {
        return ["imageUrl"]
    }
    
    
}



/// 音频分贝表
class sampleModel:Object {
    dynamic var id = "" //和RecordModel一样.
    dynamic var sample:Float = 0.0
}


//文本框基本数据表
class TextViewModel: Object {
    
    dynamic var xPercent:Float = 0.0
    dynamic var yPercent:Float = 0.0
    dynamic var widthPercent:Float = 0.0
    dynamic var heightPercent:Float = 0.0
    
    dynamic var text:String = ""
    dynamic var showTime:Float = 0
    dynamic var viewIndex = 0
   
    dynamic var hasShowTime = false
    dynamic var editable = false
    dynamic var moveDisable = false
    
    
    dynamic var colorHex:String = ""
    dynamic var fontSize:CGFloat = FontSize.one.rawValue
    dynamic var animeBackName = ""
    dynamic var anime:Int = 0 {
        didSet {
            switch anime {
            case 0:
                animeBackName = "none"
            case 1:
                animeBackName = "fade-in"
            case 2:
                animeBackName = "slide-down"
            case 3:
                animeBackName = "slide-left"
            case 4:
                animeBackName = "zoom-out"
            case 5:
                animeBackName = "zoom-in"
            default:
                break
            }
        }
    }
    
    
    
}

//案例图片数据表
class Picture: Object {
    
    dynamic var imageData: Data = Data()
    dynamic var willShow: Bool = false
    
    //非持久化属性,后台图片地址.
    var imageURL = ""
    
    var asset = PHAsset() {
        didSet {
            
        }
    }
    
    var image: UIImage {
        
        get {
            if let image = UIImage(data: imageData) {
                return image
            }
            
            return UIImage()
        }
        
        set {
            
            self.imageData = UIImageJPEGRepresentation(newValue, 1.0)!
            
            }
        
    }
    
    override static func ignoredProperties() -> [String] {
        return ["image","smallImage","imageURL","asset"]
    }
}

//时间戳表
class TimeStamp: Object {
    
    dynamic var time:Float = 0
    dynamic var launched = false
    dynamic var launchTypeInt = 0
    dynamic var action = ""
    dynamic var conflictWithRecordTrim = false
    //对应的是一个图片,用户点对图片之间的删除.
    dynamic var imageInStamp: Picture?
    
    var launchType:LaunchType {
        get {
            
            return LaunchType(rawValue: launchTypeInt)!
        }
        
        set {
            
            launchTypeInt = newValue.rawValue
            action = newValue.action
        }
    }
    
    let indexShowImage = RealmOptional<Int>()
    let indexShowText = RealmOptional<Int>()
    //在图片播放队列中的编号.默认设置一个一般不会达到的数字.
    let indexInImageQueues = RealmOptional<Int>()
}

class DDShowTime : NSObject {
    
    var time:Float = 0
    var inTrimmedTime = false //是否被剪切段覆盖.
    //在波形图中的位置Int
    var indexInWave = 0
}

enum LaunchType :Int {
    
    case defaultMode   = 0
    case showText      = 1     //显示文本框
    
    case openImage     = 2     //打开案例浏览页面
    case closeImage    = 3    //关闭案例浏览页面
    case moveImagePage = 4  //案例浏览页面-移动图片
    
    var action:String  {
        switch self {
        case .showText:
            return "text"
        case .moveImagePage :
            return "image"
        case .closeImage:
            return "closeImage"
        case .openImage:
            return "openImage"
        default:
            return ""
        }
    }
}

enum Colors: String {
    case Black  = "#1D1D1D"
    case Red    = "#E7363E"
    case Blue   = "#327CE4"
    case Yellow = "#FED345"
    case Green  = "#42A85C"
    
    var hexColor:UIColor {
        
        return UIColor(hexString: self.rawValue)
    }
    
    static let allValues = [Black, Red, Blue,Yellow,Green]
}


enum  FontSize:CGFloat {
    case one = 14.0
    case two = 16.0
    case three = 18.0
    case four = 20.0
    case five = 24.0
    
    var font:UIFont {
        return UIFont.systemFont(ofSize: self.rawValue)
    }
    
    static let allValues = [one,two,three,four,five]
}






