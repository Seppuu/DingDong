//
//  ChannelViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/30.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChannelViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var channelTableView: UITableView!
    
    fileprivate let cellID = "ChannelCell"
    
    var authorID = ""
    
    var authorName = "" {
        didSet {
            title = authorName
        }
    }
    
    var albums = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
        
        getDataWith(authorID)
        
        changeBarItemTitle()
    }

    func setCollectionView() {
        
        //delegate 设置在storyboard中完成了
        let nib = UINib(nibName: cellID, bundle: nil)
        channelTableView.register(nib, forCellReuseIdentifier: cellID)
 
    }
    
    func getDataWith(_ authorID:String) {
        
        guard let id = authorID.toInt() else {return}
        
        NetworkManager.sharedManager.getAuthorAlbumListWith(id) { [weak self] (success, json, error) in
            
            if success {
                if let jsonArr = json?.array {
                    
                    if let strongSelf = self {
                        
                        strongSelf.albums = jsonArr
                        
                        strongSelf.channelTableView.reloadData()
                    }
                    
                }
                //TODO:Failed handerl
            }
            else {
                //TODO:Failed handerl
            }
            
        }
        
    }
    
    
    func goToWorksViewControllerWith(_ albumID:String,albumName:String) {
        
        let dict: JSONDictionary = [
            "id":albumID.toInt()!,
            "name":albumName
        ]
        
        performSegue(withIdentifier: "WorksViewSegue", sender: dict)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "WorksViewSegue" {
            let vc = segue.destination as! WorksViewController
            let dict = sender as! JSONDictionary
            
            let user = User.currentUser()
            
            vc.isUserSelf = user?.id == authorID ? true :false
            vc.albumID = dict["id"] as! Int
            vc.albumName = dict["name"] as! String
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChannelCell
        
        cell.selectionStyle = .none
        
        let urlString = albums[indexPath.row]["cover"].string!
        let url = URL(string: urlString)
        
        cell.coverImageView.kf.setImage(with: url!)
        
        cell.nameLabel.text = albums[indexPath.row]["name"].string!
        
        cell.detailLabel.text = albums[indexPath.row]["description"].string!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let id = albums[indexPath.row]["album_id"].string!
        let name = albums[indexPath.row]["name"].string!
        goToWorksViewControllerWith(id, albumName: name)
        
    }

}
