//
//  DDAlbumPublishViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/3/13.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import RealmSwift
import KeyboardMan
import IQKeyboardManagerSwift

class LessonReleaseViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    
    @IBOutlet weak var infoTableView: UITableView!
    
    fileprivate let titleCellId = "BasicInfoCell"
    
    fileprivate let albumCellId = "typeCell"
    
    fileprivate let confirmCellId = "SingleTapCell"
    
    fileprivate let releaseColor = UIColor ( red: 1.0, green: 0.2464, blue: 0.2688, alpha: 1.0 )
    
    fileprivate let saveLocalColor = UIColor ( red: 0.5475, green: 0.5985, blue: 1.0, alpha: 1.0 )
    
    var blackOverlay = UIControl()
    
    var hasConver = false
    
    var keyboardMan = KeyboardMan()
    
    var album = Album()
    
    var lesson = Lesson()
    
    var hud = MBProgressHUD()
    
    let maxPhotoCount = 1
    
    var keyBoardActive = false
    
    var converImage = UIImage()
    
    var hasAlbum = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.sharedManager().enable = false
    }
    
    func setTableView() {
        
        let nib1 = UINib(nibName: titleCellId, bundle: nil)
        let nib2 = UINib(nibName: albumCellId, bundle: nil)
        let nib3 = UINib(nibName: confirmCellId, bundle: nil)
        
        infoTableView.register(nib1, forCellReuseIdentifier: titleCellId)
        
        infoTableView.register(nib2, forCellReuseIdentifier: albumCellId)
        
        infoTableView.register(nib3, forCellReuseIdentifier: confirmCellId)

    }

    func albumLabelTap() {
        
        //TODO:
        openAlbumSelectView()
    }
    
    func openAlbumSelectView() {
        
        let sheet = DDPopSheetView()
        let albumTableView = AlbumSelectView(frame: CGRect(x: 0, y: screenHeight - 200, width: screenWidth, height: 200))
        sheet.containerView = albumTableView
        
        sheet.show()
        
        albumTableView.createAlbumTap = {
            sheet.dismiss()
            self.performSegue(withIdentifier: "AlbumCreate", sender: nil)
        }
        
        albumTableView.albumSelect = { [weak self] (album) in
            
            self?.album = album
            self?.hasAlbum = true
            sheet.dismiss()
            
            let indexPath = IndexPath(item: 1, section: 0)
            let albumCell = self?.infoTableView.cellForRow(at: indexPath) as! typeCell
            
            albumCell.typeLabel.text = self?.album.title
            
        }
        
    }
    
    func removeMakeLessonDoc() {
        let url = FileManager.ddMakeLessonDocsURL()
        do {
            try  FileManager.default.removeItem(at: url!)
        }catch _{
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    fileprivate func upLoadAlbum() {
        let indexPath = IndexPath(item: 0, section: 0)
        
        let titleCell = infoTableView.cellForRow(at: indexPath) as! BasicInfoCell
        
        if titleCell.rightTextField.text == "" && titleCell.rightTextField.placeholder == "未命名" {
            DDAlert.alert(title: "提示", message: "请添加标题", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return
        }
        
        if hasAlbum == false {
            
            DDAlert.alert(title: "提示", message: "请添加专辑", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            
            let fieldText = titleCell.rightTextField.text!
            let placeHolder = titleCell.rightTextField.placeholder!
            
            lesson.name = titleCell.rightTextField.text! == "" ? placeHolder : fieldText
            
            lesson.album = self.album
            
            lesson.released = false
        }
        
        showHud()
        
        
        let (jsonDict,imageDict,audioDict) = JsonManager.sharedManager.getWholeLessonDict(with: lesson)
        
        NetworkManager.sharedManager.uploadLesson(jsonDict, imageDict: imageDict, audioDict: audioDict,progress: { (progress) in
            
            self.doSomeWorkWithProgress(progress)
        
        }) { (success) in
            
            if success {
               // delete realm data
                try! realm.write {
                    self.lesson.cascadingDeleteInRealm(realm)
                }
                
                //hide hud
                self.hideHud()
                
                //这里是一个好时机,记录,该用户上传过课程.
                Defaults.hasLessonUpload.value = true
            }
            else {
                //TODO:failed should do something
                self.showFailedHud()
                
            }
            
            
        }
        
    }
    
    func showHud() {
        hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "上传中.."
    }
    
    func showFailedHud() {
        hud.label.text = "上传失败.."
        hud.hide(animated: true, afterDelay: 2.0)
    }
    
    func hideHud() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
            // Do something useful in the background and update the HUD periodically.
            DispatchQueue.main.async(execute: {
                self.hud.hide(animated: true)
                
                //add a noti
                let noti = NotificationCenter.default
                noti.post(name: Notification.Name(rawValue: DDShouldGoToMyAlbumWithDelay), object: self)
                
                //go to myAlbum vc
                self.navigationController?.popToRootViewController(animated: true)
                
            })
        })
    }
    
    func saveToLocal() {
        
        //TODO:将标题保存下来,如果用户编辑了.
        let indexPath = IndexPath(item: 0, section: 0)
        
        guard let titleCell = infoTableView.cellForRow(at: indexPath) as? BasicInfoCell else {
            return
        }
        
        if titleCell.rightTextField.text == "" {
            DDAlert.alert(title: "提示", message: "请添加标题", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            
            lesson.name = titleCell.rightTextField.text!
            
            lesson.released = false
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func doSomeWorkWithProgress(_ progress:Float) {
        //self.canceled = NO;
        // This just increases the progress indicator in a loop.
        
        if (progress <= 1.0) {

            DispatchQueue.main.async(execute: {
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                self.hud.progress = progress
                
                })
        }
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AlbumCreate" {
            
        }
    }
    
    
    //MARK: TableView method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 2 {
//            return 5
//        }
//        else {
//            return 20
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: titleCellId, for: indexPath) as! BasicInfoCell
            
            cell.leftLabel.text = "课程标题"
            if lesson.name == "" {
                cell.rightTextField.placeholder = "未命名"
            }
            else {
                cell.rightTextField.placeholder = lesson.name
            }
            
            return cell
        }
        else if  indexPath.section == 0 &&  indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: albumCellId, for: indexPath) as! typeCell
            cell.leftLabel.text = "所属专辑"
            cell.typeLabel.text = "选择"
            
            return cell
        }
        else if indexPath.section == 1  &&  indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: confirmCellId, for: indexPath) as! SingleTapCell
            cell.middleLabel.text = "发布课程"
            cell.middleLabel.textColor = releaseColor
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: confirmCellId, for: indexPath) as! SingleTapCell
            cell.middleLabel.text = "暂存本地"
            cell.middleLabel.textColor = saveLocalColor
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            //专辑选择
            albumLabelTap()
        }
        else if indexPath.section == 1 &&  indexPath.row == 0 {
            //课程发布
            upLoadAlbum()
        }
        else if indexPath.section == 1 &&  indexPath.row == 1{
            //暂存本地
            saveToLocal()
        }
        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.view.endEditing(true)
    }
    
}
