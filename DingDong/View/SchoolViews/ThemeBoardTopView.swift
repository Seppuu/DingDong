//
//  ThemeBoardTopView.swift
//  DingDong
//
//  Created by Seppuu on 4/11/16.
//  Copyright © 2016 seppuu. All rights reserved.
//

import UIKit

class ThemeBoardTopView: UIView ,UITableViewDelegate,UITableViewDataSource{
    
    var tableView: UITableView!
    
    var leftImages = [UIImage]()
    var titles = [String]()
    var rightTitles = [String]()
    
    var cellSelectedHandler:((_ cellIndex:Int)->())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setTableView()
    }

    func setData(_ leftImgs:[UIImage],leftTitles:[String],secondTitles:[String]) {
        leftImages = leftImgs
        titles = leftTitles
        rightTitles = secondTitles
        
    }
    
    func setTableView() {
        
        tableView = UITableView(frame: self.bounds, style: .plain)
        self.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor ( red: 1.0, green: 0.323, blue: 0.3586, alpha: 1.0 )
        tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.selectionStyle = .none
        
        cell.imageView?.image = leftImages[indexPath.item]
        cell.textLabel?.text = titles[indexPath.item]
        cell.detailTextLabel?.text = rightTitles[indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        cellSelectedHandler?(indexPath.item)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
