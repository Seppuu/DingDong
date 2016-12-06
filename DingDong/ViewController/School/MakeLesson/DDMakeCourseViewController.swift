//
//  makeAudioViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/2/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import KeyboardMan
import RMPZoomTransitionAnimator
import RealmSwift
import IQKeyboardManagerSwift

class DDMakeCourseViewController: BaseViewController {
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var timeView: RecordCountView!
    
    var countDownView = CountDownView()
    
    //realm object
    var page: Page {
        get {
            let page = self.recordControl.page
            return page
        }
    }
    
    var backImageURL:URL?
    
    var hud = MBProgressHUD()
    
    var recordControl = DDRecordControl()
    
    var recordControlBottomCons:Constraint? = nil
    
    var themeImageView = UIImageView()
    
    var bigContainerView = UIView()
    
    lazy var addTextButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"addTextButton") , for: UIControlState())
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(DDMakeCourseViewController.addTextView(_:)), for: .touchUpInside)
        return button

    }()
    
    lazy var photoButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"addImageButton") , for: UIControlState())
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(DDMakeCourseViewController.toPhotosView(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var showPhotoButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"addImageButton") , for: UIControlState())
        button.addTarget(self, action: #selector(DDMakeCourseViewController.showPhotosView(_:)), for: .touchUpInside)
        return button
    }()
    
    var countDot = UILabel()
    
    var imagesAttachView = DDImagesAttachmentView()
    
    var alertView: DDPlaypartRecordAlertView?
    
    //var iFlyhandler = DDiFlyHandler()
    
    var subTitleView = DDShowSubTitleViewController()
    
    //参考线
    var coordinateLine = UIView()
    //底部编辑栏
    var textEditView = DDTextEditView()
    
    var textEditViewBottomCons:Constraint? = nil
    
    var showText = false
    
    var keyboardMan = KeyboardMan()
    
    var keyboardActive = false {
        
        didSet {
           
            if keyboardActive {
                
                //隐藏,顶部按钮
                addTextButton.alpha   = 0.0
                photoButton.alpha     = 0.0
                showPhotoButton.alpha = 0.0
            }
            else {
                
                //显示顶部按钮
                addTextButton.alpha   = 1.0
                photoButton.alpha     = 1.0
                showPhotoButton.alpha = 0.0
            }
        }
        
    }
    
    //移动图片背景和文本框如果需要.
    var moveHeight:CGFloat?
    
    var currentKeyBoardHeight:CGFloat?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        let tap = UITapGestureRecognizer(target: self, action: #selector(DDMakeCourseViewController.tapSelf))
        view.addGestureRecognizer(tap)
        
        makeUI()
        
        setNavbar()
        
        setkeyBoardHelper()
    }
    
    func makeUI() {
        
        timeView = RecordCountView.instanceFromNib()
        timeView.backgroundColor = UIColor.clear
        timeView.dotView.alpha = 0.0
        topView.addSubview(timeView)
        timeView.snp.makeConstraints { (make) in
            make.centerX.equalTo(topView.snp.centerX)
            make.bottom.equalTo(topView.snp.bottom)
            make.width.equalTo(150)
            make.height.equalTo(21)
        }
        
        bigContainerView.frame = view.bounds
        view.addSubview(bigContainerView)
        
        // Add themeImageView
        themeImageView.frame = view.bounds
        bigContainerView.addSubview(themeImageView)
        if backImageURL != nil {
            themeImageView.kf.setImage(with: backImageURL)
        }
        
        themeImageView.contentMode = .scaleAspectFill
        
        
        // Add Button
        view.addSubview(addTextButton)
        addTextButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(8)
            make.top.equalTo(self.view).offset(64 + 8)
            make.width.equalTo(30)
            make.height.equalTo(25)
        }
        addTextButton.alpha = 0.0
        
        //展示图片
        view.addSubview(showPhotoButton)
        showPhotoButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.view).offset(-8)
            make.top.equalTo(self.view).offset(64 + 8)
            make.width.equalTo(30)
            make.height.equalTo(25)
        }
        showPhotoButton.alpha = 0.0
        
        //添加图片按钮
        view.addSubview(photoButton)
        photoButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.view).offset(-8)
            make.top.equalTo(self.view).offset(64 + 8)
            make.width.equalTo(30)
            make.height.equalTo(25)
        }
        photoButton.alpha = 0.0
        
        view.addSubview(countDot)
        countDot.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.view).offset(-2)
            make.top.equalTo(self.view).offset(64 + 2)
            make.width.height.equalTo(18)
        }
        
        countDot.backgroundColor = UIColor ( red: 0.9049, green: 0.2107, blue: 0.2415, alpha: 1.0 )
        countDot.layer.cornerRadius = 18/2
        countDot.layer.masksToBounds = true
        countDot.font = UIFont.systemFont(ofSize: 14)
        countDot.textAlignment = .center
        countDot.textColor = UIColor.white
        countDot.alpha = 0.0
        
        
        // Add DDRecordControl
        view.addSubview(recordControl)
        recordControl.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(view)
            recordControlBottomCons =  make.bottom.equalTo(view).offset(150).constraint
            make.height.equalTo(48 * 2 + 10)
        }
        recordControl.delegate = self
        recordControl.buttonDelegate = self
        recordControl.backgroundColor = UIColor.clear
        
        // Add imagesView 
        imagesAttachView.frame = self.view.frame
        view.addSubview(imagesAttachView)

        self.imagesAttachView.alpha = 0.0
        imagesAttachView.photos = self.page.recordPhotos
        
        
        // Add textEdit
        textEditView = DDTextEditView.instanceFromNib()
        view.addSubview(textEditView)
        textEditView.snp.makeConstraints({ (make) in
            
            make.left.right.equalTo(view)
            textEditViewBottomCons = make.bottom.equalTo(view).offset(48).constraint
            make.height.equalTo(48)
        })
        textEditView.delegate = self
        textEditView.backgroundColor = UIColor.ddTextEditButtonsBackColor()
        
        countDownView = CountDownView.instanceFromNib()
        view.addSubview(countDownView)
        countDownView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(80)
            make.height.equalTo(120)
        }
        
        countDownView.alpha = 0.0
    }
    
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    
    func setNavbar() {
        
        
        topView.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        topView.layer.shadowColor  = UIColor ( red: 0.698, green: 0.698, blue: 0.698, alpha: 1.0 ).cgColor
        
        view.bringSubview(toFront: topView)
        
        topViewTopConstraint.constant = -64
        self.view.layoutIfNeeded()
    }
    
    var dismissHandler:((_ textViews:[DDTextView]) -> ())?
    
    @IBAction func backButtonTap(_ sender: UIButton) {
        
        //录音时,完成才能后退
        guard recordControl.state == .finishRecord ||
              recordControl.state == .default      ||
              recordControl.state == .playPausing
        else {return}
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        recordControl.removeDisplayLink()
        
        self.page.saveTextData()
        self.deleteAllTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordControl.setCADisplayLinkTimer()
        
        //更新文本框,如果有.
        addTextViewFromPage()
      
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //转场动画完成
        showTopAndBottomView()
        
        recordControl.checkCureentPhotoStatus()
        //更新录音,波形属性.
        recordControl.updateTimeAndSampleWavesNeeded()
        
        //更新顶部相册计数
        let count = page.recordPhotos.count
        if count > 0 {
            self.countDot.text = "\(count)"
            self.countDot.alpha = 1.0
        }
    }
    
    func showTopAndBottomView() {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.topViewTopConstraint.constant = 0
            self.recordControlBottomCons?.update(offset: 0)
            self.addTextButton.alpha = 1.0
            self.photoButton.alpha = 1.0
            self.view.layoutIfNeeded()
            
            }) { (Bool) in
                
        }
        
    }
    
    //点击自己.隐藏其他文本框的边框
    func tapSelf() {
       //检车如果在文本框编辑状态,点击自己消失键盘
       guard keyboardActive else {return}
        
        view.endEditing(true)
        
//        page.ddTextViews.forEach {
//            $0.layer.borderColor = UIColor.clearColor().CGColor
//        }
//        
        //如果,录音台在底部,让它出现.
//        guard showText else {return}
//        showText = false
//        animteTextEdit(false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    func addTextViewFromPage() {
        
        page.createTextView()
        
        page.ddTextViews.forEach { [weak self] in
            
            $0.DDdelegate = self
            
            self?.bigContainerView.addSubview($0)
        }
        
    }
    
    //MARK: Text Action
    func addTextView(_ sender:UIButton) {

        let textView = DDTextView(frame: CGRect(x: 0, y: 0, width: 50 + 40, height: 37))
       
        textView.viewIndex = page.ddTextViews.count

        textView.DDdelegate = self
        
        bigContainerView.addSubview(textView)
        
        // add textView to record arry
        page.ddTextViews.append(textView)
        
        //隐藏其他文本框的边框
        highLightActiveTextView(textView)
        autoLayoutTextViews()
        
        //自动弹出键盘
        textView.becomeFirstResponder()

    }
    
    //文本框自动布局
    func autoLayoutTextViews() {
        //总高度需要修改.
        let totalHeight = screenHeight - 64 - 150
        var textViewsHeight:CGFloat = 0.0
        for i in 0..<page.ddTextViews.count {
            
            //获取所有文本框的高度
            let height = page.ddTextViews[i].frame.size.height
            textViewsHeight += height
            
        }
        
        let averageCount = page.ddTextViews.count + 1
        
        let averageHeight = (totalHeight - textViewsHeight) / CGFloat(averageCount)
        
        var accumulateHeight:CGFloat = 0.0
        for i in 0..<page.ddTextViews.count {
            
            page.ddTextViews[i].frame.origin.y = 64 + accumulateHeight + averageHeight * (CGFloat(i) + 1)
            
            accumulateHeight += page.ddTextViews[i].frame.size.height
            
            //最后一个文本框的X位置和上一个一样.
            if i == page.ddTextViews.count - 1 && i > 0 {
                
                page.ddTextViews[i].frame.origin.x =  page.ddTextViews[i-1].frame.origin.x
            }
            
        }
        
    }
    
    func getTheActiveTextView() -> DDTextView? {
        
        var textView:DDTextView?
        page.ddTextViews.forEach {
            
            if  $0.highLight {
                textView = $0
            }
        }
        
        return textView != nil ? textView! : nil
    }
    //高亮当前活跃的文本框
    func highLightActiveTextView(_ textView:DDTextView) {
        
        page.ddTextViews.forEach { $0.deHighLightSelf() }
        textView.highLightSelf()
        
        //文本框点击了,如果编辑框没出现,那么让它出现
//        guard !showText else {return}
//        
//        showText = true
//        animteTextEdit(true)
    }
    
    //改变文本颜色
    func changeTextViewColor(_ color:Colors) {
        
        guard let textView = getTheActiveTextView() else {return}
        textView.textColor = color.hexColor
        textView.color = color
        
    }
    
    //改变文本字号
    func changeTextFontSize(_ sizeIndex:Int) {
        
        guard let textView = getTheActiveTextView() else {return}
        textView.fontSize = FontSize.allValues[sizeIndex]
        textView.font = textView.fontSize.font
        
    }
    
    
    //设置文本出现动画
    func setTextShowAnime(_ animeIndex:Int) {
        guard let textView = getTheActiveTextView() else {return}
        textView.animeIndex = animeIndex
        
    }
    
    //取消文本出现动画,重置到常显
    func cancelTextShowAnime() {
        guard let textView = getTheActiveTextView() else {return}
        textView.animeIndex = 0
    }
    
    //预览文本出现动画.
    func previewTextAnime() {
        guard let textView = getTheActiveTextView() else {return}
        textView.displayTextViewByTime()
    }
    
    //删除文本
    func deleteEdittingTextView() {
        guard let textView = getTheActiveTextView() else {return}
        remove(textView)
    }
    
    func deleteTextViewBy(_ index:Int) {
        
        let view = page.ddTextViews[index]
        
        remove(view)
    }
    
    
    func remove(_ textView:DDTextView) {
        
        // remove it from superView
        textView.removeFromSuperview()
        
        // remove it from recrod object
        page.ddTextViews.removeObject(textView)
        
        // update textviews viewindex
        page.ddTextViews.forEach {
            
            $0.viewIndex = page.ddTextViews.index(of: $0)!
            
        }
        
    }
    
    
    func deleteAllTextView() {
        
        page.ddTextViews.forEach {
            $0.removeFromSuperview()
        }
        
        page.ddTextViews.removeAll()
    }
    
    //录音台和文本框编辑台动画
    func animteTextEdit(_ showText:Bool) {
        // show text or record
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
            self.recordControlBottomCons?.update(offset: showText ? 150 : 0)
            self.textEditViewBottomCons?.update (offset: showText ? 0 : 48 )
            self.textEditView.layoutIfNeeded()
            self.recordControl.layoutIfNeeded()
                
            }, completion: { (Bool) in
        })
    }
    
    //MARK: HUD
    func showHUDWithText(_ text:String){
        DispatchQueue.main.async {
            // hud here
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .text
            self.hud.offset.y = 500
            self.hud.label.text = text
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.hud.hide(animated: true, afterDelay: 0.5)
            });
        }
    }
    

    
    //检测是否需要高亮和剪辑音频冲突的组件
    func highLightTimepointIfNeed() {
        
        page.playQueue.forEach {
            
            guard $0.conflictWithRecordTrim else {
                //关闭高亮
                switch $0.launchType {
                    
                case LaunchType.showText:
                    page.ddTextViews[$0.indexShowText.value!].layer.borderColor = UIColor.clear.cgColor
                    page.ddTextViews[$0.indexShowText.value!].layer.borderWidth = 1.0
                default:
                    
                    self.photoButton.layer.borderColor = UIColor.clear.cgColor
                    self.photoButton.layer.borderWidth = 0.0
                }
                
                return
            }
            //高亮
            switch $0.launchType {
                
            case LaunchType.showText:
                page.ddTextViews[$0.indexShowText.value!].layer.borderColor = UIColor.red.cgColor
                page.ddTextViews[$0.indexShowText.value!].layer.borderWidth = 2.0
            default:
                
                self.photoButton.layer.borderColor = UIColor.red.cgColor
                self.photoButton.layer.borderWidth = 2.0
            }
            
        }
    }
    
    
}

//图片展示相关
extension DDMakeCourseViewController {
    
    
    func toPhotosView(_ sender:UIButton) {
        
        let vc = DDPhotosViewController()
        vc.photos = self.page.recordPhotos
        vc.page = self.page
        let nav = UINavigationController(rootViewController: vc)
        vc.confirmHandler = { [unowned self] (record) in
            //self.record = record
            self.recordControl.page = record
            
            //print(record.samples.count)
            
            //更新录音附带的图片集
            let photos = self.page.recordPhotos
            
            if photos.count > 0 {
                self.countDot.alpha = 1.0
                self.countDot.text = "\(photos.count)"
            }
            else {
                self.countDot.alpha = 0.0
                self.countDot.text = "\(photos.count)"
            }
        }
        
        vc.imageDleleteBeginHandler = { (intArray) in
            

        }
        
        present(nav, animated: true, completion: nil)
        
    }
    
    //展示案例相册图片
    func showPhotosView(_ sender:UIButton) {
        //更新总播放队列 图片打开
        guard self.recordControl.state == .recording && self.page.recordPhotos.count > 0 else { return }
        
        let realm = try! Realm()
        
        let openPoint = TimeStamp()
        openPoint.time = ddRecordTimelyObserver
        //打开的时候
        openPoint.launchType = LaunchType.openImage
        try! realm.write {
            page.playQueue.append(openPoint)
        }
        
        //由于打开之后,会显示当前的图片,所以,自动增加一个movePoint.时间是打开的时间点之后的0.1秒.
        let movePoint = TimeStamp()
        movePoint.time = openPoint.time + 1
        movePoint.imageInStamp = page.recordPhotos[imagesAttachView.currentPage]
        movePoint.launchType = LaunchType.moveImagePage
        try! realm.write {
            page.playQueue.append(movePoint)
        }
        
        imagesAttachView.setDefaultImagePosition = false
        imagesAttachView.collectionView.isScrollEnabled = true
        imagesAttachView.dismissButton.alpha = 1.0
        imagesAttachView.photos = self.page.recordPhotos
        imagesAttachView.collectionView.reloadData()
        view.bringSubview(toFront: imagesAttachView)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.imagesAttachView.alpha = 1.0
            
            }, completion: {(success) -> Void in
                
        })
        
        //更新总播放队列. 图片移动
        imagesAttachView.imageScorlledHandler = { [unowned self] (index) in
            
            guard self.recordControl.state == .recording else { return }
            print("图片移动记录时刻:\(ddRecordTimelyObserver)")
            let point = TimeStamp()
            point.time = ddRecordTimelyObserver
            point.imageInStamp = self.page.recordPhotos[index]
            point.launchType = LaunchType.moveImagePage
            try! realm.write {
                self.page.playQueue.append(point)
            }
        }
        
        //更新总播放队列, 图片关闭
        imagesAttachView.dismissViewHandler = { [unowned self] in
            
            guard self.recordControl.state == .recording else { return }
            let point = TimeStamp()
            point.time = ddRecordTimelyObserver
            point.launchType = LaunchType.closeImage
            try! realm.write {
                self.page.playQueue.append(point)
                
                //uodate imageQueues
                self.page.updateImageQueuesWithPlayQueue()
                self.page.updatePointShowImageIndex()
            }
            
        }
        
        
    }
    
    
    //MARK: 播放队列.每0.01秒检测一次
    func launchPlayQueue() {
        
        page.playQueue.forEach { [unowned self] (p) in
            
            guard p.time == ddAudioPlayTimelyObserver else { return }
            //匹配成功
            switch p.launchType {
                
            case .defaultMode:   break
            case .showText:      self.showText(p.indexShowText.value!)    //显示 文本框
            case .openImage:     self.openImagesView()             //打开 浏览页面
            case .closeImage:    self.closeImagesView()            //关闭 浏览页面
            case .moveImagePage: self.moveImage(p.indexShowImage.value!)  //图片滚动
                
            }
            
            let realm = try! Realm()
            
            try! realm.write {
               p.launched = true
            }
            
        }
        
    }
    
    //MARK: 播放队列 时相关的方法
    func showText(_ index:Int) {
        let textView = self.page.ddTextViews[index]
        textView.alpha = 1.0
        textView.displayTextViewByTime()
    }
    
    func openImagesView() {
        
        imagesAttachView.photos = page.recordPhotos
        imagesAttachView.dismissButton.alpha = 1.0
        imagesAttachView.collectionView.isScrollEnabled = false
        imagesAttachView.collectionView.reloadData()
        view.bringSubview(toFront: imagesAttachView)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.imagesAttachView.alpha = 1.0
            }, completion: nil)
    }
    
    func closeImagesView() {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.imagesAttachView.alpha = 0.0
            }, completion: nil)
    }
    
    func moveImage(_ index:Int) {
        
        self.imagesAttachView.collectionView.scrollToItem(at: IndexPath(item:index, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
}

//MARK: 键盘,文本框适应
extension DDMakeCourseViewController {
    
    func setkeyBoardHelper() {
        
        
        keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            
            print("appear, \(keyboardHeight)\n")
            
            if let strongSelf = self {
                strongSelf.moveTextEditView(keyboardHeight,putUp: true)
                
                strongSelf.keyboardActive = true
                strongSelf.moveTextViewAndBackImageIfNeed(keyboardHeight,putUp:true)
                strongSelf.currentKeyBoardHeight = keyboardHeight
                
            }
        }
        
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            
            print("disappear \(keyboardHeight)\n")
            
            if let strongSelf = self {
                strongSelf.moveTextEditView(keyboardHeight,putUp: false)
                
                strongSelf.keyboardActive = false
                strongSelf.moveTextViewAndBackImageIfNeed(keyboardHeight,putUp:false)
                strongSelf.currentKeyBoardHeight = keyboardHeight
            }
        }
    }
    
    func moveTextEditView(_ keyboardHeight:CGFloat,putUp:Bool){
        
        //将编辑框至于子view最上层.
        view.bringSubview(toFront: textEditView)
        //向上,向下移动编辑框
        self.textEditViewBottomCons?.update(offset: putUp ? -keyboardHeight : 48)
        
    }
    
    
    func moveTextViewAndBackImageIfNeed(_ keyboardHeight:CGFloat,putUp:Bool) {
        
        //确保view的位置正常,保证动画出现.
        self.view.layoutIfNeeded()
        self.view.setNeedsFocusUpdate()
        //查看当前编辑的TextView的位置是否在键盘位置一下,注意加上文本编辑框的高度
        if putUp {
            
            //let textEditHeight = textEditView.frame.size.height
            let textEditHeight:CGFloat = 48
            
            //因为是bigContainerView的子View.所以算上它.
            guard let avtiveTextView = getTheActiveTextView() else {return}
            let bottomPoint    = avtiveTextView.frame.size.height + avtiveTextView.frame.origin.y + self.bigContainerView.frame.origin.y
            
            if bottomPoint > self.bigContainerView.frame.size.height - (keyboardHeight + textEditHeight)  {
                
            }
            else {
                moveHeight = 0
                return
            }
            
            //需要移动,计算移动高度,移动所有文本框和背景图片
            moveHeight =  bottomPoint - ( self.bigContainerView.frame.size.height - (keyboardHeight + textEditHeight))
        }
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            if putUp {
                self.bigContainerView.frame.origin.y -= self.moveHeight!
                
                //如果背景图将要离开最低高度,重置贴底.
                if self.bigContainerView.frame.origin.y + self.bigContainerView.frame.size.height <= self.textEditView.frame.origin.y {
                    self.bigContainerView.frame.origin.y = self.textEditView.frame.origin.y - self.bigContainerView.frame.size.height
                }
                
                self.bigContainerView.layoutIfNeeded()
                self.bigContainerView.setNeedsLayout()
            }
            else {
                self.bigContainerView.frame.origin.y = self.view.bounds.origin.y
                self.bigContainerView.layoutIfNeeded()
                self.bigContainerView.setNeedsLayout()
            }
            
            
        }) { (Bool) in
            self.moveHeight = 0
            if !putUp {
                self.animteTextEdit(false)
            }
            
        }
    }
}

extension DDMakeCourseViewController: DDTextViewDelegate {
    
    
    func DDTextViewTapped(_ textView: DDTextView) {
        
        //隐藏其他文本框的边框
        highLightActiveTextView(textView)
        if keyboardActive {
            moveTextViewAndBackImageIfNeed(currentKeyBoardHeight!, putUp: true)
        }
    }
    
    
    func DDTextViewSizeChanged(_ textView: DDTextView, height: CGFloat) {
        //文本框尺寸变化,检测,是否需要移动,不被键盘遮住,在键盘打开的情况下
        if keyboardActive {
           moveTextViewAndBackImageIfNeed(currentKeyBoardHeight!, putUp: true)
        }
        
    }
    
    func DDTextViewFadeBegin(_ currentIndex: Int) {
        
        let t = page.ddTextViews[currentIndex]
        print(ddRecordTimelyObserver)
        t.showTime.time = ddRecordTimelyObserver //这是一个写在DDRecordControl上的录音计时全局变量
        
    }
    
    func DDTextViewFadeCanceled(_ currentIndex: Int) {
        
        let t = page.ddTextViews[currentIndex]
        t.showTime.time = 0
    }
    
    func DDTextViewFadeEnded(_ currentIndex: Int) {
     
        let t = page.ddTextViews[currentIndex]
        print("第\(currentIndex)个view,已经记录:\(t.showTime.time)")
        
        t.hasShowTime = true
        t.moveDisable = true
        
        //更新播放队列.realm
        let point = TimeStamp()
        point.time = t.showTime.time
        point.indexShowText.value = currentIndex
        point.launchType = LaunchType.showText
        let realm = try! Realm()
        
        try! realm.write {
            page.playQueue.append(point)
        }
        
    }
    
    
    
    func DDTextViewBeginEdit(_ currentTextView: DDTextView) {

    }
    
    
    func DDTextViewBeginMove(_ textView: DDTextView, left: CGFloat, right: CGFloat) {
        //和所有文本框比较位置,有对齐的时候,出现参考线.
        var textViews = page.ddTextViews
        
        //移除在移动的文本框.
        textViews.removeObject(textView)
        
        //开始比较,在前后距离5pt内显示参考线.
        var i = 0
        textViews.forEach { [weak self] in
            
            let targetX = $0.frame.origin.x
            let targetWidth = $0.frame.size.width
            
            if left >= targetX - 2 && left <= targetX + 2 {
                
                i = 1
                self?.showCoordinateLine(targetX)
                
            }
            else if  right >= (targetX + targetWidth) - 2 && right <= (targetX + targetWidth) + 2 {
                
                i = 2
                self?.showCoordinateLine(targetX + targetWidth)
            }
            else {
                
                if i == 0 {
                   self?.dismissCoordinateLine()
                }
                
            }
        }
        
        
    }
    
    
    func DDTextViewEndMove(_ textView: DDTextView) {
        
        if coordinateLine.alpha == 1.0  &&  coordinateLine.superview == self.view {
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { 
                
                //判断是左对齐还是右对齐.(参考线和文本框中心点x比较.)
                if self.coordinateLine.frame.origin.x < textView.center.x {
                    //左对齐
                    textView.frame.origin.x = self.coordinateLine.frame.origin.x
                }
                else {
                    //右对齐
                    textView.frame.origin.x = self.coordinateLine.frame.origin.x - textView.frame.size.width
                }
                
                textView.layoutIfNeeded()
                
                }, completion: { (Bool) in
                    self.dismissCoordinateLine()
                    
            })
            
            
        }
    }
    
    
    func showCoordinateLine(_ x:CGFloat) {
        
        coordinateLine.frame = CGRect(x: x, y: 0, width: 1, height: screenHeight)
        view.addSubview(coordinateLine)
        view.insertSubview(coordinateLine, belowSubview: recordControl)
        
        coordinateLine.backgroundColor = UIColor.red
        
        coordinateLine.alpha = 1.0
    }
    
    
    func dismissCoordinateLine() {
        
        self.coordinateLine.alpha = 0.0
        self.coordinateLine.removeFromSuperview()
    }
}

//MARK: 文本框边界栏按钮
extension DDMakeCourseViewController: DDTextEditViewDelegate {
    
    //字号
    func TextEditViewFontButtonTap(_ buttonCenter: CGPoint) {
        // Show a pop view for color choose
        let startPoint = CGPoint(x: buttonCenter.x, y: textEditView.frame.origin.y + 10)
        
        let fontView = DDTextFontEditView.instanceFromNib()
        guard let textView = getTheActiveTextView() else {return}
        fontView.size = textView.fontSize //设置当前字号
        let width:CGFloat = screenWidth
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        
        let options = [
            .type(.up),
            .cornerRadius(8)
            ] as [PopoverOption]
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        popover.popoverColor = UIColor.white
        popover.sideEdge = 0.0 //边距
        popover.showBlackOverlay = true
        //TODO:这个展示系统要更换.
        popover.beiginShowHandler =  {
            
            delay(0.05, closure: {
                
                aView.addSubview(fontView)
                fontView.snp.makeConstraints({ (make) in
                    make.left.top.bottom.right.equalTo(aView)
                })
                
                popover.goOn()
            })
            
        }
        popover.show(aView, point:startPoint)
        
        fontView.fontSizeChangeHandler = { [weak self] (sizeIndex) in
            if let strongSelf = self {
                
                strongSelf.changeTextFontSize(sizeIndex)
                //popover.dismiss()
            }
            
        }
        
    }
    
    //颜色
    func TextEditViewColorButtonTap(_ buttonCenter: CGPoint) {
        // Show a pop view for color choose
        let startPoint = CGPoint(x: buttonCenter.x, y: textEditView.frame.origin.y + 10)

        let colorView = DDTextColorEditView.instanceFromNib()
        guard let textView = getTheActiveTextView() else {return}
        colorView.color = textView.color
        let width:CGFloat = screenWidth
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        
        let options = [
            .type(.up),
            .cornerRadius(8)
            ] as [PopoverOption]
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        popover.popoverColor = UIColor.white
        popover.sideEdge = 0.0 //边距
        popover.showBlackOverlay = true
        //TODO:这个展示系统要更换.
        popover.beiginShowHandler =  {
            
            delay(0.05, closure: {
                
                aView.addSubview(colorView)
                colorView.snp.makeConstraints({ (make) in
                    make.left.top.bottom.right.equalTo(aView)
                })
                
                popover.goOn()
            })
            
        }
        popover.show(aView, point:startPoint)
        
        
        
        colorView.colorTapHandler = { [weak self] (color) in
            // color choose 
            if let strongSelf = self {
                strongSelf.changeTextViewColor(color)
                
                popover.dismiss()
            }
        }
        
    }
    
    //动画
    func TextEditViewAnimationButtonTap(_ buttonCenter: CGPoint) {
        
        // Show a pop view for color choose
        let startPoint = CGPoint(x: buttonCenter.x, y: textEditView.frame.origin.y + 10 ) //加上箭头尺寸
        
        let animeView = DDTextAnimeEditView.instanceFromNib()
        
        guard let textView = getTheActiveTextView() else {return}
        
       
        animeView.animeIndex = textView.animeIndex
       
        if textView.hasShowTime {
            animeView.needCancel = false
        }
        else {
            animeView.needCancel = true
        }
        
        let width:CGFloat = screenWidth
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        
        let options = [
            .type(.up),
            .cornerRadius(8)
            ] as [PopoverOption]
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        popover.popoverColor = UIColor.white
        popover.sideEdge = 0.0 //边距
        popover.showBlackOverlay = true
        //TODO:这个展示系统要更换.
        popover.beiginShowHandler =  {
            
            delay(0.05, closure: {
                
                aView.addSubview(animeView)
                animeView.snp.makeConstraints({ (make) in
                    make.left.top.bottom.right.equalTo(aView)
                })
                
                popover.goOn()
            })
            
        }
        popover.show(aView, point:startPoint)
        
        
        
        animeView.animeButtonTapHandler = { [weak self] (index ) in
            // anime choose
            if let strongSelf = self {
                strongSelf.setTextShowAnime(index)
                strongSelf.previewTextAnime()
            }
        }
        
        
        animeView.cancelAnimeTapHandler = { [weak self] _ in
            //cancel anime
            if let strongSelf = self {
                strongSelf.cancelTextShowAnime()
            }
            
        }
        
    }
    
    
    func TextEditViewDeleteButtonTap() {
        
        // check if textView has text if so ,show alert 
        
        guard let textView = getTheActiveTextView() else {return}
        guard textView.hasShowTime else {
            
            deleteEdittingTextView()
            
            return
        }
        
        showTextEditAlert()
    }
    
    func TextEditViewEditTap() {
        guard let textView = getTheActiveTextView() else {return}
        textView.becomeFirstResponder()
    }
    
    func TextEditViewConfirmTap() {
        guard let textView = getTheActiveTextView() else {return}
        
        textView.resignFirstResponder()
    }
    
    func showTextEditAlert() {
        //TODO:!!这里的功能是否多余,另外,删除了文本这里并没删除对应的时间戳.
        let msg = "该文本将会在录音播放时显示,确认删除吗"
        let alert = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "删除", style: .destructive) { (UIAlertAction) in
            // Delete text view
            self.deleteEdittingTextView()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

}

extension DDMakeCourseViewController: DDRecordControlActionDelegate {
    
    func recordTap() {
        //显示倒计时
        countDownView.show(3)
        
        countDownView.countDownComplete = { [weak self] in
            self?.recordControl.recordBeigin()
        }
    }
    
    func recordBegin() {
        
        page.ddTextViews.forEach {
            
            guard !$0.hasShowTime else { return }
            //text 进入录音模式,只能左滑动
            //选择过动画的才能左滑动
            if $0.animeIndex != 0 {
                $0.state = .record
            }
            else {
                $0.alpha = 1.0
            }
            
        }

        
        addTextButton.alpha = 0.0
        
        photoButton.alpha = 0.0
        
        showPhotoButton.alpha = 1.0
        
        let count = page.recordPhotos.count
        if count > 0 {
            countDot.text = "\(count)"
            countDot.alpha = 1.0
        }
        
        
       // closeButton.alpha = 0.0
        
        // open iFlySpeech
        //iFlyhandler.start()
    }
    
    func recordFinished() {
        
        page.ddTextViews.forEach { $0.state = .edit  }
        
        addTextButton.alpha = 1.0
        photoButton.alpha = 1.0
        showPhotoButton.alpha = 0.0
        
        let count = page.recordPhotos.count
        if count > 0 {
            countDot.text = "\(count)"
            countDot.alpha = 1.0
        }
        
        // close iFlySpeech
        //iFlyhandler.stop()
    }
    
    func recordTryPlayBegin() {
        
        page.ddTextViews.forEach {
            
           
            if $0.animeIndex == 0 {
                $0.alpha = 1.0
            }
            else {
                $0.alpha = 0.0
            }
            
        }
        addTextButton.alpha = 0.0
        
        photoButton.alpha = 0.0
        
        showPhotoButton.alpha = 0.0
        
        countDot.alpha = 0.0
        
        //试播前，将图片重置到第一张，试播结束之后，回到原来位置
        guard page.recordPhotos.count > 0 else {return}
        moveImage(0)
        
    }
    
    func recordTryPlaying() {
        launchPlayQueue()
    }
    
    func recordTryPlayPaused() {
        
        
    }
    
    
    func trimmTryPalyBegin() {
        
        alertView = DDPlaypartRecordAlertView()
        view.addSubview(alertView!)
        alertView!.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(300)
        }
        
        
        
    }
    
    func trimmTryPlaying(_ time: Float, duration: Float) {
        
        page.playQueue.forEach {
            
           //试播,播放图片
            guard $0.time == time  && $0.launchType == LaunchType.moveImagePage else { return }
            
            let image = $0.imageInStamp!.image
            let index = $0.indexShowImage
            alertView?.changeImageViewImage(image, imageIndex: index.value! + 1)
            
        }
        
        let currentSeconds = Int(time)
        let currentMin = Int(currentSeconds / 60 )
        let currentSec = Int(currentSeconds - currentMin * 60)
        
        let totalSecond = Int(duration)
        let totalMin = Int(totalSecond / 60)
        let totalSec = Int(totalSecond - totalMin * 60)
        
        alertView!.timeTextLabel.text = String(format: "%02d:%02d/%02d:%02d", currentMin, currentSec,totalMin ,totalSec)
  
    }
    
    
    func trimmTryPlayEnd() {
        
        alertView?.removeFromSuperview()
        
    }
    
    //TODO:字幕处理,提示
    func shouldShowSubtitleView() {
        //跳转到字幕页面.
//        let vc = DDShowSubTitleViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        
//        vc.text = iFlyhandler.textForSubTitle
//        
//        presentViewController(nav, animated: true, completion: nil)
        
    }
    
}

extension DDMakeCourseViewController: DDRecordControlDelegate {
    
    func recordBeginWithLimmit() {
        
        DDAlert.alert(title: "提示", message: "录音时间达到60秒上限,请使用新的页面录制", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
    }
    
    func recordTimeAwayFromLimmit() {
        
        timeView.stopWarning()
    }
    
    func recordTimeReachLimmit() {
        
        //录音时长达到最高限制
        recordControl.recordOverLimmit()
    }
    
    func recordTimeUpdate(_ timeText: String, showWarning: Bool) {
        
        //展示倒计时警告.
        timeView.timeLabel.text = timeText
        
        if showWarning {
            timeView.timeLabel.text = timeText + "(\(recordControl.limmitSecond)s)"
            timeView.startWarning()
        }
        else {
            timeView.stopWarning()
        }
        
    }
    
    
    func recordImagePageEnable(_ enable: Bool) {
        
    }
    
    func recordCombinedComplete() {
        
        showHUDWithText("处理中...")
    }
    
    func recordTrimming() {
        
        highLightTimepointIfNeed()
    }
    
    func trimmedTimeConflictWithPlayQueue(_ trimStart: Float, trimEnd: Float) {
        //弹窗
        showTrimAlertViewIfNeed(trimStart, trimEnd: trimEnd)
    }
    
    
    func showTrimAlertViewIfNeed(_ trimStart: Float, trimEnd: Float) {
        //剪切的时间中包含播放队列时间点.提示用户如果删除,将删除时间戳.

        let msg = "剪切部分含有文本或者图片显示的时刻点,删除该部分,包含的显示内容的出现时间将重置."
        
        let alert = UIAlertController(title: "提示", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        
        let confirmAction = UIAlertAction(title: "删除", style: .destructive) { (UIAlertAction) -> Void in
            
            self.editImageQueuesBeforeTrimRecord(trimStart, endTime: trimEnd)
        }
        
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion: nil)
    }
    //在时间剪切前,先删除,处理,更新,时间戳,
    
    //剪切时包含图片.图片的时间戳直接移除.
    func editImageQueuesBeforeTrimRecord(_ starTime:Float,endTime:Float) {
        
        //收集所有打上冲突的时间戳.将冲突的时间戳移出队列.
        let realm = try! Realm()
        self.page.playQueue.forEach {
            
            //"关闭"时间戳会被打上冲突标记.但是并不删除它
            if  $0.conflictWithRecordTrim {
                
                //如果即将删除的这个点的下一个点就是"关闭"的时间戳,那么,将关闭的时间戳置于剪切开始的时间点上.
                //这里的开始时间加入是4.75.剪切之后由于误差,只有4.5s.那么关闭将不会触发.
                //再往前移动0.5秒的时间.
//                let nextIndex = self.page.playQueue.index(of: $0)! + 1
//                //确保nextIndex在数量范围内
//                if nextIndex <= self.page.playQueue.count - 1 {
//                    //且是"关闭"队列
//                    if (self.page.playQueue[nextIndex].launchType == LaunchType.closeImage ) {
//                        
//                        try! realm.write {
//                           self.page.playQueue[nextIndex].time = starTime - 0.5
//                            print("关闭时间重置为:\(starTime - 0.5)")
//                        }
//                        
//                    }
//                }
                
                let index = self.page.playQueue.index(of: $0)
                
                if $0.launchType == .closeImage {
                    //如果是关闭的时间点,不移除出播放队列
                }
                else {
                    try! realm.write {
                        self.page.playQueue.remove(at: index!)
                    }
                    
                    print("被移出的冲突时间点是:\($0.time)")
                    //如果是文本框时间点.
                    if  $0.launchType == .showText {
                        
                        //这个index是在textViews中的顺序
                        if let index = $0.indexShowText.value {
                            
                            try! realm.write {
                                
                                self.page.playQueue.forEach({ (textTimeStamp) in
                                    //更新时间戳中对应的文本框的index
                                    if let indexRemind = textTimeStamp.indexShowText.value {
                                        
                                        if indexRemind > index {
                                            
                                                //在数据库中操作
                                                textTimeStamp.indexShowText.value = indexRemind - 1
                                            
                                            
                                        }
                                        
                                    }
                                    
                                })
                            
                            }
                            
                        }
                        
                        
                    }
                    
                }
                 
                //处理文本框
                if  $0.launchType == .showText  {
                    
                    if let index = $0.indexShowText.value {
                        
                       deleteTextViewBy(index)
                    }
                    
                }
  
            }
        }
        
        
        try! realm.write {
            //将剪切起点之后的时间戳向前移动一段时间.
            self.page.playQueue.forEach {
                
                //如果是关闭时间的点
                //假如这里的开始时间加入是4.75.剪切之后由于误差,只有4.5s.那么关闭将不会触发.
                //再往前移动1.0秒的时间.
                
                //问题是,可能存在多个关闭时间戳,只对最后一个关闭时间戳做该处理(最后一个时间戳肯定是关闭类型)
                if $0 == self.page.playQueue.last {
                    $0.time = starTime - 1.0
                }
                else {
                    //这里的比较是大于.确保遗留下来的"关闭"的时间戳,不会被设置成错误的触发时间.
                    guard $0.time > starTime else { return }
                    
                    $0.time -= (endTime - starTime)
                }
                
            }
            
            //播放队列集合.更新
            self.page.updateImageQueuesWithPlayQueue()
            self.page.updatePointShowImageIndex()
        }
        
        self.recordControl.trimConfirmByUser()
        
    }
    
    
    
}

extension DDMakeCourseViewController:RMPZoomTransitionAnimating, RMPZoomTransitionDelegate {
    
    //MAKR: RMPZoomTransitionAnimating
    func transitionSourceImageView() -> UIImageView! {
        
        let imageView = UIImageView.init(image: themeImageView.image)
        imageView.contentMode = themeImageView.contentMode;
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = themeImageView.frame;
        return imageView
    }
    
    func transitionSourceBackgroundColor() -> UIColor! {
        return UIColor.white
    }
    
    func transitionDestinationImageViewFrame() -> CGRect {
        
        return themeImageView.frame
    }
    
    //MARK: RMPZoomTransitionDelegate
    
    func zoomTransitionAnimator(_ animator: RMPZoomTransitionAnimator!, didCompleteTransition didComplete: Bool, animatingSourceImageView imageView: UIImageView!) {
        
        themeImageView.image = imageView.image
    
    }
    
    
}



