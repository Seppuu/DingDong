//
//  AlbumCreateViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/21.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import CTAssetsPickerController
import RealmSwift
import IQKeyboardManagerSwift


class AlbumCreateViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var albumInfoTableView: UITableView!
    
    fileprivate let coverCellId     = "CoverAddCell"
    fileprivate let basicInfoCellId = "BasicInfoCell"
    fileprivate let segmentCellId   = "SegmentCell"
    fileprivate let switchCellId    = "SwitchCell"
    fileprivate let typeCellId      = "typeCell"
    fileprivate let pickerCellId    = "pickerCell"
    
    fileprivate let ProfileCellId   = "ProfileCell"

    var type = "营销" {
        didSet {
            
            switch type {
            case "营销": typeIndex = 1
            case "管理": typeIndex = 2
            case "财务": typeIndex = 3
            case "执行": typeIndex = 4
            case "专业": typeIndex = 5
            case "服务": typeIndex = 6
                
            default:
                break;
            }
            
        }
    }
    
    var typeIndex = 0
    
    var coverImage = UIImage()
    
    var hasConver = false
    
    var hasTitle = false
    
    var coverTitle = ""
    
    var showPicker = false
    
    var permissionIndex = 0
    
    var hud = MBProgressHUD()

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
        
        albumInfoTableView.delegate = self
        albumInfoTableView.dataSource = self
        
        
        albumInfoTableView.register(UINib(nibName: coverCellId, bundle: nil), forCellReuseIdentifier: coverCellId)
        albumInfoTableView.register(UINib(nibName: basicInfoCellId, bundle: nil), forCellReuseIdentifier: basicInfoCellId)
        albumInfoTableView.register(UINib(nibName: switchCellId, bundle: nil), forCellReuseIdentifier: switchCellId)
        albumInfoTableView.register(UINib(nibName: segmentCellId, bundle: nil), forCellReuseIdentifier: segmentCellId)
        albumInfoTableView.register(UINib(nibName: typeCellId, bundle: nil), forCellReuseIdentifier: typeCellId)
        
        albumInfoTableView.register(UINib(nibName: pickerCellId, bundle: nil), forCellReuseIdentifier: pickerCellId)
        
        albumInfoTableView.register(UINib(nibName: ProfileCellId, bundle: nil), forCellReuseIdentifier: ProfileCellId)
        

    }
    
    
    @objc fileprivate func creationConfirm() {
        
        //Check 
        if hasConver == false {
            DDAlert.alert(title: "提示", message: "请添加封面", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return
        }
        
        let indexPath = IndexPath(item: 1, section: 0)
        let titleCell = albumInfoTableView.cellForRow(at: indexPath) as! BasicInfoCell
        
        if titleCell.rightTextField.text == "" {
            DDAlert.alert(title: "提示", message: "请添加标题", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return
        }
        
        let indexPath2 = IndexPath(item: 0, section: 1)
        let profileCell = albumInfoTableView.cellForRow(at: indexPath2) as! ProfileCell
        
        if profileCell.profileTextView.text == "" {
            DDAlert.alert(title: "提示", message: "请添加简介", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return
        }
 
        createAlbum(titleCell.rightTextField.text!, profile: profileCell.profileTextView.text!)
        
    }

    func createAlbum(_ title:String,profile:String) {
        
        let album = Album()
        album.title = title
        album.permissionType = permissionIndex
        album.type = typeIndex
        album.intro = profile
        
        
        //make json dict
        let dict: JSONDictionary = [
            "name"       :album.title,
            "description":album.intro,
            "privacy"    :album.permissionType,
            "category"   :album.type,
            "token"      :defaultToken,
            "ssid"       :Defaults.userSSID.value!
        ]
        
        // hud here
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        
        
        NetworkManager.sharedManager.createAlbum(dict, coverImage: coverImage) { (success,json) in
            
            if success {
                self.hud.hide(animated: true)
                //服务器上传成功,保存到本地.
//                let realm = try! Realm()
//                album.id = json["dataInfo"]["id"].string!.toInt()!
//                album.coverUrl =  json["dataInfo"]["cover"].string!
//                    try! realm.write {
//                        
//                        realm.add(album)
//                }
                //back
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            
            return showPicker ? 6 : 5
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "简介"
        }
        else {
            return nil
        }
    }
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 0
//        }
//        else {
//            return 10
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        else if indexPath.section == 0 && indexPath.row == 5 {
            
            return 120
        }
        if indexPath.section == 1 {
            return 120
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                //封面
                let cell = tableView.dequeueReusableCell(withIdentifier: coverCellId) as! CoverAddCell
                
                cell.leftLabel.text = "专辑封面"
                
                cell.addLabel.alpha = hasConver ? 0.0 : 1.0
                
                cell.coverImageView.image = self.coverImage
                
                return cell
            }
            else if indexPath.row == 1 {
                //标题
                let cell = tableView.dequeueReusableCell(withIdentifier: basicInfoCellId) as! BasicInfoCell
                
                cell.leftLabel.text = "专辑标题"
                
                cell.rightTextField.placeholder = "添加"
                
                return cell
                
            }
            else if indexPath.row == 2 {
                //范围
                let cell = tableView.dequeueReusableCell(withIdentifier: segmentCellId) as! SegmentCell
                
                cell.segmentChangeHandler = { (selectIndex) in
                    self.permissionIndex = selectIndex
                    //print("许可Int:\(selectIndex)")
                }
                
                return cell
            }
            else if indexPath.row == 3 {
                //是否付费
                let cell = tableView.dequeueReusableCell(withIdentifier: switchCellId) as! SwitchCell
                cell.leftLabel.text = "是否付费"
                
                return cell
            }
            else if indexPath.row == 4 {
                //分类
                let cell = tableView.dequeueReusableCell(withIdentifier: typeCellId) as! typeCell
                cell.typeLabel.text = type
                
                return cell
            }
            else {
                
                //有picker
                let cell = tableView.dequeueReusableCell(withIdentifier: pickerCellId) as! pickerCell
                cell.titles = ["营销","管理","财务","执行","专业","服务"]
                cell.defaultTitle = self.type
                cell.titleSelectHandler = { selectName in
                    
                    //reload
                    self.type = selectName
                    let indexpath = IndexPath(row: 3, section: 0)
                    self.albumInfoTableView.reloadRows(at: [indexpath], with: .fade)
                }
                
                return cell
            }
            

            
        }
        else if indexPath.section == 1 {
            //简介
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCellId, for: indexPath) as! ProfileCell
            return cell
        }
        else {
            
            //创建专辑
            let cell = UITableViewCell()
            
            let confirmButton = UIButton(frame: CGRect(x: 0, y: 0, width: cell.ddWidth, height: cell.ddHeight))
            confirmButton.setTitle("创建专辑", for: UIControlState())
            confirmButton.setTitleColor(UIColor ( red: 0.2953, green: 0.5976, blue: 1.0, alpha: 1.0 ), for: UIControlState())
            confirmButton.addTarget(self, action: #selector(AlbumCreateViewController.creationConfirm), for: .touchUpInside)
            
            cell.contentView.addSubview(confirmButton)
            
            return cell
            
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //封面点击
        if indexPath.section == 0 && indexPath.row == 0 {
            
            CoverTap()
        }
        
        //分类点击
        if indexPath.section == 0 && indexPath.row == 4 {
            
            //open picker view
            showPicker = !showPicker
            let indexpath = IndexPath(row: 5, section: 0)
            let indexpath3 = IndexPath(row: 4, section: 0)
            if showPicker {
                
                albumInfoTableView.insertRows(at: [indexpath], with: .fade)
                
                
            }
            else {
                
                albumInfoTableView.deleteRows(at: [indexpath], with: .fade)
               
            }
            
             albumInfoTableView.reloadRows(at: [indexpath3], with: .none)
        }
        
    }
    
}

extension AlbumCreateViewController: CTAssetsPickerControllerDelegate {
    /**
     *  Tells the delegate that the user finish picking photos or videos.
     *
     *  @param picker The controller object managing the assets picker interface.
     *  @param assets An array containing picked `PHAsset` objects.
     *
     *  @see assetsPickerControllerDidCancel:
     */
    //MARK:相册代理
    public func assetsPickerController(_ picker: CTAssetsPickerController!, didFinishPickingAssets assets: [Any]!) {
        
        if let actualAsset = assets.first as? PHAsset {
            
            PhotoManager.sharedManager.getAssetThumbnail(actualAsset, completion: { (image) in
                self.coverImage = image
            })
            
        }
        
        self.hasConver = true
        let indexPath = IndexPath(row: 0, section: 0)
        self.albumInfoTableView.reloadRows(at: [indexPath], with: .fade)
        picker.dismiss(animated: true, completion: nil)
    }

    
    func CoverTap() {
        
        //打开相册.
        PHPhotoLibrary.requestAuthorization { (PHAuthorizationStatus) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                let picker = CTAssetsPickerController()
                picker.delegate = self
                picker.showsSelectionIndex = true
                self.present(picker, animated: true, completion: nil)
                
            })
        }
    }
    
    func assetsPickerController(_ picker: CTAssetsPickerController!, didSelect asset: PHAsset!) {
        
        for asset in picker.selectedAssets {
            picker.deselect(asset as! PHAsset)
        }
        
        picker.select(asset)
    }
    

    
    
}



