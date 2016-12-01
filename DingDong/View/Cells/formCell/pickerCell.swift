//
//  pickerCell.swift
//  DingDong
//
//  Created by Seppuu on 16/5/23.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class pickerCell: UITableViewCell,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var titles = [String]() {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    var defaultTitle = "" {
        
        willSet {
            defaultRow =  titles.index(of: newValue)!
            pickerView.selectRow(defaultRow, inComponent: 0, animated: false)
        }
    }
    
    var defaultRow = 0
    
    var titleSelectHandler:((_ title:String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return titles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        titleSelectHandler?(titles[row])
        
    }
    
    
}
