//
//  ChannelListViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/30.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChannelListViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var channelListTableView: UITableView!
    
    fileprivate let cellID = "ChannelListCell"
    
    var listOfAuthor = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "订阅的老师"
        
        let nib = UINib(nibName: cellID, bundle: nil)
        
        channelListTableView.register(nib, forCellReuseIdentifier: cellID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfAuthor.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChannelListCell
        
        cell.selectionStyle = .none
        
        let urlString = listOfAuthor[indexPath.row]["avator"].string!
        let url = URL(string: urlString)
        
        cell.avatarImageView.kf.setImage(with: url!)
        
        let name = listOfAuthor[indexPath.row]["name"].string!
        
        cell.channelNameLabel.text = name
        
        let newUpload = listOfAuthor[indexPath.row]["new_course"].bool!
        
        if (newUpload == true) {
            
            cell.newUploadCountLabel.text = "有更新"
        }
        else {
            cell.newUploadCountLabel.text = ""
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let authorID = listOfAuthor[indexPath.row]["user_id"].string!
        let authorName = listOfAuthor[indexPath.row]["name"].string!
        
        goToChannelWith(authorID, authorName: authorName)
        
    }
    
    func goToChannelWith(_ authorID:String,authorName:String) {
        
        let vc = UIStoryboard(name: "Channel", bundle: nil).instantiateViewController(withIdentifier: "ChannelViewController") as! ChannelViewController
        
        vc.authorID = authorID
        vc.authorName = authorName
        
        self.navigationController!.pushViewController(vc, animated: true)
        
    }

    
    
}
