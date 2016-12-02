//
//  DDWaveView.swift
//  DingDong
//
//  Created by Seppuu on 16/4/2.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SnapKit


protocol DDWaveViewDelegate {
    
    func DDWaveViewIndicatorIsMovingWhenPlay(_ beginIndex:Int)
    func DDWaveViewIndicatorIsMovingWhenTrim()
    func DDWaveViewSamplesInTrim(_ cellIndex:Int)
    func DDWaveViewSamplesNotInTrim(_ cellIndex:Int)
}

class DDWaveView: UIView {
    
    var sampleView: VoiceRecordSampleView!
    var indicatorView: UIImageView!
    var delegate:DDWaveViewDelegate!
    var indicatorViewCenterXCons: Constraint? = nil
    var scrollToRightTimer:Timer?
    var scrollToLeftTimer:Timer?
    var pauseTimeTooSmall = false
    /// 波形图第一个cell的位置
    var firstItemX:CGFloat = 0.0
    var aInt = 0
    var offSetXWhenTrim :CGFloat = 0.0
    var trimEndCellIndex:Int = 0
    var startCellIndex:Int = 0
    var pauseEndCellIndex:Int = 0
    var sampleValuesForPlay : [Float] = []

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        makeUI()
        
        backgroundColor = UIColor.red
    }
    
    func makeUI() {
        
        sampleView = VoiceRecordSampleView()
        addSubview(sampleView)
        sampleView.snp_makeConstraints { (make) -> Void in
            make.left.top.right.bottom.equalTo(self)
        }
        
        sampleView.backgroundColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 )
        
        //滑动的线
        indicatorView = UIImageView()
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make)  in
            indicatorViewCenterXCons =  make.centerX.equalTo(self).constraint
            make.center.equalTo(sampleView)
            make.height.equalTo(sampleView)
            make.width.equalTo(100)
        }
        
        indicatorView.image = UIImage(named: "voice_indicator")
        indicatorView.contentMode = .scaleAspectFit
        indicatorView.backgroundColor = UIColor.clear
        indicatorView.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(_:)))
        indicatorView.addGestureRecognizer(panGesture)
        
        indicatorView.alpha = 0.0 //默认隐藏
    }
    
    func refreshSampleView(_ itemWidth:CGFloat,lineSpacing:CGFloat,sampleVals:[Float]) {
        
        sampleView.reset()
        sampleView.passColor = false
        sampleView.sampleCollectionViewLayout.itemSize = CGSize(width:itemWidth, height: sampleView.bounds.height)
        sampleView.sampleCollectionViewLayout.minimumLineSpacing = lineSpacing
        sampleView.sampleValues = sampleVals
        sampleView.sampleCollectionView.reloadData()
    }
    
    func appendSampleValue(_ vals:Float) {
        
        sampleView.appendSampleValue(vals)
    }
    
    func resetSampleView() {
        
        sampleView.reset()
    }
    
    func panAction(_ sender:UIPanGestureRecognizer) {
        
        
        let point = sender.translation(in: self)
        
        //如果剪切的时间点太小,向右移动波形图.
        if (pauseTimeTooSmall) {
            
            //像左边移动
            if ((sender.view?.center.x)! + point.x <= firstItemX) {
                
                sender.view?.center.x = firstItemX
            }
            else  {
                sender.view?.center = CGPoint(x: (sender.view?.center.x)! + point.x, y: (sender.view?.center.y)!)
            }
            
            //向右边移动
            if (sender.view?.center.x)! + point.x >= self.frame.size.width - 4*(4+2) {
                sender.view?.center.x = self.frame.size.width - 4*(4+2)
            }
            
            sender.setTranslation(CGPoint.zero, in: self)
            
            //获取指示器所在位置对于cell的位置.
            let cellIndexX = (sender.view?.center.x)! + sampleView.sampleCollectionView.contentOffset.x
            self.getBeginCellIndex(cellIndexX)
            
            return
        }
        
        
        if (aInt == 0) {
            offSetXWhenTrim = sampleView.sampleCollectionView.contentOffset.x
            aInt = 1
        }
        
        guard (sender.view?.center.x)! + point.x <= self.frame.size.width - 4*(4+2) else  {
            if (scrollToLeftTimer == nil) {
                scrollToLeftTimer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(self.scrollLeft(_:)), userInfo: nil, repeats: true)
            }
            
            return
        }
        
        guard  (sender.view?.center.x)! + point.x >= 0 else {
            if (scrollToRightTimer == nil) {
                scrollToRightTimer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(self.scrollRight(_:)), userInfo: nil, repeats: true)
            }
            
            return
        }
        
        scrollToRightTimer?.invalidate()
        scrollToRightTimer = nil
        
        scrollToLeftTimer?.invalidate()
        scrollToLeftTimer = nil
        sender.view?.center = CGPoint(x: (sender.view?.center.x)! + point.x, y: (sender.view?.center.y)!)
        
        sender.setTranslation(CGPoint.zero, in: self)
        
        //获取指示器所在位置对于cell的位置.
        let cellIndexX = (sender.view?.center.x)! + sampleView.sampleCollectionView.contentOffset.x
        self.getBeginCellIndex(cellIndexX)
    }
    
    func scrollRight(_ timer:Timer) {
        
        let currentOffsetX = sampleView.sampleCollectionView.contentOffset.x
        
        guard currentOffsetX > 0.0 else {
            sampleView.sampleCollectionView.setContentOffset(CGPoint(x:0.0, y: 0), animated: false)
            let x = self.indicatorView.center.x + currentOffsetX
            self.getBeginCellIndex(x)
            timer.invalidate()
            return
        }
        
        sampleView.sampleCollectionView.setContentOffset(CGPoint(x: currentOffsetX - 2, y: 0), animated: false)
        
        let x = indicatorView.center.x + currentOffsetX
        self.getBeginCellIndex(x)
    }
    
    func scrollLeft(_ timer:Timer) {
        let currentOffsetX = sampleView.sampleCollectionView.contentOffset.x
        guard currentOffsetX < offSetXWhenTrim else {
            sampleView.sampleCollectionView.setContentOffset(CGPoint(x:offSetXWhenTrim, y: 0), animated: false)
            
            let x = indicatorView.center.x + currentOffsetX
            self.getBeginCellIndex(x)
            timer.invalidate()
            return
        }
        
        sampleView.sampleCollectionView.setContentOffset(CGPoint(x: currentOffsetX + 2, y: 0), animated: false)
        
        let x = indicatorView.center.x + currentOffsetX
        self.getBeginCellIndex(x)
    }
    
    func getBeginCellIndex(_ positionX:CGFloat) {
        //let beginIndex:CGFloat = positionX/(4+2)
        //通过所在位置得到cellIndex
        let y = sampleView.sampleCollectionView.frame.origin.y
        var point = CGPoint(x: positionX, y: y)
        
        var cellIndexPath = sampleView.sampleCollectionView.indexPathForItem(at: point)
        
        if let actualIndexPath = cellIndexPath {
            //通知控制台,更新时间.当剪切指示器滑动时
            delegate.DDWaveViewIndicatorIsMovingWhenPlay(actualIndexPath.item)
        }
        else {
            // nil 的原因是,指示器所在的位置时间隔区域,做一次调整,将位置向左移动2pt,确保X位置在cell位置.
            point = CGPoint(x: positionX - 2, y: y)
            cellIndexPath = sampleView.sampleCollectionView.indexPathForItem(at: point)
            //通知控制台,更新时间.当剪切指示器滑动时
            delegate.DDWaveViewIndicatorIsMovingWhenPlay(cellIndexPath!.item)
            
        }

    }
    
    
    //试听颜色渐变
    func updateWaveViewColor(_ currentSeekIndex:Int) {
        //波形图变色.
        for i in 0..<sampleView.sampleValues.count {
            
            if let cell:VoiceRecordSampleCell =  sampleView.sampleCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? VoiceRecordSampleCell {
                if i <= currentSeekIndex {
                    
                    cell.color = UIColor.ddWavePlayedColor()
                }
                else {
                    
                    cell.color = UIColor.ddWaveDefaultColor()
                }
            }
            
        }
        
    }
    
    
    //剪切颜色渐变.
    func updateMiddleWaveViewColor(_ beginIndex:Int,endIndex:Int) {
        
        
        for index in 0..<(endIndex - beginIndex + 1) {
            //着色
            if  let cell:VoiceRecordSampleCell =  sampleView.sampleCollectionView.cellForItem(at: IndexPath(item: index + beginIndex, section: 0)) as? VoiceRecordSampleCell {
                
                cell.color = UIColor.ddWaveTrimmedColor()
                
                delegate.DDWaveViewSamplesInTrim(index + beginIndex)
                
            }
        }
        
        for index in 0..<beginIndex {
            //默认色
            if let cell:VoiceRecordSampleCell =  sampleView.sampleCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VoiceRecordSampleCell {
                
                cell.color = UIColor.ddWaveDefaultColor()
                delegate.DDWaveViewSamplesNotInTrim(index)
                
            }
        }
        
        
        delegate.DDWaveViewIndicatorIsMovingWhenTrim()//通知总控制台,正在滑动波形图,检测是否需要高亮冲突组件.
    }
    
    func resetSamplePosition() {
        
        sampleView.sampleCollectionView.scrollToItem(at: IndexPath(item:0, section: 0), at: .left, animated: false)
        //颜色重置
        for i in 0..<sampleView.sampleValues.count {
            
            if let cell:VoiceRecordSampleCell =  sampleView.sampleCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? VoiceRecordSampleCell {

                    cell.color = UIColor.ddWaveDefaultColor()
                
            }
            
        }
    }
    
    //挑选特别的波显示不同的颜色.
    func setColorForSingleCell(_ cellIndex:Int,color:UIColor) {
        
        let cell =  sampleView.sampleCollectionView.cellForItem(at: IndexPath(item: cellIndex, section: 0)) as! VoiceRecordSampleCell
        
        cell.color = color
    }
    
   
}
