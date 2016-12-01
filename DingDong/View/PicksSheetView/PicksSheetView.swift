//
//  PicksSheetView.swift
//  DingDong
//
//  Created by Seppuu on 16/5/25.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class PicksSheetView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var tableView:UITableView!
    
    fileprivate let sheetCellId = "SheetCell"
    
    fileprivate let titles = ["分享","取消"]
    
    var deleteRecordHandler:(()->())?
    
    var shareTapHandler:(()->())?
    
    var cancelHandler:(()->())?
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setTableView()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    
    func setTableView() {
        
        tableView = UITableView(frame:self.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        
        tableView.register(UINib(nibName: sheetCellId, bundle: nil), forCellReuseIdentifier: sheetCellId)
        addSubview(tableView)
        
        tableView.reloadData()
    }
    
    
    //MARK: TableView
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: sheetCellId) as! SheetCell
        
        cell.iconImageView.backgroundColor = UIColor.brown
        cell.titleLabel.text = titles[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            shareTapHandler?()
           
        }
        else if indexPath.row == 1 {
            cancelHandler?()
        }
    }
    
    
    
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
