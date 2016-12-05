//
//  DDRecordControl.swift
//  DingDong
//
//  Created by Seppuu on 16/3/17.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import RealmSwift

var kAudioFileName = ""

@objc protocol  DDRecordControlDelegate {
    
    func recordCombinedComplete()
    
    func trimmedTimeConflictWithPlayQueue(_ trimStart:Float,trimEnd:Float)
    
    func recordTrimming()
    
    func recordTimeUpdate(_ timeText:String,showWarning:Bool)
    
    func recordTimeReachLimmit()
    
    func recordTimeAwayFromLimmit()
    
    @objc optional func recordSecondsCount(_ currentSeconds:Int)
}


@objc protocol DDRecordControlActionDelegate {
    
    @objc optional func recordBeginWithLimmit()
    
    @objc optional func recordTap() //按下了录音
    
    @objc optional func recordBegin()
    
    @objc optional func recordFinished()
    
    @objc optional func recordTryPlayBegin()
    
    @objc optional func recordTryPlayPaused()
    
    /**
     每0.01秒触发一次的播放监控.
     */
    @objc optional func recordTryPlaying()
    
    /**
     剪切时的试播开始
     */
    @objc optional func trimmTryPalyBegin()
    
    /**
     剪切时的试播进行中.
     */
    @objc optional func trimmTryPlaying(_ time:Float,duration:Float)
    
    /**
     剪切时的试播结束
     */
    @objc optional func trimmTryPlayEnd()
    
    /**
     通知总控制台展示字幕
     */
    @objc optional func shouldShowSubtitleView()
}


class DDRecordControl: UIView {
    
    var FileRecordedNumber = 0
    
    var page = Page() {
        
        didSet {
            setAudioHelperHandler() //设置音频处理助手
            self.sampleValues.removeAll()
            for sample in page.samples {
                
                self.sampleValues.append(sample.sample)
            }
        }
        
    }
    
    var delegate:DDRecordControlDelegate!
    var buttonDelegate:DDRecordControlActionDelegate!
    
    //当前录音文件的地址
    var audioPathURL:URL {
        get {
            
            let url = page.audioDocURL
            if let actualURL = FileManager.ddRecordURLWithName(url!, name: kAudioFileName) {
                return actualURL
            }
            
            return URL(string: "")!
        }
    }
    
    //MARK: 控制台按钮
    var microButton       = UIButton()
    
    var saveLessonButton  = UIButton()
    
    var buttonContainer   = UIView()
    
    var timeLabel         = UILabel()
    
    var tryPlayButton     = UIButton()
    
    var tryPlaySlider     = UISlider()
    
    var trimButton        = UIButton()
    
    var trimCancelButton  = UIButton()
    
    var trimConfirmButton = UIButton()
    
    var deleteTextViewShowTime = false
    
    // 波形图
    var waveView:DDWaveView!
    var waveViewBottomConstraint:Constraint? = nil
    
    //试听 timer
    fileprivate var playbackTimer: Timer? {
        didSet {
            if let oldPlaybackTimer = oldValue {
                oldPlaybackTimer.invalidate()
            }
        }
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        makeUI()
    }
    
    func makeUI() {
        
        timeLabel.alpha = 0.0
        
        makeWaveViewUI()

        makeTryPlaySliderUI()
        
        makeButtonContainerUI()

    }
    
    
    func makeWaveViewUI() {
        //波形图
        waveView = DDWaveView()
        addSubview(waveView)
        waveView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            waveViewBottomConstraint = make.bottom.equalTo(self.snp.bottom).constraint
            make.height.equalTo(48 * 2)
        }
        
        waveView.delegate = self
    }
    
    func makeTryPlaySliderUI() {
        //滑块
        addSubview(tryPlaySlider)
        tryPlaySlider.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(waveView.snp.top).offset(-5)
            make.height.equalTo(10)
        }
        
        tryPlaySlider.addTarget(self, action: #selector(DDRecordControl.tryPlaySliderValueChanged(_:)), for: .valueChanged)
        tryPlaySlider.thumbImage(for: UIControlState())
        tryPlaySlider.setThumbImage(UIImage(named: "ThumbImage"), for: UIControlState())
        tryPlaySlider.minimumTrackTintColor = UIColor ( red: 1.0, green: 0.2124, blue: 0.2869, alpha: 1.0 )
        tryPlaySlider.maximumTrackTintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 )
        tryPlaySlider.alpha = 0.0
        
    }
    
    func makeButtonContainerUI() {
        //"播放" "录音" "剪辑"
        addSubview(buttonContainer)
        buttonContainer.isUserInteractionEnabled = true
        buttonContainer.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(48)
        }
        buttonContainer.backgroundColor = UIColor ( red: 0.9566, green: 0.9565, blue: 0.9565, alpha: 1.0 )
        
        
        
        let buttonHeight:CGFloat = 40
        let buttonWidth :CGFloat  = 43
        buttonContainer.addSubview(tryPlayButton)
        buttonContainer.addSubview(microButton)
        buttonContainer.addSubview(trimButton)
        
        buttonContainer.addSubview(trimCancelButton)
        buttonContainer.addSubview(trimConfirmButton)
        
        let leftMargin = screenWidth * (42/375)
        let rightMargin = screenWidth * (42/375)
        
        //播放按钮
        addSubview(tryPlayButton)
        tryPlayButton.snp.makeConstraints { (make) in
            make.left.equalTo(buttonContainer.snp.left).offset(leftMargin)
            make.centerY.equalTo(buttonContainer.snp.centerY)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        tryPlayButton.setImage(UIImage(named: "recordPlay"), for: UIControlState())
        tryPlayButton.addTarget(self, action: #selector(DDRecordControl.playWholeFile), for: .touchUpInside)
        
        //录音按钮
        microButton.snp.makeConstraints { (make) in
            
            make.center.equalTo(buttonContainer)
            make.width.equalTo(43)
            make.height.equalTo(40)
        }
        
        microButton.setImage(UIImage(named: "recordMic"), for: UIControlState())
        microButton.addTarget(self, action: #selector(DDRecordControl.voiceRecord), for: .touchUpInside)
        
        //剪辑按钮
        trimButton.snp.makeConstraints { (make) in
            make.right.equalTo(buttonContainer.snp.right).offset(-rightMargin)
            make.centerY.equalTo(buttonContainer.snp.centerY)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        
        trimButton.setImage(UIImage(named: "recrodTrim"), for: UIControlState())
        trimButton.addTarget(self, action: #selector(DDRecordControl.trimTapped), for: .touchUpInside)
        
        
        //"取消"按钮,和"剪辑"一个位置
        trimCancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(buttonContainer.snp.right).offset(-rightMargin)
            make.centerY.equalTo(buttonContainer.snp.centerY)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        trimCancelButton.alpha = 0.0
        trimCancelButton.setTitle("取消", for: UIControlState())
        trimCancelButton.setTitleColor(UIColor ( red: 0.5216, green: 0.5569, blue: 0.6, alpha: 1.0 ), for: UIControlState())
        trimCancelButton.addTarget(self, action: #selector(DDRecordControl.trimCancel), for: .touchUpInside)
        
        //剪辑"确认"按钮,和"录音"一个位置.
        trimConfirmButton.snp.makeConstraints { (make) in
            make.center.equalTo(buttonContainer)
            make.width.equalTo(43)
            make.height.equalTo(40)
        }
        trimConfirmButton.alpha = 0.0
        trimConfirmButton.setTitle("确认", for: UIControlState())
        trimConfirmButton.setTitleColor(UIColor ( red: 0.8861, green: 0.0364, blue: 0.0, alpha: 1.0 ), for: UIControlState())
        trimConfirmButton.addTarget(self, action: #selector(DDRecordControl.firstTimetrimConfirm), for: .touchUpInside)

    }

    
    
    // MARK: Action
    
    
    //MARK: 试听 , 选播
    var audioPlayForTrim:AVAudioPlayer?//剪辑时选播的播放者
    
    var currentPlayTime:Double = 0.0 //播放部分音频
    
    var updateTimerInPlay:Timer!
    
    var fireCount:Float = 0.0
    
    var audioSeconds:Int = 0
    
    
    var audioDuration:TimeInterval = 0.0
    
    //试听 和 选播 共用 一个button 事件
    func playWholeFile() {
        
        if state == .trimmingRecord {
            //选播 起点和终点时间,以及持续时间.
            let beginTime = TimeInterval(self.startSec)
            
            self.playAudioSlected(beginTime)
        }
        else if (state == .finishRecord || state == .playing || state == .playPausing )  {
            //全局"播放"
            self.tryPlaySlider.alpha = 1.0
            
            self.playRecord()
        }
        
    }
    
    //选播
    func playAudioSlected(_ beginTime:TimeInterval){
        //开始播放.
        //先跳到开始位置.
        currentPlayTime = beginTime
        playAPartOfAudio()
        fireCount = Float(beginTime)
        Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(DDRecordControl.playSomeSoundsFire(_:)), userInfo: nil, repeats: true)
    }
    
    
    func playAPartOfAudio() {
        
        //因为播放前多个文件已经合并到一个.所以锁定播放路径.
        kAudioFileName = "record0"
        voiceFileURL = self.audioPathURL
        
        guard let voiceFileURL = voiceFileURL else {
            return
        }
        
        if AVAudioSession.sharedInstance().category == AVAudioSessionCategoryRecord {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
                print("playVoice setCategory failed: \(error)")
                return
            }
        }
        
        do {
            
            let audioPlayer = try AVAudioPlayer(contentsOf: voiceFileURL)
            
            self.audioPlayForTrim = audioPlayer // hold it
            
            audioPlayer.prepareToPlay()
            
            
            if audioPlayer.play() {
                //在剪辑时候的选播
                if (state == .trimmingRecord){
                    audioPlayer.currentTime = currentPlayTime
                    buttonDelegate.trimmTryPalyBegin?()
                }
            }
            
        } catch let error {
            print("play voice error: \(error)")
        }
        
    }
    
    //选播计时器.
    func playSomeSoundsFire(_ timer:Timer){
        fireCount += 0.25
        
        if let audioPlayer = audioPlayForTrim {
            
            if audioPlayer.currentTime >= 0.25 {
               
                let sampleIndex = turnFloatTimeToSampleIndex(Float(audioPlayer.currentTime))
                let time = getCurrentTimeFromSamples(sampleIndex + 1)
                
                 buttonDelegate.trimmTryPlaying?(time, duration:pauseEndSec)
            }
        }
        guard fireCount >= pauseEndSec else { return }
        timer.invalidate()
        //停止播放.
        if let audioPlay = audioPlayForTrim {
            audioPlay.pause()
            self.audioPlayForTrim = nil
            fireCount = 0.0
            
            buttonDelegate.trimmTryPlayEnd?()
        }
        
    }
    
    
    func getAllSamples(){
        
        guard let fileURL = voiceFileURL, !sampleValues.isEmpty else {
            return
        }
        
        let voiceSampleValues = sampleValues
        
        // 我们来一个 [0, 无穷] 到 [0, 1] 的映射
        
        // 函数 y = 1 - 1 / e^(x/100) 挺合适
        func f(_ x: Int, max: Int) -> Int {
            let n = 1 - 1 / exp(Double(x) / 100)
            return Int(Double(max) * n)
        }
        
        //设置最低的录音时长是是动态的,(波形长度固定4+2间隙)
        let minSamples = Int(self.frame.size.width / (4+2))
        
        let viewWidth = Int(self.frame.width/1) - 250
        var maxNumber = viewWidth
        
        if (voiceSampleValues.count < maxNumber && voiceSampleValues.count > minSamples) {
            maxNumber = voiceSampleValues.count
        }
        else if (voiceSampleValues.count  > maxNumber) {
            maxNumber = viewWidth//不变
            
        }
        else  {
            //波形数量小于minSamples
            maxNumber = minSamples
        }
        
        let finalNumber = f(voiceSampleValues.count, max: maxNumber)

        var width = self.frame.size.width / CGFloat(minSamples) - 2
        var minimumLineSpacing: CGFloat = 2
        
        //用finalNumger来设置宽度.
        if (finalNumber <= minSamples ) {
            
            minimumLineSpacing = 4
            width = (self.frame.size.width / CGFloat(finalNumber)) - 4
            
        }
        else if (finalNumber > minSamples ) {
            //数量不会超过let viewWidth = Int(self.view.frame.width/1) - 80
            width = self.frame.size.width / CGFloat(finalNumber) - 1
            minimumLineSpacing = 1
        }
        
        
        // 再做一个抽样
        
        func averageSamplingFrom(_ values:[Float], withCount count: Int) -> [Float] {
            
            let step = Double(values.count) / Double(count)
            
            var outoutValues = [Float]()
            
            var x: Double = 0
            
            for _ in 0..<count {
                
                let index = Int(x)
                
                if let value = values[safe : index] {
                    let fixedValue = Float(Int(value * 100)) / 100 // 最多两位小数
                    outoutValues.append(fixedValue)
                    
                } else {
                    break
                }
                
                x += step
            }
            
            return outoutValues
        }
        
        let limitedSampleValues = averageSamplingFrom(voiceSampleValues, withCount: finalNumber)
        print("limitedSampleValues: \(limitedSampleValues.count)")
        
        let count = sampleValues.count
        let frequency = 4 //频率是4
        let minutes = count / frequency / 60
        audioSeconds = count / frequency - minutes * 60
        waveView.sampleValuesForPlay = limitedSampleValues
        
        closeAudioPlay()
        
        waveView.refreshSampleView(width, lineSpacing: minimumLineSpacing, sampleVals: limitedSampleValues)
        
    }
    
    
    func playRecord() {
        
        //因为播放前多个文件已经合并到一个.所以锁定播放路径.
        kAudioFileName = "record0"
        voiceFileURL = audioPathURL
        
        guard let voiceFileURL = voiceFileURL else {
            return
        }
        
        if let audioPlayer = audioPlayer {
            
            handlerAudioPlayed(audioPlayer)
            
        }
        else {
            
            openNewAudioIn(voiceFileURL)
        }
    }
    
    func handlerAudioPlayed(_ audioPlayer:AVAudioPlayer) {
        if audioPlayer.isPlaying {
            
            audioPlayer.pause()
            state = .playPausing
            audioPlaying = false
            stopTimer()

            
            tryPlayButton.setImage(UIImage(named: "recordPlay"), for: UIControlState())
            
        } else {
            
            audioPlayer.play()
            state = .playing
            audioPlaying = true
            
            tryPlayButton.setImage(UIImage(named: "recordPlayPauseButton"), for: UIControlState())
            
            initTimer()
        }
    }
    
    
    func openNewAudioIn(_ file:URL) {
        
        if AVAudioSession.sharedInstance().category == AVAudioSessionCategoryRecord {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
                print("playVoice setCategory failed: \(error)")
                return
            }
        }
        
        do {
            
            let audioPlayer = try AVAudioPlayer(contentsOf: file)
            
            self.audioPlayer = audioPlayer
            
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            
            
            if audioPlayer.play() {
                //将波形图重置到开始位置
                waveView.sampleView.sampleCollectionView.scrollToItem(at: IndexPath(item:0, section: 0), at: .left, animated: false)
                //print("do play voice")
                state = .playing
                audioPlaying = true
                
                refreshPlaySlider()
                
                tryPlayButton.setImage(UIImage(named: "recordPlayPauseButton"), for: UIControlState())
                
                initTimer()
                
            }
            
        } catch let error {
            print("play voice error: \(error)")
        }
    }
    
    func initTimer() {
        
        updateTimerInPlay = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DDRecordControl.updateTimeLabel(_:)), userInfo: nil, repeats: true)
        
        playbackTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(DDRecordControl.updateAudioPlaybackProgress(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        
        playbackTimer?.invalidate()
        updateTimerInPlay.invalidate()
    }
    
    
    //播放时间计时器
    func updateTimeLabel(_ timer:Timer) {
//        let currentSeconds = self.audioPlayer?.currentTime
//        let currentMin = Int(currentSeconds! / 60)
//        let currentSec = Int(currentSeconds!) - currentMin * 60
//        
//        let totalSecond = self.audioPlayer?.duration
//        let totalMin = Int(totalSecond! / 60 )
//        let totalSec = Int(totalSecond!) - totalMin * 60
//        
//        //播放时候的时间显示,当前时间/总时间
//        //let timeText = String(format: "%02d:%02d/%02d:%02d", currentMin, currentSec,totalMin ,totalSec)
//        //delegate.recordTimeUpdate(timeText)
    }
    
    //试听 进度条和波形颜色.
    
    var aCount:Int = 0
    
    
    
    @objc fileprivate func updateAudioPlaybackProgress(_ timer: Timer) {
        
        if let audioPlayer = audioPlayer {
            let currentTime = audioPlayer.currentTime
            
            self.tryPlaySlider.value = Float(currentTime)
            
            let currentSeekIndex = turnFloatTimeToSampleIndex(Float(currentTime))
            waveView.updateWaveViewColor(currentSeekIndex)
            
            //Index 0 based
            guard currentTime >= 0.25 else {return}
            
            //每0.25秒统计一次.timer 用0.01 是为了让播放进度条运行的平滑.
            aCount += 1
            
            guard aCount == 25 else {
                
                return
            }
            
            aCount = 0
            
            //播放进度超过屏幕宽度之后,需要移动波形图.
            let playedWidth = CGFloat((currentSeekIndex + 1) * (4 + 2))
            if playedWidth >= screenWidth {
                waveView.sampleView.makeAnime()
            }
            
            //这里不需要从波形图位置来获取一个时间,直接使用计时器累计
            ddAudioPlayTimelyObserver += 0.25
            print("正在播放:\(ddAudioPlayTimelyObserver)")
            buttonDelegate.recordTryPlaying!()
        }
    }
    
    func closeAudioPlay() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioPlaying = false
        ddAudioPlayTimelyObserver = 0
    }
    
    /**
     将浮点转化成波形图位置index
     */
    func turnFloatTimeToSampleIndex(_ time:Float) -> Int {
        
        return Int(time * 4) - 1
    }
    
    /**
     从波形图当前位置所在的数量来得到一个时间.(频率0.25)
     */
    func getCurrentTimeFromSamples(_ count:Int) -> Float {
        
        let sec = Float(count) / 4
        return sec
    }
    
    
    //MARK: 剪切
    func trimTapped() {
        
        if state == .finishRecord || state == .playPausing || state == .timeOver {
            
            state = .trimmingRecord
            var pauseTimeMicroSeconds:Float = 0.0
            //如果没有试听直接点击了剪辑,那么直接滚到最后一秒.
            if (self.tryPlaySlider.value == 0.0) {
                //使用毫秒来操作.
                refreshPlaySlider()
                pauseTimeMicroSeconds = self.tryPlaySlider.maximumValue
            }
            else {
                //获取结束的时间点.
                pauseTimeMicroSeconds = self.tryPlaySlider.value
            }
            
            //将波形图定位到结束的时间点,并且放置在左侧.
            do {
                
                //更新波形图
                waveView.refreshSampleView(4, lineSpacing: 2, sampleVals: sampleValues)
                
                let postion = Int(pauseTimeMicroSeconds * 4)
                
                let pauseTimeIndex = postion - 1 // 由于cellIndex 是0开始的 到cellindex要减一
                waveView.trimEndCellIndex = pauseTimeIndex
                
                print(sampleValues.count)
                
                //停止点不超过屏幕宽度.4是波形图宽度,2是间隔.
                if (pauseTimeIndex * (4+2) <= Int(self.frame.size.width)) {
                    
                    let xOffSet = self.frame.size.width - CGFloat(pauseTimeIndex * (4+2))
                    waveView.firstItemX = xOffSet
                    delay(0.1, closure: {
                        self.waveView.sampleView.sampleCollectionView.setContentOffset(CGPoint(x: -xOffSet, y: 0), animated: false)
                    })
                   waveView.pauseTimeTooSmall = true
                    
                }
                else {
                    
                    waveView.sampleView.sampleCollectionView.scrollToItem(at: IndexPath(item: pauseTimeIndex - 1, section: 0), at: .right, animated: false)
                    
                    waveView.pauseTimeTooSmall = false
                    
                    waveView.firstItemX = 0.0
                }
                
                //关闭重置全局播放器
                closeAudioPlay()
                
            }
            
            //更新时间显示.最大值是当前位置.
            let totalSecond = pauseTimeMicroSeconds
            let totalMin = Int(totalSecond / 60 )
            let totalSec = Int(totalSecond) - totalMin * 60
            
            timeLabel.text = String(format: "%02d:%02d/%02d:%02d", totalMin, totalSec - 1,totalMin ,totalSec)
            
            //筛选器的位置时结束点的前一秒位置.(默认最少可以删除一秒.)一秒是4个step也就是(4 + 2)*4
            waveView.indicatorView.alpha = 1.0
            waveView.indicatorView.center.x = self.frame.size.width - 4*(4+2)
            
            //筛选器所在的时间.
            waveView.currentTimeLabel.alpha = 1.0
            waveView.currentTimeLabel.center.x = waveView.indicatorView.center.x
            //获取起始位置和重点位置.更新波形图颜色.
            let beginIndex = waveView.trimEndCellIndex - 4 //因为4个cell代表一秒
            let endIndex = waveView.trimEndCellIndex
            
            //默认:如果用户不移动直接剪辑的话.确定起点和终点时间,给选播,剪切做准备.beginTimeMicroSeconds  pauseTimeMicroSeconds
            self.startSec = pauseTimeMicroSeconds - 1
            self.pauseEndSec = pauseTimeMicroSeconds
            
            waveView.startCellIndex = beginIndex
            waveView.pauseEndCellIndex = endIndex
            
            delay(0.1, closure: { () -> () in
                self.waveView.updateMiddleWaveViewColor(beginIndex, endIndex: endIndex)
            })
            
        }
        
    }
    
    
    func trimConfirmByUser() {
        
        if state == .trimmingRecord {
            
            let start = self.startSec
            //注意,当直接剪切的时候,按照规则,结束时间点应该是最末的时间,但是这里pauseEndSec,是0.0 理论上,这个0.0是不可能在剪切时出现的.它的默认值应该是录音总时长
            let end = self.pauseEndSec
            trimAudioByHelper(start, end:end)
        }
    }
    
    
    func firstTimetrimConfirm() {
        
        if state == .trimmingRecord {
            
            var tellDelagate = false
            //剪辑之前,判断是否包含了.播放队列
            page.playQueue.forEach {
                
                guard $0.conflictWithRecordTrim == true else { return }
                
                tellDelagate = true
            }

            guard tellDelagate else {
                
                trimConfirmByUser()
                return
            }
            
            delegate.trimmedTimeConflictWithPlayQueue(self.startSec, trimEnd: self.pauseEndSec)
   
        }
    }
    
    
    func trimCancel() {
        
        if state == .trimmingRecord {
            state = .finishRecord
            //取消裁剪之后,回到暂停状态,或者告警状态.
            closeAudioPlay()
            tryPlaySlider.value = 0.0
            
            pullWaveToRight()
        }

    }
    
    func setCADisplayLinkTimer() {
        
//        displayLink = CADisplayLink(target: self, selector: #selector(DDRecordControl.checkVoiceRecordValue(_:)))
//        
//        // 频率为每秒 4次 CADisplayLink的selector每秒调用次数=60/frameInterval
//        displayLink.frameInterval = 15
//        
//        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
//        
//        // 如果进来前有声音在播放，令其停止
//        if let audioPlayer = DDAudioService.sharedManager.audioPlayer, audioPlayer.isPlaying {
//            audioPlayer.pause()
//        }
        
        displayLink = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(DDRecordControl.checkVoiceRecordValue), userInfo: nil, repeats: true)
        displayLink.fire()
        
    }
    
    //移除帧计时器,否则会重复调用.
    func removeDisplayLink() {
        
        if (displayLink != nil) {
            
            displayLink.invalidate()
        }
        
    }
    
    //录音时更新波形数组
    func checkVoiceRecordValue() {
        
        if let audioRecorder = DDAudioService.sharedManager.audioRecorder {
            
            if audioRecorder.isRecording {
               // audioRecorder.meteringEnabled = true
                audioRecorder.updateMeters()
                
                let normalizedValue = pow(10, audioRecorder.averagePower(forChannel: 0)/40)
                
                let value = Float(normalizedValue)
                
                sampleValues.append(value)
                //从波形数量来统计时间.4个等于1秒.
                let count = sampleValues.count
                let sec = Float(count) / 4
                ddRecordTimelyObserver = sec
                waveView.appendSampleValue(value)
                
                print("当前录音是:  \(ddRecordTimelyObserver)")
                
//                dbObserver.time = ddRecordTimelyObserver
//                dbObserver.decibels = audioRecorder.averagePowerForChannel(0)
//                
//                dbObserver.covertDB()
            }
        }
    }
    
    
    func voiceRecord() {
        
        switch state {
        case .recording:
            
            recordShutDown()
        default:
            
            if !couldRecord() {
                buttonDelegate.recordBeginWithLimmit?()
                
            }
            else {
                state = .recordPrepare
                buttonDelegate.recordTap?()//3秒倒计时.
            }
            
            
        }
        
    }
    
    //录音开始
    func recordBeigin() {
        
        voiceFileURL = self.audioPathURL
        DDAudioService.sharedManager.shouldIgnoreStart = false
        
        DDAudioService.sharedManager.beginRecordWithFileURL(self.audioPathURL , audioRecorderDelegate: self)
        
        closeAudioPlay()
        
        waveView.refreshSampleView(4, lineSpacing: 2, sampleVals: sampleValues)
        
        state = .recording
    }
    
    //停止录音,合并.
    func recordShutDown() {
        
        endRecording()
        state = .finishRecord
        
    }
    
    //录音到达限制
    func recordOverLimmit() {
        endRecording()
        state = .finishRecord
    }
    
    fileprivate func endRecording() {
        DDAudioService.sharedManager.endRecord()
        self.combineAudioIfNeed()
    }

    func showSubTitle() {
        //通知控制台,展示字幕界面.
        buttonDelegate.shouldShowSubtitleView?()
    }
    
    
    func tryPlaySliderValueChanged(_ sender:UISlider) {
        
        self.seekToFrame(sender.value)
    }
    
    func seekToFrame(_ microSeconds:Float)  {
        
        if let audioPlay = self.audioPlayer  {
            self.audioPlayer!.currentTime = TimeInterval(microSeconds)
            
            let totalSecond = audioPlay.duration
            let totalMin = Int(totalSecond / 60 )
            let totalSec = Int(totalSecond) - totalMin * 60
            
            let currentSeconds = microSeconds
            let currentMin = currentSeconds / 60
            let currentSec = currentSeconds - currentMin * 60
            
            timeLabel.text = String(format: "%02d:%02d/%02d:%02d", currentMin, currentSec,totalMin ,totalSec)
            
            let currentSeekIndex = Int(microSeconds * 4) - 1
            guard currentSeekIndex >= 0 else {return}
            waveView.updateWaveViewColor(currentSeekIndex)
            
            //更新当前的全局录音计时器的时间
            ddAudioPlayTimelyObserver = getCurrentTimeFromSamples(currentSeekIndex + 1)
            
        }
        
    }
    
    //MARK: 控制台状态
    var startSec:Float = 0.0
    var pauseEndSec:Float = 0.0

    enum State {
        case `default`
        case recordPrepare
        case recording
        case finishRecord
        case timeOver
        case playing
        case playPausing
        case trimmingRecord
    }
    
    var state : State = .default {
        willSet {
            switch newValue {
                
            case .default:        state_Defult()
                
            case .recordPrepare: state_RecordPrepare()
                
            case .recording:      state_Recording()
                
            case .playing:        state_Playing()
                
            case .playPausing:    state_PlayPausing()
                
            case .finishRecord:   state_FinishRecord()
                
            case .timeOver:       state_TimeOver()
                
            case .trimmingRecord: state_TrimmingRecord()
   
            }
        }
    }
    
    
    func state_Defult() {
        
        microButton.setImage(UIImage(named: "recordMic"), for: UIControlState())
        
        microButton.alpha            = 1.0
        tryPlayButton.alpha          = 1.0
        trimButton.alpha             = 1.0
        
        waveView.indicatorView.alpha = 0.0
        waveView.currentTimeLabel.alpha = 0.0
        trimConfirmButton.alpha      = 0.0
        trimCancelButton.alpha       = 0.0
        tryPlaySlider.alpha          = 0.0
        
        trimConfirmButton.alpha = 0.0
        trimCancelButton.alpha = 0.0
    }
    
    func state_RecordPrepare() {
        trimConfirmButton.alpha = 0.0
        trimCancelButton.alpha  = 0.0
        tryPlayButton.alpha     = 0.0
        trimButton.alpha        = 0.0
        tryPlaySlider.alpha     = 0.0
        
        waveView.indicatorView.alpha = 0
        waveView.currentTimeLabel.alpha = 0.0
        
        if ((updateTimerInPlay) != nil){
            updateTimerInPlay.invalidate()
        }
        
        microButton.alpha = 0.0
    }
    
    func state_Recording() {
        
        microButton.alpha = 1.0
        
        microButton.setImage(UIImage(named: "recordPauseIcon"), for: UIControlState())
        
        buttonDelegate.recordBegin!()
    }
    
    func state_Playing() {
        
        buttonDelegate.recordTryPlayBegin!()
        
        microButton.isEnabled = false
        trimButton.isEnabled = false
    }
    
    func state_TimeOver() {
        
        
    }
    
    func state_FinishRecord() {
        
        microButton.isEnabled = true
        trimButton.isEnabled = true
        microButton.alpha            = 1.0
        tryPlayButton.alpha          = 1.0
        trimButton.alpha             = 1.0
        
        trimConfirmButton.alpha      = 0.0
        trimCancelButton.alpha       = 0.0
        waveView.indicatorView.alpha = 0.0
        waveView.currentTimeLabel.alpha = 0.0
        
        tryPlaySlider.value          = 0.0
        waveView.aInt                = 0
        
        buttonDelegate.recordFinished!()
        
        tryPlayButton.setImage(UIImage(named: "recordPlay"), for: UIControlState())
        microButton.setImage(UIImage(named: "recordMic"), for: UIControlState())
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.waveViewBottomConstraint?.update(offset: 0)
            self.waveView.layoutIfNeeded()
            
            }, completion: nil)
        
        //更新总时间
        let totalTimeStr =  DDTimeLabelCounter.audioDurationBy(audioSamlesCount: sampleValues.count)
        
        let count = sampleValues.count
        let frequency = 4
        let totalSeconds = (count / frequency)
        var warning = false
        if totalSeconds >= limmitSecond {
            state = .timeOver
        }
        else {
            delegate?.recordTimeAwayFromLimmit()
        }
        
        if totalSeconds >= limmitSecond - countDownSeconds {
            warning = true
        }
        
        delegate.recordTimeUpdate(totalTimeStr,showWarning: warning)
        
        //将波形,时间保存到数据库对象.
        saveSamplesToRealm()
        
        saveDurationToRealm(totalTimeStr)
        
        //由于,播放之后,会把路径重置到0record.m4a.所以需要重新check
        checkCureentPhotoStatus()
        
        
    }
    

    
    func state_PlayPausing() {
        
        buttonDelegate.recordTryPlayPaused!()
        microButton.isEnabled = true
        trimButton.isEnabled = true
    }
    
    func state_TrimmingRecord() {
        
        microButton.alpha = 0.0
        tryPlayButton.alpha = 1.0
        trimButton.alpha = 0.0
        trimConfirmButton.alpha = 1.0
        trimCancelButton.alpha = 1.0
        tryPlaySlider.alpha = 0.0
        
        tryPlayButton.setImage(UIImage(named: "trimPlay"), for: UIControlState())
        
        //剪辑的时候,将波形图抬高
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            
            self.waveViewBottomConstraint?.update(offset:  -self.waveView.frame.size.height/2)
            self.waveView.layoutIfNeeded()
            }, completion: nil)
        
        
        
    }
    
    func saveSamplesToRealm() {
        let realm = try! Realm()
        
        let sampArr =  List<sampleModel>()
        for samle in self.sampleValues {
            let model = sampleModel()
            model.sample = samle
            sampArr.append(model)
        }
        
        try! realm.write {
            self.page.samples.removeAll()
            self.page.samples.append(objectsIn: sampArr)
            
        }
    }
    
    func saveDurationToRealm(_ timeSring:String) {
        let realm = try! Realm()
        
        try! realm.write {
            self.page.duration = timeSring
        }
    }
    
    func updateTimeAndSampleWavesNeeded() {
        
        waveView.resetSampleView()
        waveView.sampleView.sampleValues =  self.sampleValues
        waveView.sampleView.sampleCollectionView.reloadData()
        self.timeLabel.text = page.duration
        
        //更新录音同步计时器
        ddRecordTimelyObserver = Float (self.sampleValues.count) / 4
        if ddRecordTimelyObserver > 0 {
            self.state = .finishRecord
        }
        
    }
    
    
    fileprivate var voiceFileURL: URL?
    fileprivate var audioPlayer: AVAudioPlayer?
   // fileprivate var displayLink: CADisplayLink! //波形更新计时器
    
    fileprivate var displayLink: Timer!
    
    var limmitSecond:Int = 60 //录音时长限制
    
    var countDownSeconds:Int = 10 //结束倒计时时长
   
    //波形粒子集合
    var sampleValues: [Float] = [] {
        didSet {
            checkSamples()
        }
    }
    
    func checkSamples() {
        
        let count = sampleValues.count
        let frequency = 4
        let minutes = count / frequency / 60
        let seconds = count / frequency - minutes * 60
        
        let totalSeconds = (count / frequency)
        
        //let subSeconds = count - seconds * frequency - minutes * 60 * frequency
        let text = String(format: "%2d:%02d", minutes, seconds)
        if let currentDelegate = delegate {
            var warning = false
            //到达警告时间范围.
            if totalSeconds >= limmitSecond - countDownSeconds {
                warning = true
            }
            else {
                //离开警告范围.
                warning = false
            }
            
            if totalSeconds == limmitSecond {
                
                currentDelegate.recordTimeReachLimmit()
            }
            
            currentDelegate.recordTimeUpdate(text, showWarning: warning)
            
        }

    }
    
    func couldRecord() -> Bool {
        
        let count = sampleValues.count
        let frequency = 4
        let totalSeconds = (count / frequency)
        
        if totalSeconds >= limmitSecond {
            return false
        }
        else {
            return true
        }
        
    }
    
    var yellowSampleIndexArry = [Int]()//存储文本框的showTime
    
    fileprivate var audioPlaying: Bool = false {
        willSet {
            if newValue != audioPlaying {
                if newValue {
                    buttonDelegate.recordTryPlayBegin!()
                    
                } else {
                    buttonDelegate.recordTryPlayPaused!()
                    
                }
            }
        }
    }
    
    var audioHelper = DDAudioHandler()
    
    func setAudioHelperHandler() {
        
        audioHelper.audioDocURL = page.audioDocURL
        audioHelper.totalTrimCount = 2
        
        //合并完成
        audioHelper.recordCombineCompleteHandler = { [weak self] in
            self?.notiMakeCourseVC()
        }
        
        //剪切开始
        audioHelper.trimmBeginHandler =  {
            
        }
        
        //剪切完成
        audioHelper.trimmCompleteHandler =  { [weak self] in
            
            self?.combineAudioIfNeed()
            //在主线程更新UI.
            self?.updateUIAfterTrim()
        }
    
    }
    
    func notiMakeCourseVC() {
        //提示总控台.
        DispatchQueue.main.async {
            self.delegate.recordCombinedComplete()
            
            self.checkCureentPhotoStatus()
        }
    }
    
    func updateUIAfterTrim() {
        DispatchQueue.main.async {
            
            self.refreshSamples() //更新波形图
            
            self.refreshPlaySlider() //更新进度条.
            
            self.state = .finishRecord //状态改为FinishRecord(这里面会更新波形图存储)
        }
    }
    
    func combineAudioIfNeed() {
        //剪切之后,源路径留下两个分开的音频,需要合并.
        audioHelper.combinedAudiosifNeed()
    }
    
    func trimAudioByHelper(_ start:Float,end:Float) {
        
        audioHelper.clipAudioByStartAndEndTime(start, end: end)
    }

    func refreshSamples() {
        //samples中要删除相应的波形图.
        sampleValues.removeSubrange(( waveView.startCellIndex)...( waveView.pauseEndCellIndex))
        
        //清空voiceRecordSampleView
        pullWaveToRight()
    }
    
    func refreshPlaySlider() {
        
        let microseconds = Float(sampleValues.count) / 4
        tryPlaySlider.minimumValue = 0
        tryPlaySlider.maximumValue = Float(microseconds)
        tryPlaySlider.isContinuous = true
        tryPlaySlider.value = 0.0
        
    }
    
    func refeshSamplesWithTimes(_ times:[Int]) {
        var currentTimes = times
        //获取N段截取区间.从末尾开始删除.
        var doubleTimes = [[Int]]()
        for _ in 0..<times.count/2 {
            var range = [Int]()
            
            range.append(currentTimes.removeFirst())
            range.append(currentTimes.removeFirst())
            
            doubleTimes.append(range)
            
        }
        
        for i in 0..<doubleTimes.count {
            
            //从末尾删除
            let start = doubleTimes[doubleTimes.count - i - 1][0]
            let end   = doubleTimes[doubleTimes.count - i - 1][1]
            sampleValues.removeSubrange(start...end)
            
        }
        pullWaveToRight()
        self.state = .finishRecord //状态改为FinishRecord
    }
    
    func pullWaveToRight() {
        
        waveView.refreshSampleView(4, lineSpacing: 2, sampleVals: sampleValues)
        
        guard self.sampleValues.count > 0 else {return}
        
        waveView.sampleView.sampleCollectionView.scrollToItem(at: IndexPath(item: (self.sampleValues.count - 1), section: 0), at: .right, animated: false)
    }
    
    func pullWaveToLeft() {
        
        waveView.refreshSampleView(4, lineSpacing: 2, sampleVals: sampleValues)
        
        guard self.sampleValues.count > 0 else {return}
        
        waveView.sampleView.sampleCollectionView.scrollToItem(at: IndexPath(item: (self.sampleValues.count - 1), section: 0), at: .left, animated: false)
    }
    
    

}

extension DDRecordControl {
    
//    
//    func recordImageIndexChanged(curretnIndex:Int,previousIndex:Int) {
//        
//        currentPage = curretnIndex
//        
//        NSObject.delay(0.5) {
//            //先保存之前的波形
//            self.samplesArry[previousIndex] = self.sampleValues
//            self.sampleValues = []
//            
//            self.waveView.resetSampleView()
//            
//            //获取当前图片的波形,如果有,没有的情况是空.
//            self.checkCureentPhotoStatus(curretnIndex) //检查当前的路径中是否存在录音.
//            
//            self.sampleValues =  self.samplesArry[curretnIndex]
//            self.waveView.sampleView.sampleValues =  self.sampleValues
//            
//            self.waveView.sampleView.sampleCollectionView.reloadData()
//            self.timeLabel.text =  self.recordTimesArr[curretnIndex]
//        }
//        
//    }
    
    func checkCureentPhotoStatus(){
        
        let recordURL = page.audioDocURL
        //获取当前图片(lessonindex)中的音频文件的数量,
        let count = FileManager.recordCountInLessonIndex(recordURL!)
        if count > 0 {
            //存在录过的音频.设置当前播放index文件.由于合并了录音,所以每次回到路径都是一个文件.
            self.FileRecordedNumber = count
            kAudioFileName = "record\(self.FileRecordedNumber)"
            
        }
        else if count == 0 {
            //这是一个空的文件夹.
            self.FileRecordedNumber = 0
            kAudioFileName = "record\(self.FileRecordedNumber)"
        }
        
    }
}

extension DDRecordControl:DDWaveViewDelegate {
    
    //滑动指示器在移动.
    func DDWaveViewIndicatorIsMovingWhenPlay(_ beginIndex: Int) {
        
        //根据指示器所在的cellIndex反推出时间点.一格等于1/4秒
        
        let beginSeconds:Float = Float(beginIndex + 1) / 4
        
        
        //更新时间显示.最大值是当前位置.
        var pauseTimeMicroSeconds:Float = 0.0
        //如果没有试听直接点击了剪辑,那么直接滚到最后一秒.
        if (self.tryPlaySlider.value == 0.0) {
            //使用毫秒来操作.
            refreshPlaySlider()
            pauseTimeMicroSeconds = self.tryPlaySlider.maximumValue
        }
        else {
            //获取结束的时间点.
            pauseTimeMicroSeconds = self.tryPlaySlider.value
        }


        let pauseMin = Int(pauseTimeMicroSeconds / 60 )
        let pauseSec = Int(pauseTimeMicroSeconds) - pauseMin * 60
        
        let currentMin = Int(beginSeconds / 60)
        let currentSec = Int(beginSeconds) - currentMin * 60
        
        timeLabel.text = String(format: "%02d:%02d/%02d:%02d", currentMin,currentSec,pauseMin ,pauseSec)
        
        //更新当前裁剪时间
        waveView.currentTimeLabel.text = String(format: "%02d:%02d", currentMin,currentSec )
        waveView.currentTimeLabel.center.x = waveView.indicatorView.center.x

        //更新波形图颜色
        waveView.updateMiddleWaveViewColor(beginIndex, endIndex: waveView.trimEndCellIndex)
        
        //确定起点和终点时间,给选播,剪切做准备.beginTimeMicroSeconds  pauseTimeMicroSeconds
        self.startSec = beginSeconds
        self.pauseEndSec = pauseTimeMicroSeconds
        
        print((startSec))
        
        
        waveView.startCellIndex = beginIndex
        waveView.pauseEndCellIndex = waveView.trimEndCellIndex
    }
    
    
    func DDWaveViewIndicatorIsMovingWhenTrim() {
        //通知总控制台,正在滑动波形图,检测是否需要高亮冲突组件.
        delegate.recordTrimming()
    }
    
    func DDWaveViewSamplesInTrim(_ cellIndex: Int) {

        page.playQueue.forEach { (point)in
            //遍历
            let sampleTime = Float(cellIndex + 1) / 4
            guard point.time == sampleTime else { return }
            
            let realm = try! Realm()
            
            try! realm.write {
                point.conflictWithRecordTrim = true //确认与剪切时间冲突.
            }
            
            //print("冲突的时间点是:\($0.time)")
            switch point.launchType {
                
            case LaunchType.openImage:
                self.waveView.setColorForSingleCell(cellIndex, color: UIColor.ddWaveWithImageTimeColor())
                
            case LaunchType.moveImagePage:
                self.waveView.setColorForSingleCell(cellIndex, color: UIColor.ddWaveWithImageTimeColor())
                
            case LaunchType.showText:
                self.waveView.setColorForSingleCell(cellIndex, color: UIColor.ddWaveWithTextTimeColor())
                
            
            case LaunchType.closeImage:
//                try! realm.write {
//                    point.conflictWithRecordTrim = false //图片关闭在时刻在波形图上不显示,不算冲突.
//                }
                self.waveView.setColorForSingleCell(cellIndex, color: UIColor.ddWaveWithImageTimeColor())
                
            case LaunchType.defaultMode:break
             
            }
            
            
        }
    }
    
    func DDWaveViewSamplesNotInTrim(_ cellIndex: Int) {
        
        page.playQueue.forEach { (ponit) in
            //遍历
            let sampleTime = Float(cellIndex + 1) / 4
            guard ponit.time == sampleTime else { return }
            
            let realm = try! Realm()
            try! realm.write {
                ponit.conflictWithRecordTrim = false
            }
            
            self.waveView.setColorForSingleCell(cellIndex, color: UIColor.ddWaveAttachedColor())
//            if !(ponit.launchType == LaunchType.closeImage) {
//                
//                self.waveView.setColorForSingleCell(cellIndex, color: UIColor.ddWaveAttachedColor())
//            }
            
        }
    }
    
    
    
    
}

// MARK: - AVAudioRecorderDelegate

extension DDRecordControl: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        state = .finishRecord
        
        print("audioRecorderDidFinishRecording: \(flag)")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
        state = .default
        
        print("audioRecorderEncodeErrorDidOccur: \(error)")
    }
}

// MARK: - AVAudioPlayerDelegate

extension DDRecordControl: AVAudioPlayerDelegate {

    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if state == .trimmingRecord {
            
        }
        else {
            audioPlaying = false
            //audioPlayedDuration = 0
            state = .finishRecord
            updateTimerInPlay.invalidate()
            //waveView.resetSamplePosition()
            pullWaveToLeft()
            print("audioPlayerDidFinishPlaying: \(flag)")
        }
        closeAudioPlay()
        
        DDAudioService.sharedManager.resetToDefault()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        print("audioPlayerDecodeErrorDidOccur: \(error)")
        
        DDAudioService.sharedManager.resetToDefault()
    }
}
