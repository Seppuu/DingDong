//
//  classificationViewController.swift
//  DingDong
//
//  Created by Seppuu on 16/2/19.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class CategoriesViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    
    @IBOutlet weak var categoriesTableView: UITableView!
    var parentNavigationController : UINavigationController?
    var titles = ["营销","管理","财务","执行","专业","服务"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARk: tableView 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cell"
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        cell.selectionStyle = .none
        cell.textLabel?.text = titles[indexPath.item]
        
        return cell
    }
    
    
    

}
