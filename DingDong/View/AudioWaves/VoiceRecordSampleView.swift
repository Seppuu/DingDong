//
//  VoiceRecordSampleView.swift
//  Yep
//
//  Created by nixzhu on 15/11/25.
//  Copyright © 2015年 Catch Inc. All rights reserved.
//

import UIKit

class VoiceRecordSampleCell: UICollectionViewCell {

    var value: Float = 0 {
        didSet {
            if value != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    var color = UIColor(red: 171/255.0, green: 181/255.0, blue: 190/255.0, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()

        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(bounds.width)
        context?.setLineCap(.round)

        let x = bounds.width / 2
        let height = bounds.height
        let valueHeight = height * CGFloat(value) + 6
        let offset = (height - valueHeight) / 2

       // print("分贝值:\(value)")
        
        
        //这里的是波形样式是中间点对称.
        context?.move(to: CGPoint(x: x, y: height - offset))
        context?.addLine(to: CGPoint(x: x, y: height - valueHeight - offset))
        
        //这里的波形样式是从底部开始,显示一半.
//        CGContextMoveToPoint(context, x, height  )
//        CGContextAddLineToPoint(context, x, height - valueHeight)

        context?.strokePath()
    }
}

class VoiceRecordSampleView: UIView {

    var sampleValues: [Float] = []

    var passColor = false
    lazy var sampleCollectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets.zero
        layout.itemSize = CGSize(width: 4, height: 60)
        layout.scrollDirection = .horizontal
        return layout
    }()

    lazy var sampleCollectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.sampleCollectionViewLayout)
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.clear
        view.dataSource = self
        view.register(VoiceRecordSampleCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        makeUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        sampleCollectionViewLayout.itemSize = CGSize(width: 4, height: sampleCollectionView.bounds.height)
    }

    func makeUI() {

        addSubview(sampleCollectionView)
        sampleCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let views = [
            "sampleCollectionView": sampleCollectionView,
        ]

        let sampleCollectionViewConstraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[sampleCollectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let sampleCollectionViewConstraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[sampleCollectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)

        NSLayoutConstraint.activate(sampleCollectionViewConstraintH)
        NSLayoutConstraint.activate(sampleCollectionViewConstraintV)
    }


    //var initialScrollDone = false
    func appendSampleValue(_ value: Float) {
        sampleValues.append(value)
        
        let indexPath = IndexPath(item: sampleValues.count - 1, section: 0)
        sampleCollectionView.insertItems(at: [indexPath])
        
        
        //每0.25秒触发一次,每0.25秒向右移动一次.
        let cells = sampleCollectionView.visibleCells
        
        guard cells.count + 1 < sampleValues.count else {return}
        makeAnime()
    }
    
    func makeAnime() {
        
        let contentOffsetX = self.sampleCollectionView.contentOffset.x
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
            
            //6 是一个cell宽度
            self.sampleCollectionView.contentOffset = CGPoint(x: contentOffsetX + 6, y: 0)
            
            }, completion: nil)
        
    }
    
    
    func reset() {
        sampleValues = []
        sampleCollectionView.reloadData()
    }
    
    //新增的,删除.
    func removeSampleValues(_ start:Int,end:Int){
        sampleCollectionView.performBatchUpdates({ () -> Void in
            let total = self.sampleValues.count
            
            self.sampleValues.removeSubrange(start...end)
            let removeCount = total - self.sampleValues.count
           
            
            var indexPathArr = [IndexPath]()
            for index in 0 ..< removeCount {
                let path = IndexPath(item: index + start, section: 0)
                indexPathArr.append(path)
            }
            
            self.sampleCollectionView.deleteItems(at: indexPathArr)
            
            }, completion: nil)
        
        
    }
    
}

extension VoiceRecordSampleView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleValues.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VoiceRecordSampleCell

        let value = sampleValues[indexPath.item]
        if (passColor) {
            cell.color = UIColor ( red: 1.0, green: 0.3036, blue: 0.3245, alpha: 1.0 )
        }
        else {
            cell.color = UIColor.ddWaveDefaultColor()
        }
        cell.value = value

        return cell
    }
}

