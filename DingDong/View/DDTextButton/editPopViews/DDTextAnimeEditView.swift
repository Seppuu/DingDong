//
//  DDTextAnimeEditView.swift
//  DingDong
//
//  Created by Seppuu on 16/4/8.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DDTextAnimeEditView: UIView {
    
    
    @IBOutlet weak var firstAnimeButton: UIButton!
    
    @IBOutlet weak var secondAnimeButton: UIButton!
    
    @IBOutlet weak var thirdAnimeButton: UIButton!
    
    
    @IBOutlet weak var fourthAnimeButton: UIButton!
   
    var animeIndex:Int = 0
    var buttons = [UIButton]()
    let buttonTitles = ["渐现","掉落","划变","放大","缩放"]
    var needCancel = true //默认开启"取消"模式
    
    @IBOutlet weak var fifthAnimeButton: UIButton!
    
    var animeButtonTapHandler:((_ animeIndex:Int)->())?
    
    var cancelAnimeTapHandler:(() -> ())?
    
    class func instanceFromNib() -> DDTextAnimeEditView {
        
        return UINib(nibName: "DDTextAnimeEditView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DDTextAnimeEditView
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        
        makeUI()
    }
    
    func makeUI() {
        
        buttons = [firstAnimeButton,secondAnimeButton,thirdAnimeButton,fourthAnimeButton,fifthAnimeButton]
        
        //设置默认高亮,如果有的话.
        for i in 0..<buttons.count {
            
            buttons[i].setTitleColor(UIColor.ddTextEditButtonDeHighLightColor(), for: UIControlState())
            buttons[i].backgroundColor = UIColor.white
            buttons[i].setTitle(buttonTitles[i], for: UIControlState())
            
            if  animeIndex != 0 &&  i == animeIndex {
                
                
                if needCancel {
                    buttons[i].setTitleColor(UIColor.ddTextEditButtonHighLightColor(), for: UIControlState())
                    buttons[i].setTitle("无动画", for: UIControlState())
                }
                else {
                    //有时间点,无法取消,必选一个模式.
                    buttons[i].setTitleColor(UIColor.ddTextEditButtonHighLightColor(), for: UIControlState())
                    
                    
                }
            }

        }
    }
    
    
    @IBAction func firstTap(_ sender: UIButton) {
        let index = buttons.index(of: firstAnimeButton)
        highLightButton(index!)
        
    }
    
    
    @IBAction func secondTap(_ sender: UIButton) {
        let index = buttons.index(of: secondAnimeButton)
        highLightButton(index!)
    }
    
    
    
    @IBAction func thirdTap(_ sender: UIButton) {
        let index = buttons.index(of: thirdAnimeButton)
        highLightButton(index!)
    }
    
    
    

    @IBAction func fourthTap(_ sender: UIButton) {
        let index = buttons.index(of: fourthAnimeButton)
        highLightButton(index!)
    }
    
    
    
    @IBAction func fifthTap(_ sender: UIButton) {
        let index = buttons.index(of: fifthAnimeButton)
        highLightButton(index!)
    }
    
    
    
    
    func highLightButton(_ index:Int) {
        
        for i in 0..<buttons.count {
            
            buttons[i].setTitleColor(UIColor.ddTextEditButtonDeHighLightColor(), for: UIControlState())
            buttons[i].setTitle(buttonTitles[i], for: UIControlState())
            if i == index {
                
                //如果点击的是已经点击高亮着的,并且此时是可以取消的模式,则关闭高亮,是取消命令
                if i == animeIndex - 1 && animeIndex != 0 && needCancel {
                    
                    buttons[i].setTitleColor(UIColor.ddTextEditButtonDeHighLightColor(), for: UIControlState())
                    animeIndex = 0
                    cancelAnimeTapHandler?()
                    
                }
                else {
                    //不管是不是可以取消的模式,用户点击的是不同的选项.
                    buttons[i].setTitleColor(UIColor.ddTextEditButtonHighLightColor(), for: UIControlState())
                    buttons[i].setTitle("无动画", for: UIControlState())
                    //由于animeType中有"无动画" 在枚举中是0,所以,这里.所有的其他的title向后+1
                    animeIndex = i + 1
                    animeButtonTapHandler?(animeIndex)
                }
            }
            
        }
        
    }
    
    

}
