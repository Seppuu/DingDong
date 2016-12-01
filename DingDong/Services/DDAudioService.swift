//
//  DDAudioService.swift
//  DingDong
//
//  Created by Seppuu on 16/3/2.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import Proposer
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DDAudioService: NSObject {
    
    static let sharedManager = DDAudioService()
    
    var shouldIgnoreStart = false
    
    let queue = DispatchQueue(label: "YepAudioService", attributes: [])
    
    var audioFileURL: URL?
    
    var audioRecorder: AVAudioRecorder?
    
    var audioPlayer: AVAudioPlayer?
    /**
     录音前的准备
     
     - parameter fileURL:               存储URL路径
     - parameter audioRecorderDelegate:
     */
    func prepareAudioRecorderWithFileURL(_ fileURL: URL, audioRecorderDelegate: AVAudioRecorderDelegate) {
        
        audioFileURL = fileURL
        
        let settings: [String: AnyObject] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC) as AnyObject,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as AnyObject,
            AVEncoderBitRateKey : 64000 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey : 44100.0 as AnyObject
        ]
        
        do {
            let audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder.delegate = audioRecorderDelegate
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord() // creates/overwrites the file at soundFileURL
            
            self.audioRecorder = audioRecorder
            
        } catch let error {
            self.audioRecorder = nil
            print("create AVAudioRecorder error: \(error)")
        }
    }
    
    var recordTimeoutAction: (() -> Void)?
    
    var checkRecordTimeoutTimer: Timer?
    func startCheckRecordTimeoutTimer() {
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DDAudioService.checkRecordTimeout(_:)), userInfo: nil, repeats: true)
        
        checkRecordTimeoutTimer = timer
        
        timer.fire()
    }
    
    func checkRecordTimeout(_ timer: Timer) {
        
        if audioRecorder?.currentTime > DDConfig.AudioRecord.longestDuration {
            
            endRecord()
            
            recordTimeoutAction?()
            recordTimeoutAction = nil
        }
    }
    
    func beginRecordWithFileURL(_ fileURL: URL, audioRecorderDelegate: AVAudioRecorderDelegate) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        } catch let error {
            print("beginRecordWithFileURL setCategory failed: \(error)")
        }
        
        //dispatch_async(queue) {
        do {
            //AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker,error: nil)
            //AVAudioSession.sharedInstance().setActive(true, error: nil)
            
            proposeToAccess(.microphone, agreed: {
                
                self.prepareAudioRecorderWithFileURL(fileURL, audioRecorderDelegate: audioRecorderDelegate)
                
                if let audioRecorder = self.audioRecorder {
                    
                    if (audioRecorder.isRecording){
                        audioRecorder.stop()
                        
                    } else {
                        if !self.shouldIgnoreStart {
                            audioRecorder.record()
                            print("audio record did begin")
                        }
                    }
                }
                
                }, rejected: {
                    if let
                        appDelegate = UIApplication.shared.delegate as? AppDelegate,
                        let viewController = appDelegate.window?.rootViewController {
                            viewController.alertCanNotAccessMicrophone()
                    }
            })
        }
    }
    
    func endRecord() {
        
        if let audioRecorder = self.audioRecorder {
            if audioRecorder.isRecording {
                audioRecorder.stop()
            }
        }
        
        queue.async {
            //AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker,error: nil)
            let _ = try? AVAudioSession.sharedInstance().setActive(false, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
        }
        
        self.checkRecordTimeoutTimer?.invalidate()
        self.checkRecordTimeoutTimer = nil
    }
    
    
    // MARK: Audio Player
    
    
    var playbackTimer: Timer? {
        didSet {
            if let oldPlaybackTimer = oldValue {
                oldPlaybackTimer.invalidate()
            }
        }
    }
    
    
    func resetToDefault() {
        // playback 会导致从音乐 App 进来的时候停止音乐，所以需要重置回去
        
        queue.async {
            let _ = try? AVAudioSession.sharedInstance().setActive(false, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
        }
        
        //playingItem = nil
    }
    
    // MARK: Proximity
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DDAudioService.proximityStateChanged), name: NSNotification.Name.UIDeviceProximityStateDidChange, object: UIDevice.current)
    }
    
    func proximityStateChanged() {
        
        if UIDevice.current.proximityState {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            } catch let error {
                print("proximityStateChanged setCategory failed: \(error)")
            }
            
        } else {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
                print("proximityStateChanged setCategory failed: \(error)")
            }
        }
    }
    
    
    
    
}
