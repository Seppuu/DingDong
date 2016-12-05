//
//  LessonsReleasedViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/9.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import RealmSwift

class LessonsReleasedViewController: BaseViewController {
    
    var lessonResutls = [Lesson]()
    var parentNavigationController:UINavigationController?
    var albums = [Album]()
    
    fileprivate let cellID = "ChannelCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        
        getAlbumsFromServer()
        
    }
    
    func setTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: cellID, bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: cellID)
        
    }
    
    
    func getAlbumsFromServer() {
        
        //可能是全新的app,或者设备,从后台获取数据,保存到本地.
        NetworkManager.sharedManager.getMyAlbumList({ (success,json,error) in
            
            if success == true {
                
                if let jsonArr = json?.array {
                    self.albums = JsonManager.sharedManager.saveAlbumListInRealm(with: jsonArr)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
                
                
            }
            else {
                
                self.getAlbumsFormRealm()
            }
        })
        
    }
    
    
    func getAlbumsFormRealm() {
        
            guard let realm = try? Realm() else {return}
            
            self.albums = Array(realm.objects(Album.self))
            if self.albums.count > 0 {
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func albumTap(_ index:Int) {
        
        let album = albums[index]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AlbumCellTap), object: album)
    }
    
}

extension LessonsReleasedViewController : UITableViewDataSource,UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return albums.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChannelCell
        let album = self.albums[indexPath.row]
        cell.selectionStyle = .none
        let url = URL(string: album.coverUrl)!
        cell.coverImageView.kf.setImage(with: url)
        
        cell.nameLabel.text = album.title
        
        cell.detailLabel.text = album.intro
        
        cell.moreButton.alpha = 0.0
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        albumTap(indexPath.item)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "共\((albums.count))个专辑课程"
    }
    
    
}





