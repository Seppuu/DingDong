//
//  DDPhotosViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/3/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import CTAssetsPickerController
import RandomColorSwift
import SnapKit
import AVFoundation
import RealmSwift
import CLImageEditor
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DDPhotosViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    var tableView: UITableView!
    
    var collectionView: UICollectionView!
    
    let cellID = "cell"
    
    var page = Page()
    
    var assets = [PHAsset]()
    
    var photos = List<Picture>()
    
    var imageQueuesPassToGroup = [[TimeStamp]]()
    
    var maxPhotoCount = 8
    
    var exchangePhoto = false
    
    var confirmHandler: ( (_ record:Page) -> (Void))?
    
    var imageDleleteBeginHandler: (([Int]) -> (Void))?
    
    var orders = 3
    
    var topView = UIView()
    
    var cellSelectIndex:Int? //被选中的图片.
    
    var topContainer: topPhotosContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.ddViewBackGroundColor()
        
        setNavbarItem()
        
        setToobar()
        
        setTopCollectionView()
        
        setTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    func setNavbarItem() {
        title = "照片"
        let rightBarItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DDPhotosViewController.confirmTap(_:)))
        navigationItem.rightBarButtonItem = rightBarItem
        
    }
    
    func setToobar() {
        
        let buttonFrame = CGRect(x: 0, y: 0, width: 19, height: 23)
        let labelFrame = CGRect(x:0, y: 23, width: 20, height: 10)
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.setImage(UIImage(named: "icon_ios_trash"), for: UIControlState())
        deleteButton.addTarget(self, action: #selector(DDPhotosViewController.deleteTap(_:)), for: .touchUpInside)
        deleteButton.frame = buttonFrame
        
        let deleteLabel = UILabel(frame: labelFrame)
        deleteLabel.font = UIFont.systemFont(ofSize: 8)
        deleteLabel.text = "删除"
        deleteLabel.textAlignment = .center
        deleteLabel.textColor = UIColor.ddBasicBlueColor()
        deleteLabel.backgroundColor = UIColor.clear
        
        deleteButton.addSubview(deleteLabel)
        
        let changeButton = UIButton(type: .custom)
        changeButton.setImage(UIImage(named: "icon_ios_repeat"), for: UIControlState())
        changeButton.addTarget(self, action: #selector(DDPhotosViewController.changeTap(_:)), for: .touchUpInside)
        changeButton.frame = buttonFrame
        
        let changeLabel = UILabel(frame: labelFrame)
        changeLabel.font = UIFont.systemFont(ofSize: 8)
        changeLabel.text = "替换"
        changeLabel.textAlignment = .center
        changeLabel.textColor = UIColor.ddBasicBlueColor()
        changeLabel.backgroundColor = UIColor.clear
        
        changeButton.addSubview(changeLabel)
        
        let editButton = UIButton(type: .custom)
        editButton.setImage(UIImage(named: "icon_ios_edit"), for: UIControlState())
        editButton.addTarget(self, action: #selector(DDPhotosViewController.editTap(_:)), for: .touchUpInside)
        editButton.frame = buttonFrame
        
        let editLabel = UILabel(frame: labelFrame)
        editLabel.font = UIFont.systemFont(ofSize: 8)
        editLabel.text = "编辑"
        editLabel.textAlignment = .center
        editLabel.textColor = UIColor.ddBasicBlueColor()
        editLabel.backgroundColor = UIColor.clear
        
        editButton.addSubview(editLabel)
        
        //toobar 布局
        let flexSpace0 = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let deleteBarItem = UIBarButtonItem(customView: deleteButton)
        
        let flexSpace1 = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let flexSpace11 = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let changeBarItem = UIBarButtonItem(customView: changeButton)
        
        let flexSpace2 = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let flexSpace22 = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let editBarItem = UIBarButtonItem(customView: editButton)
        
        let flexSpace3 = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let items = [flexSpace0,deleteBarItem,flexSpace1,flexSpace11,changeBarItem,flexSpace2,flexSpace22,editBarItem,flexSpace3]
        
        self.setToolbarItems(items, animated: false)
        
        
        
        
    }
    
    func setTopCollectionView() {
        
        self.automaticallyAdjustsScrollViewInsets = false //去掉collectionview留白

        topContainer = topPhotosContainer()
        
        view.addSubview(topContainer)
        
        let height = (screenWidth / 4.0 - ((1.0 / 4) * 3)) * 2 + 1
        topContainer.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view).offset(64)
            make.height.equalTo(height)
        }
        
        var images = [UIImage]()
        photos.forEach {
            
            images.append($0.image)
            
        }
        
        topContainer.photos = images
        
        topContainer.addImageTapHandler = {
            
            self.addPhoto()
        }
        
        //上方图片点击闭包
        topContainer.imageCellSelectedHandler = { [weak self] (index) in
            
            self?.navigationController?.setToolbarHidden(false, animated: true)

            self?.imageQueuesPassToGroup =  self!.getQueuesHasPhoto(index)
            
            self?.cellSelectIndex = index //设置当然被选中的cellindex.不管有没有被展示.
            
            guard self?.imageQueuesPassToGroup.count > 0 else {return}
            
            self?.tableView.reloadData()
            
            self?.tableView.alpha = 1.0
            
                    }
        
        topContainer.imageIndexChanged =  { [weak self] (fromInex,toIndex) in
            
            self!.photos.move(from: fromInex, to: toIndex)
        }
    }
    
    func setTableView() {
        
        let Y = 64 + (screenWidth / 4.0 - ((1.0 / 4) * 3)) * 2 + 1
        let frame = CGRect(x: 0, y:Y, width: screenWidth, height: screenHeight - Y)
        tableView = UITableView(frame: frame, style:.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.alpha = 0.0
        self.view.addSubview(tableView)
        
    }
    
    
    func getQueuesHasPhoto(_ index:Int) -> [[TimeStamp]]{
        
        var arr = [[TimeStamp]]()
        //先选出有改图片在其中的队列集合.
        page.imageQueues.forEach {
            //[DDTimePoint]
            var hasIndexImage = false
            $0.forEach { (point) in
                //首先得是有展示图片index记录的队列.
                guard  point.launchType == LaunchType.moveImagePage else {return}
                
                //比较其中的index 是否是该图片
                guard point.imageInStamp == page.recordPhotos[index] else {return}
                
                //是,收集整个含有此图片的队列集合.
                hasIndexImage = true
            }
            
            if hasIndexImage { arr.append($0) }
            
            
        }
       // print("收集了\(arr.count)组含有改图片的队列集合.")
        return arr
        
    }
    
    
    func confirmTap(_ sender:UIBarButtonItem) {
        
        self.confirmHandler!(self.page)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func deleteTap(_ sender:UIBarButtonItem) {
    
        //确认点击的图片是否被展示过,通过判断是否有tableview数据
        guard self.imageQueuesPassToGroup.count > 0 else {
            //没有,直接删除图片.一般情况肯定是末尾的图片.所以不会影响前面被展示的图片的顺序.
            let realm = try! Realm()
            try! realm.write {
                photos.remove(at: cellSelectIndex!)
            }

            //刷新顶部视图,取消"高亮",完成之后,重置高亮flag.和 cellSelectIndex
            topContainer.photos.remove(at: cellSelectIndex!)
            cellSelectIndex = nil
            topContainer.cancelHighLight = true
            topContainer.collectionView.reloadData()
            self.navigationController?.setToolbarHidden(true, animated: true)
            return
        }
        
        //弹窗确认删除.
        let msg = "在该图片上的录音将一同删除。"
        let alert = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "删除", style: .destructive) { (UIAlertAction) in
            
            self.deleteRecords()
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }

    func deleteRecords() {
        //删除图片显示的时间段,删除完成之后,之后的所有时间戳向前移动该时间段.
        setAudioHelper()
        
        let realm = try! Realm()
        
        //起点,持续时间 用于音频剪切 和 用于时间点处理
        //这里的起点就是时间戳本身,持续时间是改图片消失前的时间.(后一个点 - 当前的点)
        var trimDict = [Float:Float]()
        var trimmingPoints = [TimeStamp]() //将要删除的点 用于时间点处理
        
        for i in 0..<page.playQueue.count {
            
            let point = page.playQueue[i]
            
            if point.imageInStamp == page.recordPhotos[cellSelectIndex!] {
                //这个点需要删除.
                trimmingPoints.append(point)
                //获取起点和持续时间.
                let startTime = point.time
                let duration = (page.playQueue[i+1].time) - (point.time)
                
                trimDict[startTime] = duration
                
            }
            
        }
        
        //收集好需要的数据,进行处理.
        
        //删除含有被点击图片的时间点
        trimmingPoints.forEach {
            
            //播放队列
            let index = page.playQueue.index(of: $0)
            
            try! realm.write {
                page.playQueue.remove(at: index!)
            }
            
            
        }
        
        //删除图片.
        try! realm.write {
            page.recordPhotos.remove(at: cellSelectIndex!)
        }
        
        
        
        //更新队列的时间点.
        let startTimes = Array(trimDict.keys)
        
        for startTime in startTimes {
            
            let duration = trimDict[startTime]!
            
            for i in 0..<page.playQueue.count {
                
                if page.playQueue[i].time > startTime {
                    
                    try! realm.write {
                        page.playQueue[i].time -= duration
                    }
                    
                }
            }
            
        }
        
        //一次性剪切
        let timesSorted = startTimes.sorted()
        
        var timesForTrim = [Float]()
        
        for i in 0..<timesSorted.count {
            
            timesForTrim.append(timesSorted[i])
            
            //获取下一个时间点
            let nextTime = timesSorted[i] + trimDict[timesSorted[i]]!
            timesForTrim.append(nextTime)
            
            
        }

        audioHelper.clipAudioByTimes(timesForTrim)
        
        //删除波形图
        var timesForSamplesTrim = [Int]()
        for timeFloat in timesForTrim {
            
            let int = Int(timeFloat * 4 )
            timesForSamplesTrim.append(int)
        }
        
        trimSamples(timesForSamplesTrim)
    }
    
    func trimSamples(_ times:[Int]) {
        let realm = try! Realm()
        var currentTimes = times
        //获取N段截取区间.从末尾开始删除.
        var doubleTimes = [[Int]]()
        for _ in 0..<times.count/2 {
            var range = [Int]()
            
            range.append(currentTimes.removeFirst())
            range.append(currentTimes.removeFirst())
            
            doubleTimes.append(range)
            
        }
        
        for i in 0..<doubleTimes.count {
            
            //从末尾删除
            let start = doubleTimes[doubleTimes.count - i - 1][0]
            let end   = doubleTimes[doubleTimes.count - i - 1][1]
            
            try! realm.write {
                page.samples.removeSubrange(start...end)
            }
            
            
            
        }
    }
    
    let audioHelper = DDAudioHandler()
    
    func setAudioHelper() {
        
        audioHelper.audioDocURL = page.audioDocURL
        
        audioHelper.trimmBeginHandler =  {
            
            
        }
        
        
        audioHelper.trimmCompleteHandler =  { [weak self] in
            //剪切完成,合并被剪切的音频
            self?.audioHelper.combinedAudiosifNeed()
            
            
            //在主线程更新UI
            DispatchQueue.main.async(execute: {

                self?.refreshData()

            })

            
        }
    }
    
    
    func refreshData() {
        
        let realm = try! Realm()
        
        
        try! realm.write {
            self.page.updateImageQueuesWithPlayQueue()
            self.page.updatePointShowImageIndex()
        }
        
        self.photos = self.page.recordPhotos
        var images = [UIImage]()
        self.photos.forEach {
            
            images.append($0.image)
            
        }
        
        self.cellSelectIndex = nil
        
        self.topContainer.cancelHighLight = true
        
        self.topContainer.photos = images
        
        self.topContainer.collectionView.reloadData()
        
        self.imageQueuesPassToGroup.removeAll()
        
        self.tableView.reloadData()
    }
    
    func changeTap(_ sender:UIBarButtonItem) {
        
        exchangePhoto = true
        
        changePhoto()
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: UITableView Deledate Method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return imageQueuesPassToGroup.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        if orders > 0 {
                
            let groupView = photoGroupView.instanceFromNib()
            groupView.tag = 200
            groupView.frame = cell.frame
            cell.contentView.addSubview(groupView)
            var imagesData = [UIImage]()
                photos.forEach {
                    imagesData.append($0.image)
            }
            let queue = imageQueuesPassToGroup[indexPath.item]
            
            //根据队列拿出需要的图片
            var imagesPassToCellView = [UIImage]()
            var highLightIndexs = [Int]()
            queue.forEach {
                
                guard $0.launchType == LaunchType.moveImagePage else { return }
                let image = $0.imageInStamp?.image
                imagesPassToCellView.append(image!)
                if $0.imageInStamp! == self.photos[cellSelectIndex!] {
                    //将这个图片的index收集起来. 注意 - 1
                    highLightIndexs.append(imagesPassToCellView.count - 1)
                }

            }
            groupView.intArr = highLightIndexs //高亮的cell index
            
            groupView.photos = imagesPassToCellView //展示的iamge data
            
            //从队列集合中获取起始点. open ,close point

            queue.forEach {
                
                if $0.launchType == LaunchType.openImage { groupView.start = $0.time }
                
                if $0.launchType == LaunchType.closeImage { groupView.end = $0.time }
            }
            
            groupView.startLabel.text = "\(groupView.start!)s"
            
            groupView.endLabel.text = "\(groupView.end!)s"
            
            groupView.collectionView.reloadData()
            
            //Handler
            groupView.playTapHandler =  { [weak self] (start,end) in
                
                self?.playRecordWithGroupImage(start, end: end)
                
            }
            
        }
        
        return cell
    }
    
    //MARK: 播放
    var alertView:DDPlaypartRecordAlertView?
    
    var audioPlayer:AVAudioPlayer?
    
    var tintView :UIView?
    
    func playRecordWithGroupImage(_ begin:Float,end:Float) {
        
        //设置遮罩
        tintView = UIView()
        view.addSubview(tintView!)
        tintView!.snp.makeConstraints({ (make) in
            make.left.top.right.bottom.equalTo(view)
        })
        
        tintView!.backgroundColor = UIColor.ddTintViewColor()
        
        //设置展示窗口
        alertView = DDPlaypartRecordAlertView()
        view.addSubview(alertView!)
        alertView!.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(300)
        }
        
        //设置计时器,设置播放器
        fireCount = begin
        endSec    = end
        
        playRecord(begin)
        
        Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(DDPhotosViewController.playSomeSoundsFire(_:)), userInfo: nil, repeats: true)
    }

    
    
    func playRecord(_ currentTime:Float){
        
        //获取播放路径.
        let voiceFileURL = page.audioURLWithName
        
        if AVAudioSession.sharedInstance().category == AVAudioSessionCategoryRecord {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
                print("playVoice setCategory failed: \(error)")
                return
            }
        }
        
        do {
            
            let audioPlayer = try AVAudioPlayer(contentsOf: voiceFileURL as URL)
            
            self.audioPlayer = audioPlayer // hold it
            
            audioPlayer.prepareToPlay()
            
            
            if audioPlayer.play() {
                
                //设置开始时间点.
                audioPlayer.currentTime = Double(currentTime)
            }
            
        } catch let error {
            print("play voice error: \(error)")
        }
        
    }
    
    var fireCount:Float = 0.0
    var endSec:Float = 0.0
    //选播计时器.
    func playSomeSoundsFire(_ timer:Timer){
        fireCount += 0.25
        
        if let _ = audioPlayer {
            
            let currentTime = fireCount
            
            groupPlaying(currentTime, endSec:endSec)
            
        }
        guard fireCount >= endSec else { return }
        timer.invalidate()
        //停止播放.
        if let audioPlay = audioPlayer {
            audioPlay.pause()
            self.audioPlayer = nil
            fireCount = 0.0
            groupPlayEnd()
        }
        
    }
    
    func groupPlaying(_ time:Float,endSec:Float) {
        
        page.playQueue.forEach {
            
            //试播,播放图片
            guard $0.time == time  && ($0.launchType == LaunchType.moveImagePage) else { return }
            
            let image = $0.imageInStamp?.image
            let index = page.recordPhotos.index(of: $0.imageInStamp!)
            alertView?.changeImageViewImage(image!, imageIndex: index! + 1)
            
        }
        
        let currentSeconds = Int(time)
        let currentMin = Int(currentSeconds / 60 )
        let currentSec = Int(currentSeconds - currentMin * 60)
        
        let totalSecond = Int(endSec)
        let totalMin = Int(totalSecond / 60)
        let totalSec = Int(totalSecond - totalMin * 60)
        
        alertView!.timeTextLabel.text = String(format: "%02d:%02d/%02d:%02d", currentMin, currentSec,totalMin ,totalSec)
    }
    
    func groupPlayEnd() {
        
        alertView?.removeFromSuperview()
        tintView?.removeFromSuperview()
    }
    
    
    func closeAudioPlay() {
        audioPlayer?.stop()
        audioPlayer = nil
        ddAudioPlayTimelyObserver = 0
    }
    
    func refreshViewAfertImageAction() {
        
        cellSelectIndex = nil
        
        self.topContainer.photos.removeAll()
        
        self.photos.forEach {
            
            self.topContainer.photos.append($0.image)
            
        }
        
        //TODO:pass low quality image
        self.page.recordPhotos = self.photos
        self.topContainer.cancelHighLight = true
        
        
        self.topContainer.collectionView.reloadData()
        
        self.imageQueuesPassToGroup.removeAll()
        
        self.tableView.reloadData()
    }
    
    func saveImage() {
        //获取了选择
        let realm = try! Realm()
        
        for asset in assets {
            PhotoManager.sharedManager.getAssetThumbnail(asset, completion: { (image) in
                
                let photo = Picture()
                photo.image = image
                
                try! realm.write {
                    self.photos.append(photo)
                }
            })
        }
        
        
    }
    
    func changeAndSaveImage() {
        //获取了选择
        let realm = try! Realm()
        //替换单张照片
        for asset in assets {
            
            PhotoManager.sharedManager.getAssetThumbnail(asset, completion: { (image) in
                //替换
                try! realm.write {
                    self.photos[self.cellSelectIndex!].image = image
                }
            })
            
        }
    }
    
}
extension DDPhotosViewController: AVAudioPlayerDelegate {
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        
        print("audioPlayerDidFinishPlaying: \(flag)")
        closeAudioPlay()
        
        DDAudioService.sharedManager.resetToDefault()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        print("audioPlayerDecodeErrorDidOccur: \(error)")
        
        DDAudioService.sharedManager.resetToDefault()
    }
}

extension DDPhotosViewController:CLImageEditorDelegate {
    func editTap(_ sender:UIBarButtonItem) {
        
        //图片编辑.
        let image = self.photos[self.cellSelectIndex!].image
        
        let editor = CLImageEditor(image: image)
        editor?.delegate = self
        
        //hide some tool (喷溅,尺寸调整,色调曲线,效果)
        let toolNames = [
            "CLSplashTool",
            "CLResizeTool",
            "CLToneCurveTool",
            "CLEffectTool"
        ]
        
        for name in toolNames {
            let tool = editor?.toolInfo.subToolInfo(withToolName: name, recursive: false)
            
            tool?.available = false
        }
        
        
        
        present(editor!, animated: true, completion: nil)
    }
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEdittingWith image: UIImage!) {
        
        let realm = try! Realm()
        try! realm.write {
            self.photos[self.cellSelectIndex!].image = image
            }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        refreshViewAfertImageAction()
        editor.dismiss(animated: true, completion: nil)
        
    }
    
    
}

extension DDPhotosViewController:CTAssetsPickerControllerDelegate {
    //打开相册


    func addPhoto() {
        //打开相册.
        PHPhotoLibrary.requestAuthorization { (PHAuthorizationStatus) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in

                let picker = CTAssetsPickerController()
                picker.delegate = self
                picker.showsSelectionIndex = true
                self.maxPhotoCount = 8
                self.present(picker, animated: true, completion: nil)

            })
        }
    }

    func changePhoto(){
        
        PHPhotoLibrary.requestAuthorization { (PHAuthorizationStatus) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                let picker = CTAssetsPickerController()
                picker.delegate = self
                self.maxPhotoCount = 1
                self.present(picker, animated: true, completion: nil)
                
            })
        }
        
    }


    //MARK:相册代理
    func assetsPickerController(_ picker: CTAssetsPickerController!, didFinishPickingAssets assets: [Any]!) {
        let hud = MBProgressHUD.showAdded(to: picker.view, animated: true)
        hud.mode = .indeterminate
        
        if let acutalAsset = assets as? [PHAsset] {
            //TODO:save high quality image to local
            self.assets = acutalAsset
            
            
            if exchangePhoto == true {
                //替换
                changeAndSaveImage()
            }
            else {
                saveImage()
            }
            
            refreshViewAfertImageAction()
            hud.hide(animated: true)
            self.dismiss(animated: true, completion: nil)
        }

    }


    func assetsPickerController(_ picker: CTAssetsPickerController!, shouldSelect asset: PHAsset!) -> Bool {
        let max = maxPhotoCount

        //注意这里的count是0 based
        if (picker.selectedAssets.count >= max) {

            let msg = "请选择少于\(max)张数量的图片"
            let alert = UIAlertController(title: "提示", message: msg, preferredStyle: UIAlertControllerStyle.alert)

            let action = UIAlertAction(title: "好", style: UIAlertActionStyle.default, handler: nil)

            alert.addAction(action)

            picker.present(alert, animated: true, completion: nil)
        }

        return (picker.selectedAssets.count < max)
    }
}



