//
//  AlbumSelectView.swift
//  DingDong
//
//  Created by Seppuu on 16/5/20.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class AlbumSelectView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var tableView:UITableView!
    
    fileprivate let albumCell = "AlbumSelectCell"
    
    var createAlbumTap:(() -> ())?
    
    var albumSelect:((_ album:Album) -> ())?
    
    var albums = [Album]()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
       
        
        
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
         setTableView()
        //ask for server first , then realm
        getAlbumsFromServer()
    }
    
    func setTableView() {
        
        tableView = UITableView(frame:self.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: albumCell, bundle: nil), forCellReuseIdentifier: albumCell)
        addSubview(tableView)
        tableView.reloadData()
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

        let realm = try! Realm()
        
        self.albums = Array(realm.objects(Album.self))
        
        if self.albums.count > 0 {
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: albumCell) as! AlbumSelectCell
        
        if indexPath.section == 0 {
            //新建专辑cell,借用一下 AlbumSelectCell
            cell.albumImageView.image = UIImage(named: "albumCreate")
            cell.albumLabel.text = "新建专辑"
            
        }
        else {
            let urlString = albums[indexPath.row].coverUrl
            cell.albumImageView.kf.setImage(with: (URL(string: urlString)!))
            cell.albumLabel.text = albums[indexPath.row].title
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //TODO:noti select
        if indexPath.section == 0 {
            createAlbumTap!()
        }
        else {
            let album = albums[indexPath.row]
            albumSelect?(album)
        }
    }
    
    
    

}
