//
//  LessonUnreleasedViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/5/9.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import RealmSwift

class LessonsUnreleasedViewController: BaseViewController {
    
    var parentNavigationController : UINavigationController?

    var lessonResutls = [Lesson]()
    fileprivate let cellID = "ChannelCell"
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        
        getAlbumsFormRealm()
        
    }
    
    func setTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: cellID, bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: cellID)

        
    }
    
    func getAlbumsFormRealm() {
        //guard let realm = realm else {return}
        
            
            let realm = try! Realm()
        
            //let dd = NSPredicate(format: "released == false")
            self.lessonResutls = Array(realm.objects(Lesson.self).filter("released == false"))
            if self.lessonResutls.count > 0 {
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    
    func sendLessonToEdit(_ index:Int) {
        
        let lesson = lessonResutls[index]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UnreleasedVCTap), object: lesson)
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToLesson" {
            
            let newVC = segue.destination as! PlayingLessonViewController
            newVC.lesson = sender as! Lesson
        }
        
    }
    
}

extension LessonsUnreleasedViewController : UITableViewDataSource,UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return lessonResutls.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChannelCell
        
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.coverImageView.backgroundColor = UIColor ( red: 0.8539, green: 0.8539, blue: 0.8539, alpha: 1.0 )
        
        cell.nameLabel.text = "未发布课程\(indexPath.row)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: lessonResutls[indexPath.row].created)
        
        cell.detailLabel.font = UIFont.systemFont(ofSize: 14)
        cell.detailLabel.text = "创建于:" + dateString
        
        cell.moreButton.alpha = 0.0
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sendLessonToEdit(indexPath.row)
    }
    
    
    
}



