//
//  WorksViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/31.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SwiftyJSON

class WorksViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var worksTableView: UITableView!
    
    fileprivate let cellID = "WorkCell"
    
    var lessons:[JSON] =  [JSON]()
    
    var albumID = 0
    
    var albumName = "" {
        didSet {
            title = albumName
        }
    }
    
    var isUserSelf = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: cellID, bundle: nil)
        
        worksTableView.register(nib, forCellReuseIdentifier: cellID)
        
        getLessonsFromServer()
        
        changeBarItemTitle()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getLessonsFromServer() {
        
        NetworkManager.sharedManager.getOneAlbumLessonListwith(isUserSelf, albumID: albumID) { (success, json, error) in
            
            if success == true {
                if let jsonArr = json?.array {
                    self.lessons = jsonArr
                    self.worksTableView.reloadData()
                }
                
            }
            else {
                
            }
            
            
        }
    
    }
    
    
    func goToPlay(_ id:String) {
        let lessonID = id
        performSegue(withIdentifier: "goToPlayLesson", sender: lessonID)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "goToPlayLesson" {
            let vc = segue.destination as! PlayingLessonViewController
            vc.lessonID = sender as! String
            
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "共\(lessons.count)个视频"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! WorkCell
        cell.selectionStyle = .none
        let json = lessons[indexPath.row]
        let urlString = json["cover"].string!
        let url = URL(string: urlString)
        cell.coverImageView.kf.setImage(with: url!)
        cell.coverImageView.contentMode = .scaleAspectFill
        cell.coverImageView.clipsToBounds = true
        cell.menuLabel.alpha = 0.0
        cell.statusLabel.alpha = 0.0
        
        //该状态只有在 我的发布 中显示
        if isUserSelf {
            //TODO:"待审核" "已上传"
            cell.statusLabel.alpha = 1.0
            cell.statusLabel.font = UIFont.systemFont(ofSize: 14)
            cell.statusLabel.text = lessons[indexPath.item]["status_text"].string!
            
            let status = lessons[indexPath.item]["status"].string!
            
            switch status {
            case "-2"://未通过
                cell.statusLabel.textColor = UIColor.red
            case "0","1"://待审核,审核中
                break
                //cell.statusLabel.textColor = UIColor.redColor()
            case "2"://已通过
                cell.statusLabel.textColor = UIColor.red
            default:
                break
            }
        }
        
        cell.titleLabel.text = lessons[indexPath.item]["name"].string!
        
        cell.timeLabel.text = lessons[indexPath.item]["duration"].string!
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = lessons[indexPath.item]["course_id"].string!
        goToPlay(id)
    }

}
