//
//  DDPlayAudioControl.swift
//  DingDong
//
//  Created by Seppuu on 16/3/26.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import AVFoundation


class DDPlayAudioControl: UIView,JukeboxDelegate {

    var audioPlayer: AVAudioPlayer?
    
    var audioURL = URL(string: "")
    
    //var audioDuration:NSTimeInterval = 0.0
    @IBOutlet weak var likeButton: UIButton!
    
    var playbackTimer: Timer? {
        didSet {
            if let oldPlaybackTimer = oldValue {
                oldPlaybackTimer.invalidate()
            }
        }
    }
    
    var duration = "" {
        didSet {
            durationLabel.text = duration
        }
    }
    
    var jukebox = Jukebox()
    
    var replay = false
    
    var remoteAduioURLs = [""] {
        
        //init jukebox
        didSet {
            // configure jukebox
            
            var items = [JukeboxItem]()
            
            remoteAduioURLs.forEach {
                if let url = URL(string: $0) {
                    let item = JukeboxItem(URL: url)
                    items.append(item)
                }
                
            }
            
            self.jukebox = Jukebox(delegate: self, items: items)
        }
        
    }
    
    var pageSecond: TimeInterval = 0
    
    var playButtonTapHandler: ( (_ play:Bool) -> () )?
    var playProgresChangedHandler: ( () -> () )?
    var audioPlayBeginHandler:(() -> ())?
    var audioPlayPauseHandler:(() -> ())?
    var audioPlayPlaying:((_ time:String) -> ())?
    var audioPlayLoadingHandler:(() -> ())?
    var audioPlayDidFinished:(() -> ())?
    var shareButtonTap:(() -> ())?
    
    var likeButtonTap:(() -> ())?
    
    var unLikeButtonTap:(() -> ())?
    
    var hasLiked = false {
        didSet {
            
            likeButton.backgroundColor = UIColor.clear
            
            makeAnimeWithLikeButton()
        }
    }
    
    //第一次进入播放界面时,不需要动画.
    var needShowAnime = false
    
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    class func instanceFromNib() -> DDPlayAudioControl {
        return UINib(nibName: "DDPlayAudioControl", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DDPlayAudioControl
    }
    
    
    //MAKR: Jukebox delegate method
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
        if jukebox.state == .playEnd {
            //itme play end
            if let duration = jukebox.currentItem?.meta.duration {
                pageSecond += duration
                closeAudioPlay()
                audioPlayDidFinished?()
            }
            
        }
        else if jukebox.state == .loading {
            
            audioPlayLoadingHandler?()
        }
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
    }
    
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        
    }
    
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        
    }
    
    //MARK: Action
    @IBAction func playButtonTap(_ sender: UIButton) {
        
        playOrPauseRecord()
    }
    
    @IBAction func collectionTap(_ sender: UIButton) {
        
        if hasLiked {
            unLikeButtonTap?()
        }
        else {
            likeButtonTap?()
        }
        
    }
    
    
    fileprivate func makeAnimeWithLikeButton() {
        
        let affine = CGAffineTransform(scaleX: 2.0, y: 2.0)
        
        let image  =  hasLiked ? UIImage(named: "like_red_icon") : UIImage(named: "like_white_icon")
        likeButton.setImage(image!, for: UIControlState())
        
        if hasLiked && needShowAnime {
            likeButton.transform = affine
        }
        else {
            return
        }
        
        
        
        UIView.animate(withDuration: 1.0, delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 3,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    self.likeButton.transform = CGAffineTransform.identity
                                    
        }){ (_) in
    
        }
        
    }
    
    @IBAction func shareButtonTap(_ sender: UIButton) {
        
        shareButtonTap?()
    }

    func playOrPauseRecord() {
  
        if jukebox?.state == .ready  {
            
            jukebox?.play()
            
            openNewAudio()
        }
        else if jukebox?.state == .playing  {
            jukebox?.pause()
            audioPlayPauseHandler?()
            
            stopTimer()
            //切换到播放图片
            playButton.setImage(UIImage(named: "play_icon"), for: UIControlState())
            
        }
        else if jukebox?.state == .paused  {
            
            jukebox?.play()
            
            audioPlayBeginHandler?()
            
            //切换到暂停图片
            playButton.setImage(UIImage(named: "play_pause_icon"), for: UIControlState())
            initTimer()
            
        }
        else if jukebox?.state == .playEnd {
            if replay {
                jukebox?.replay()
                openNewAudio()
            }
        }
        
    }
    
    func openNewAudio() {
        
        playButton.setImage(UIImage(named: "play_pause_icon"), for: UIControlState())
        
        let currentSeconds =  pageSecond
        let currentMin = Int(currentSeconds / 60)
        let currentSec = Int(currentSeconds) - currentMin * 60
        
        currentTimeLabel.text = String(format: "%d:%02d", currentMin, currentSec)
        
        audioPlayBeginHandler?()
        initTimer()
        
    }
    
    func initTimer() {
        
        playbackTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(DDPlayAudioControl.updateAudioPlaybackProgress(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        
        playbackTimer?.invalidate()
    }
    
    func playNextAuio() {
        
        jukebox?.playNext()
        
        openNewAudio()
    }
    
    func resetPlay() {
        
        pageSecond = 0
        
        currentTimeLabel.text = "0:00"
        
        replay = true
        
        stopTimer()
        //切换到播放图片
        playButton.setImage(UIImage(named: "play_icon"), for: UIControlState())

    }
    

}



extension DDPlayAudioControl :AVAudioPlayerDelegate {
    
    @objc fileprivate func updateAudioPlaybackProgress(_ timer: Timer) {
        
        guard jukebox?.state == .playing else {return}
        
        guard let jukeItem = self.jukebox?.currentItem else {return}
        
        guard let currentTime = jukeItem.currentTime  else {return}
        
        //Index 0 based
        guard currentTime >= 0.25 else {return}
        
        let currentSeekIndex = turnFloatTimeToSampleIndex(Float(currentTime))
        //从波形位置来统计时间.4个等于1秒. 虽然这里么有波形图
        ddAudioPlayTimelyObserver = getCurrentTimeFromSamples(currentSeekIndex + 1)
        
        //加上上一个page的时间.伪装成总时间.
        let currentSeconds = currentTime + pageSecond
        let currentMin = Int(currentSeconds / 60)
        let currentSec = Int(currentSeconds) - currentMin * 60
        
        //播放时候的时间显示,当前时间/总时间
        currentTimeLabel.text = String(format: "%d:%02d", currentMin, currentSec)
        currentTimeLabel.textAlignment = .left
        let timeText = currentTimeLabel.text! + "/" + durationLabel.text!
        audioPlayPlaying?(timeText)
      
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
    
    func closeAudioPlay() {

        ddAudioPlayTimelyObserver = 0
        stopTimer()
    
       
    }
    
}
