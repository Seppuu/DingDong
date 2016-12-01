//
//  OrganizationCertificateViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/6/2.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import CTAssetsPickerController

class OrganizationCertificateViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let titles = ["营业执照","机构名称"]
    
    var hasConver = false
    var coverImage = UIImage()
    fileprivate let BasicInfoCellID = "BasicInfoCell"
    fileprivate let CoverAddCellID  = "CoverAddCell"
    fileprivate let SingleTapCellID = "SingleTapCell"
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "机构认证"
        
        let nib = UINib(nibName: BasicInfoCellID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BasicInfoCellID)
        
        let nib2 = UINib(nibName: CoverAddCellID, bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: CoverAddCellID)
        
        let nib3 = UINib(nibName: SingleTapCellID, bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: SingleTapCellID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CoverAddCellID, for: indexPath) as! CoverAddCell
                cell.leftLabel.text = titles[indexPath.row]
                
                if hasConver {
                    cell.addLabel.alpha = 0.0
                    cell.coverImageView.image = coverImage
                }
                else {
                    cell.addLabel.alpha = 1.0
                }
                
                return cell
                
            }
            else {

                let cell = tableView.dequeueReusableCell(withIdentifier: BasicInfoCellID, for: indexPath) as! BasicInfoCell
                cell.leftLabel.text = titles[indexPath.row]
                cell.rightTextField.placeholder = "填写"
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SingleTapCellID, for: indexPath) as! SingleTapCell
            cell.middleLabel.text = "审核"
            cell.middleLabel.textColor = UIColor ( red: 0.0, green: 0.502, blue: 1.0, alpha: 1.0 )
            return cell
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            coverTap()
        }
    }
    
    
}


extension OrganizationCertificateViewController: CTAssetsPickerControllerDelegate {
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
        self.tableView.reloadRows(at: [indexPath], with: .fade)
        picker.dismiss(animated: true, completion: nil)
        
    }

    
    func coverTap() {
        
        //打开相册.
        PHPhotoLibrary.requestAuthorization { (PHAuthorizationStatus) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                let picker = CTAssetsPickerController()
                picker.delegate = self
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
