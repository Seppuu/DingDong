//
//  DDTextEditView.swift
//  DingDong
//
//  Created by Seppuu on 16/4/5.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit


protocol DDTextEditViewDelegate {
    
    func TextEditViewFontButtonTap(_ buttonCenter:CGPoint)
    
    func TextEditViewColorButtonTap(_ buttonCenter:CGPoint)
    
    func TextEditViewAnimationButtonTap(_ buttonCenter:CGPoint)
    
    func TextEditViewDeleteButtonTap()
    
    func TextEditViewEditTap()
    
    func TextEditViewConfirmTap()
}


class DDTextEditView: UIView {
    
    var delegate:DDTextEditViewDelegate?
    
    @IBOutlet weak var fontButton: UIButton!
    
    @IBOutlet weak var colorButton: UIButton!
    
    @IBOutlet weak var animationButton: UIButton!
    
    
    @IBOutlet weak var deleteButton: UIButton!
    
    
    @IBOutlet weak var editConfirmButton: UIButton!
    
    class func instanceFromNib() -> DDTextEditView {
        
        return UINib(nibName: "DDTextEditView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DDTextEditView
    }
    
    
    var buttons = [UIButton]()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        buttons.append(fontButton)
        buttons.append(colorButton)
        buttons.append(animationButton)
        buttons.append(deleteButton)
        buttons.append(editConfirmButton)
        
        makeUI()
        
        self.backgroundColor = UIColor.ddTextEditButtonsBackColor()
    }
    
    func makeUI() {
        
        buttons.forEach {
            
            $0.backgroundColor = UIColor.ddTextEditButtonsBackColor()
            $0.setTitleColor(UIColor.ddTextEditButtonDeHighLightColor(), for: UIControlState())
            
        }
        
    }
    
    @IBAction func fontTap(_ sender: UIButton) {
        delegate?.TextEditViewFontButtonTap(sender.center)
        deHighLightOtherButton(sender)
    }
    
    
    
    @IBAction func colorTap(_ sender: UIButton) {
        delegate?.TextEditViewColorButtonTap(sender.center)
        deHighLightOtherButton(sender)
    }
    
    
        
    @IBAction func animationButtonTap(_ sender: UIButton) {
        delegate?.TextEditViewAnimationButtonTap(sender.center)
        deHighLightOtherButton(sender)
    }
    
    
    
    @IBAction func deleteTap(_ sender: UIButton) {
        delegate?.TextEditViewDeleteButtonTap()
        deHighLightOtherButton(sender)
    }
    
    
    //只有"收起"
    @IBAction func editConfirmTap(_ sender: UIButton) {
        
        changeButtonTitleForLast()
        deHighLightOtherButton(sender)
    }
    
    //更改"确认","编辑"按钮标题
    func changeButtonTitleForLast(){
        
        delegate?.TextEditViewConfirmTap()
        //editConfirmButton.setTitle("编辑", forState: .Normal)
    
    }
    
    
    
    func deHighLightOtherButton(_ button:UIButton) {
        
        buttons.forEach {
            
            $0.setTitleColor(UIColor.ddTextEditButtonDeHighLightColor(), for: UIControlState())
        }
        
        button.setTitleColor(UIColor.ddTextEditButtonHighLightColor(), for: UIControlState())
    }
    
    
}
