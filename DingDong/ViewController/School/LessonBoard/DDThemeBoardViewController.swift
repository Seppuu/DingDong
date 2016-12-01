//
//  DDPublishPreviewViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/3/10.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import RealmSwift
import SnapKit
import RMPZoomTransitionAnimator

class DDThemeBoardViewController: BaseViewController,RAReorderableLayoutDelegate,RAReorderableLayoutDataSource , UIGestureRecognizerDelegate{

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var lesson: Lesson?
    
    var topTableView = ThemeBoardTopView()
    
    var maxPhotoCount = 6
    
    var tipsLabel = UILabel()
    
    var changeTipButton = UIButton()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        addTipLabel()
        
        //TODO:新建一个课程或者继续编辑选择过来的课程
        if lesson == nil {
            //新建
            createNewLeeson()
        }
        else {
            //继续编辑
            continueMakeLesson()
        }

    }
    
    func createNewLeeson() {
        lesson = Lesson()
        
        let page = Page()
        
        let realm = try! Realm()
        
        try! realm.write {
            lesson?.pages.append(page)
            realm.add(lesson!)
        }
        
        setCollectionView()
        createFileIfNeed(0, count: (lesson?.pages.count)!)
    }
    
    
    func continueMakeLesson() {
        
        setCollectionView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reloadSecondSectionData()
        
    }
    
    var animeMaker = TipsAnimeHandler()
    
    func addTipLabel() {
        
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(view).offset(-35)
            make.width.equalTo(screenWidth)
            make.height.equalTo(17)
        }
        
        tipsLabel.textAlignment = .center
        tipsLabel.textColor = UIColor ( red: 0.5098, green: 0.502, blue: 0.502, alpha: 1.0 )
        tipsLabel.font = UIFont.systemFont(ofSize: 17)
        setTip()
        
        view.addSubview(changeTipButton)
        changeTipButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-8)
            make.width.equalTo(view)
            make.height.equalTo(17)
        }
        changeTipButton.setTitle("换一个小提示", for: UIControlState())
        changeTipButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        changeTipButton.setTitleColor(UIColor ( red: 0.0, green: 0.4627, blue: 1.0, alpha: 1.0 ), for: UIControlState())
        changeTipButton.addTarget(self, action: #selector(DDThemeBoardViewController.changeTips), for: .touchUpInside)
     
        animeMaker.autoDoAnimeHandler =  { [weak self] in
            
            if let strongSelf = self {
                strongSelf.changeTips()
            }
        }
    }
    
    
    func changeTips() {
        
        animeMaker.doAnime(tipsLabel) {
            self.setTip()
        }
        
    }
    
    func setTip() {
        tipsLabel.text = Tips.sharedTips.tip
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animeMaker.addTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        animeMaker.stopTimer()
    }
    

    
    
    func setCollectionView() {
        
        let layout = RAReorderableLayout()
        layout.scrollDirection = .vertical
        
        let nib = UINib(nibName: "verticalCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor ( red: 0.9412, green: 0.9373, blue: 0.9608, alpha: 1.0 )
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()

    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let point = gestureRecognizer.location(in: self.collectionView)
        let clickView = self.collectionView.hitTest(point, with: nil)
        let viewClassName = NSStringFromClass((clickView?.classForCoder)!) 
        
        return !viewClassName.hasPrefix("UIView")
    }
    

    func createFile(_ start:Int,count:Int) {
        
        createFileIfNeed(start, count: count)
    }

    
    @IBAction func publishRecords(_ sender: UIBarButtonItem) {
        
        //check if all record has recorded
        for page in (lesson?.pages)! {
            if page.duration == "00:00" {
                // has record unrecorded 
                showUnableAlertMsg()
                return
            }
            
        }
        //show publish confirm alert msg
        comfirmRelease()
        
    }
    
    
    @IBAction func backCancelButtonTap(_ sender: UIBarButtonItem) {
      
        //自动保存进度.
        //TODO:先判断是否有recrod录音过,或者添加过图片,或者添加过文本.
        var shouldSave = false
        for page in (lesson?.pages)! {
            
            if page.samples.count > 0 || page.textViews.count > 0 || page.recordPhotos.count > 0 {
                shouldSave = true
            }
        }
        
        
        if shouldSave {
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            for page in (lesson?.pages)! {
                //delete the record file
                do {
                    try  FileManager.default.removeItem(at: page.audioDocURL!)
                    
                }catch _{
                    
                }
            }

            //TODO:删除空白数据.
            let realm = try! Realm()
            try! realm.write {
              lesson!.cascadingDeleteInRealm(realm)
            }
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    func showUnableAlertMsg() {
        let msg = "有图片未录音哦"
        let alert = UIAlertController(title: "提示", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func comfirmRelease() {
        
        self.saveTotalDuration()
        self.performSegue(withIdentifier: "goToAlbumPublish", sender: self)
//        let msg = ""
//        let alert = UIAlertController(title: "确认发布", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
//        
//        let confirmAction = UIAlertAction(title: "确定", style: .Default) { (alert:UIAlertAction)  in
//            
//            
//        }
//        let cancelAction = UIAlertAction(title: "取消", style: .Default ,handler: nil)
//        
//        
//        alert.addAction(confirmAction)
//        alert.addAction(cancelAction)
//        
//        presentViewController(alert, animated: true, completion: nil)
    }
    
    func removeAllMakeLessonDoc() {
        
        //delete MakeLesson Docs
        let makeLessonDocURL = FileManager.ddMakeLessonDocsURL()
        do {
            try  FileManager.default.removeItem(at: makeLessonDocURL!)
        }catch _{

        }
       
    }
    
    func saveTotalDuration() {
        var samplesCount = 0
        lesson!.pages.forEach {
            samplesCount +=  $0.samples.count
        }
        
        let timeStr = DDTimeLabelCounter.audioDurationBy(audioSamlesCount: samplesCount)
        
        let realm = try! Realm()
        
        try! realm.write {
            
            lesson!.duration = timeStr
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: RAReorderableLayout delegate datasource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let threePiecesWidth = floor(screenWidth / 3.0 - ((2.0 / 3) * 2))
        
        guard indexPath.section == 1 else {
            //section 0
            return CGSize(width: screenWidth, height: 44)
        }
        
        //section 1
        return CGSize(width: threePiecesWidth, height: threePiecesWidth)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 0, 15, 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard collectionView.dataSource != nil else {return CGSize.zero}
        
        if section == 0 {
            return CGSize(width: screenWidth, height: 15)
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard section == 0 else{
            
            return (lesson?.pages.count)! + 1
        }
        return 1
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.section == 1 else {
            
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "verticalCell", for: indexPath) as! RACollectionViewCell
            
            for view in cell.subviews  {
                if view.tag == 10 || view.tag == 11 || view.tag == 12 {
                    view.removeFromSuperview()
                }
            }
            
            cell.contentView.addSubview(topTableView)
            topTableView.snp.makeConstraints { (make) in
                make.left.right.top.bottom.equalTo(cell.contentView)
            }
            topTableView.backgroundColor = UIColor.brown
            let img1 = UIImage(named: "newPaper")!
            let img2 = UIImage(named: "PaperSetting")!
            let imgs = [img1,img2]
            
            let titles = ["稿纸"]
            let rightTitles = ["默认"]
            
            topTableView.setData(imgs, leftTitles: titles, secondTitles: rightTitles)
            
            topTableView.cellSelectedHandler = { [weak self] (cellIndex) in
                //TODO:tap handler
                if let strongSelf = self {
                    
                    let vc = DDPPTStyleViewController()
                    vc.themeSelected = (strongSelf.lesson?.theme)!
                    vc.styleSelectedHandler = { (theme) in
                        
                        let realm = try! Realm()
                        try! realm.write {
                            strongSelf.lesson?.theme = theme
                        }
                        let indexSet = IndexSet(integer: 1)
                        strongSelf.collectionView.reloadSections(indexSet)
                    }
                    
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
            
            return cell
        }
        
        
        //section = 1 cell
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "verticalCell", for: indexPath) as! RACollectionViewCell
        
        for view in cell.subviews  {
            if view.tag == 10 || view.tag == 11 || view.tag == 12 {
                view.removeFromSuperview()
            }
        }
        
        if (indexPath.row != lesson?.pages.count) {
            
            cell.imageView.kf.setImage(with: (lesson?.theme.imageUrl))
            let width = cell.frame.size.width
            let heigth = cell.frame.size.height
            //add a delete action view
            let deleteView = UIImageView(frame: CGRect(x: width * (3/4) - 3, y: 3, width: width * (1/4), height: width * (1/4)))
            deleteView.image = UIImage(named: "imageDelete")
            deleteView.contentMode = .scaleAspectFit
            deleteView.isUserInteractionEnabled = true
            deleteView.tag = 10
            let gesture = UITapGestureRecognizer(target: self, action: #selector(DDThemeBoardViewController.deletePhoto(_:)))
            deleteView.addGestureRecognizer(gesture)
            
            cell.addSubview(deleteView)
            
            
            //add a tint view
            let tintView = UIView(frame: CGRect(x:0 , y: heigth * (2/3), width: width, height: heigth * (1/3)))
            tintView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.438523706896551 )
            tintView.tag = 11
            cell.addSubview(tintView)
            
            //add a text state label
            let stateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: heigth * (1/3)))
            stateLabel.tag = 12
            stateLabel.center = tintView.center
            stateLabel.textColor = UIColor.white
            stateLabel.textAlignment = .center
            stateLabel.text = lesson?.pages[indexPath.row].duration
            cell.addSubview(stateLabel)
            
        }
        else  {
            cell.imageView.image = UIImage(named: "addImage")
        }
        if (lesson?.pages.count == maxPhotoCount && indexPath.row == lesson?.pages.count) {
            //照片到达规定数量之后,加号隐藏.
            cell.imageView.alpha = 0.0
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (lesson?.pages.count)! < maxPhotoCount && indexPath.row == (lesson?.pages.count)! {
            //此处为添加按钮.
            //打开模板选择界面.
            addNewBoard()
        }
        else {
           //放大,跳转.

            performSegue(withIdentifier: "makeCourse", sender: self)

        }
    }
    
    @objc(collectionView:canFocusItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if collectionView.numberOfItems(inSection: indexPath.section) <= 1 {
            return false
        }

        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if ((lesson?.pages.count)! < maxPhotoCount && indexPath.row == (lesson?.pages.count)! ) {
            return false
        }
        
        return true
    }
    func collectionView(_ collectionView: UICollectionView, atIndexPath: IndexPath, canMoveToIndexPath: IndexPath) -> Bool {
        if ((lesson?.pages.count)! < maxPhotoCount && canMoveToIndexPath.row == (lesson?.pages.count)! ) {
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, atIndexPath: IndexPath, didMoveToIndexPath toIndexPath: IndexPath) {
        
        let realm = try! Realm()
        
        try! realm.write {
            
            lesson?.pages.move(from: atIndexPath.item, to: toIndexPath.item)
            
        }
        
        
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 0.3
        }
    }
    
    func scrollTrigerPaddingInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.collectionView.contentInset.top, 0, self.collectionView.contentInset.bottom, 0)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAlbumPublish" {
            let newVC = segue.destination as! LessonReleaseViewController
            newVC.lesson = lesson!
           
        }
        else if segue.identifier == "makeCourse" {
            
            let lessonMakerVC = segue.destination as! DDMakeCourseViewController
            lessonMakerVC.transitioningDelegate = self
            
            //传值
            let selectedIndexPath = collectionView.indexPathsForSelectedItems![0]
            lessonMakerVC.recordControl.page = (lesson?.pages[selectedIndexPath.row])!
            lessonMakerVC.backImageURL = (lesson?.theme.imageUrl)!

        }
        
    }

    
    //MARK: Action
    func deletePhoto(_ sender:UITapGestureRecognizer) {
        
        //check if this photo has recorded
        let indexPath = self.collectionView.indexPathForItem(at: sender.location(in: self.collectionView))
        
        guard let page = lesson?.pages[(indexPath?.row)!] else {return}
        
        if page.duration != "00:00" {
            let msg = "删除模板同时会删除录音"
            let alert = UIAlertController(title: "提示", message:msg , preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            
            let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                
                self.confirmRemoveRecord(indexPath!)
            })
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            present(alert, animated: true, completion: nil)
        }
        else {
            confirmRemoveRecord(indexPath!)
        }
    }
    
    
    func confirmRemoveRecord(_ indexPath:IndexPath) {
        
        self.collectionView.performBatchUpdates({ () -> Void in
            let realm = try! Realm()
            
            //delete the record file
            if let page = self.lesson?.pages[indexPath.row] {
                page.deleteAudioFile()
            }
            
            
            try! realm.write {
                self.lesson?.pages.remove(at: (indexPath.row))
            }
            
            self.collectionView.deleteItems(at: [indexPath])
            
            }) { (success) -> Void in
                if (success) {
                    //change addPhoto cell being show
                    let path = IndexPath(row: (self.lesson?.pages.count)!, section: 1)
                    let cell = self.collectionView.cellForItem(at: path) as! RACollectionViewCell
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        cell.imageView.alpha = 1.0
                    })
                    
                    //检测如果,模板全部被删除了,自动添加一个新的.同时创建新的录音路径
                    guard self.lesson?.pages.count == 0 else { return }
                    
                    delay(0.3, closure: { () -> () in
                        DispatchQueue.main.async {
                            let realm = try! Realm()
                            try! realm.write {
                                self.lesson?.pages.append(Page())
                            }
                            
                            self.createFileIfNeed(0, count: (self.lesson?.pages.count)!)
                            self.reloadSecondSectionData()
                        }
                        
                        
                    })
                    
                    
                }
        }
    }
    
    
    //MARK: 顶部点击跳转.
    func topViewTap(_ index:Int) {
        
    }

}



extension DDThemeBoardViewController {

    
    func addNewBoard() {
        let start = self.lesson?.pages.count
        
        let realm = try! Realm()
        try! realm.write {
            let page = Page()
            self.lesson?.pages.append(page)
        }
        
        let count = self.lesson?.pages.count
        createFileIfNeed(start!, count: count!)//起点是之前的总数,count是添加之后的总数.
        
        reloadSecondSectionData()
        
    }
    
    func reloadSecondSectionData(){
        UIView.setAnimationsEnabled(false)
        collectionView.performBatchUpdates({
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }) { (Bool) in
            UIView.setAnimationsEnabled(true)
        }
    }
    
}


extension DDThemeBoardViewController {
    
    // MARK :移动,删除,图片之后,对应的文件路径要修改.
    
    func createFileIfNeed(_ startIndex:Int,count:Int){
        
        for i in startIndex..<count {
            //为每一个幻灯片页面创建一个Document - DingDong - School - MakeLesson - Records URL目录
            let uuid = self.lesson?.pages[i].id //每个文件的路径末尾是一个uuid.
            
            let _ = FileManager.ddLessonFileURL(uuid!)
        }
        
        // Document - DingDong - School - MakeLesson - Transfer URL目录
        // 创建中转站"transfer",在剪切音频的时候使用
        let _ = FileManager.ddTransferDocsURL()
        
        //创建存储波形图数组的文件
        let _ = FileManager.ddSamplesDocsURl()
        
    }
    
    
}

extension DDThemeBoardViewController: RMPZoomTransitionAnimating,RMPZoomTransitionDelegate,UIViewControllerTransitioningDelegate {
    
    //MARK: RMPZoomTransitionAnimating
    func transitionSourceImageView() -> UIImageView! {
        
        let selectedIndexPath = collectionView.indexPathsForSelectedItems![0]
        let cell = collectionView.cellForItem(at: selectedIndexPath) as! RACollectionViewCell
        let imageView = UIImageView.init(image: cell.imageView.image)
        
        imageView.contentMode = cell.imageView.contentMode;
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = cell.imageView.convert(cell.imageView.frame, to: collectionView.superview)
        return imageView
    }
    
    
    func transitionSourceBackgroundColor() -> UIColor! {
        return UIColor.white
    }
    
    func transitionDestinationImageViewFrame() -> CGRect {
        
        let selectedIndexPath = collectionView.indexPathsForSelectedItems![0]
        let cell = collectionView.cellForItem(at: selectedIndexPath) as! RACollectionViewCell
        let cellFrameInSuperview = cell.imageView.convert(cell.imageView.frame, to: collectionView.superview)
        return cellFrameInSuperview
    }
    
    
    //MARK: UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let sourceTransition: RMPZoomTransitionAnimating & RMPZoomTransitionDelegate = source as! DDThemeBoardViewController
        
        let destinationTransition: RMPZoomTransitionAnimating & RMPZoomTransitionDelegate = presented as!  DDMakeCourseViewController

        if sourceTransition.conforms(to: RMPZoomTransitionAnimating.self) &&
            destinationTransition.conforms(to: RMPZoomTransitionAnimating.self) {
            
            let animator = RMPZoomTransitionAnimator()
            animator.goingForward = true
            animator.sourceTransition = sourceTransition
            animator.destinationTransition = destinationTransition
            return animator
        }
        
        return nil
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let sourceTransition: RMPZoomTransitionAnimating & RMPZoomTransitionDelegate = dismissed as!  DDMakeCourseViewController
        
        let destinationTransition: RMPZoomTransitionAnimating & RMPZoomTransitionDelegate = self

        
        if sourceTransition.conforms(to: RMPZoomTransitionAnimating.self) &&
            destinationTransition.conforms(to: RMPZoomTransitionAnimating.self) {
            
            let animator = RMPZoomTransitionAnimator()
            animator.goingForward = true
            animator.sourceTransition = sourceTransition
            animator.destinationTransition = destinationTransition
            return animator
        }
        
        return nil
    }
    
}




class RACollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var gradientLayer: CAGradientLayer?
    var hilightedCover: UIView!
    override var isHighlighted: Bool {
        didSet {
            self.hilightedCover.isHidden = !self.isHighlighted
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.hilightedCover.frame = self.bounds
       // self.applyGradation(self.imageView)
    }
    
    fileprivate func configure() {
        self.imageView = UIImageView()
        self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        self.addSubview(self.imageView)
        
        self.hilightedCover = UIView()
        self.hilightedCover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.hilightedCover.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.hilightedCover.isHidden = true
        self.addSubview(self.hilightedCover)
    }
    
    fileprivate func applyGradation(_ gradientView: UIView!) {
        self.gradientLayer?.removeFromSuperlayer()
        self.gradientLayer = nil
        
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer!.frame = gradientView.bounds
        
        let mainColor = UIColor(white: 0, alpha: 0.3).cgColor
        let subColor = UIColor.clear.cgColor
        self.gradientLayer!.colors = [subColor, mainColor]
        self.gradientLayer!.locations = [0, 1]
        
        gradientView.layer.addSublayer(self.gradientLayer!)
    }
}
