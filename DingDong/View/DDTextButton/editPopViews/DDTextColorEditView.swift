//
//  DDTextColorEditView.swift
//  DingDong
//
//  Created by Seppuu on 16/4/7.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit

class DDTextColorEditView: UIView {

    
    
    @IBOutlet weak var blackView: UIView!
    
    
    @IBOutlet weak var redView: UIView!
    
    
    
    @IBOutlet weak var blueView: UIView!
    
    @IBOutlet weak var yellowView: UIView!
    
    
    @IBOutlet weak var greenView: UIView!
    
    
    var color:Colors = .Black
    
    var colorIndex:Int = 0 {
        didSet {
            color = Colors.allValues[colorIndex]
        }
    }
    var buttons = [UIView]()
    var colors: [UIColor] {
        var uicolors = [UIColor]()
        for color in Colors.allValues {
            
            uicolors.append(UIColor(hexString: color.rawValue))
        }
        
        return uicolors
    }
    class func instanceFromNib() -> DDTextColorEditView {

        return UINib(nibName: "DDTextColorEditView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DDTextColorEditView
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        
        makeUI()
        
        makeGesture()
    }
    
    
    func makeUI() {
        
        buttons = [blackView,redView,blueView,yellowView,greenView]
        
        
        for i in 0..<buttons.count {
            
            buttons[i].isUserInteractionEnabled = true
            
            // add color view
            let view = UIView()
            buttons[i].addSubview(view)
            buttons[i].backgroundColor = UIColor.white
            view.snp_makeConstraints({ (make) in
                make.center.equalTo(buttons[i])
                make.width.height.equalTo(26)
            })
            
            view.layer.cornerRadius = 26/2
            view.layer.masksToBounds = true
            view.backgroundColor = colors[i]
            
            
            // add a check view
            let checkView = UIImageView()
            checkView.image = UIImage(named: "ColorCheck")
            checkView.tag = 10
            checkView.contentMode = .scaleAspectFit
            buttons[i].addSubview(checkView)
            checkView.snp_makeConstraints({ (make) in
                make.center.equalTo(buttons[i])
                make.width.equalTo(16)
                make.height.equalTo(12)
            })
            checkView.alpha = 0.0
            
            
            if colorIndex == i {
                 checkView.alpha = 1.0
            }
           
            
        }
        
        
        
    }

    func makeGesture() {
        
        let blackTap = UITapGestureRecognizer(target: self, action: #selector(DDTextColorEditView.blackColorTap))
        blackView.addGestureRecognizer(blackTap)
        
        let redTap = UITapGestureRecognizer(target: self, action: #selector(DDTextColorEditView.redColorTap))
        redView.addGestureRecognizer(redTap)
        
        let blueTap = UITapGestureRecognizer(target: self, action: #selector(DDTextColorEditView.blueColorTap))
        blueView.addGestureRecognizer(blueTap)
        
        let yellowTap = UITapGestureRecognizer(target: self, action: #selector(DDTextColorEditView.yellowColorTap))
        yellowView.addGestureRecognizer(yellowTap)
        
        let greenTap = UITapGestureRecognizer(target: self, action: #selector(DDTextColorEditView.greenColorTap))
        greenView.addGestureRecognizer(greenTap)
    }
    
    var colorTapHandler: ((_ color:Colors) -> ())?
    
    func blackColorTap() {
        let index = buttons.index(of: blackView)
        highLightButton(index!)
        
    }
    
    func blueColorTap() {
        let index = buttons.index(of: blueView)
        highLightButton(index!)
        
    }
    
    func yellowColorTap() {
        let index = buttons.index(of: yellowView)
        highLightButton(index!)
        
    }
    
    func redColorTap() {
        let index = buttons.index(of: redView)
        highLightButton(index!)
        
    }
    
    func greenColorTap() {
        let index = buttons.index(of: greenView)
        highLightButton(index!)
        
    }
    
    
    func highLightButton(_ index:Int) {
        
        for i in 0..<buttons.count {
            
            buttons[i].viewWithTag(10)?.alpha = 0.0
            
            if i == index {
                buttons[i].viewWithTag(10)?.alpha = 1.0
                colorIndex = i
                colorTapHandler?(color)
            }
            
        }
        
    }
    
    
}


extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    
    
    class func DDRedTextColor() -> UIColor {
        return UIColor ( red: 0.871, green: 0.1177, blue: 0.1881, alpha: 1.0 )
    }
    
    class func DDBlueTextColor() -> UIColor {
        return UIColor ( red: 0.1551, green: 0.392, blue: 0.8671, alpha: 1.0 )
    }
    
    class func DDYellowTextColor() -> UIColor {
        return UIColor ( red: 0.991, green: 0.7971, blue: 0.2134, alpha: 1.0 )
    }
    
    class func DDGreenTextColor() -> UIColor {
        return UIColor ( red: 0.2163, green: 0.6077, blue: 0.2895, alpha: 1.0 )
    }
    
    
}

