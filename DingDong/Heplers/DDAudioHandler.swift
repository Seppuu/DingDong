//
//  AudioHandler.swift
//  DingDong
//
//  Created by Seppuu on 16/3/1.
//  Copyright © 2016年 seppuu. All rights reserved.
//

import UIKit
import AVFoundation

class DDAudioHandler:NSObject {
    
    var trimmedCount = 0
    var audioDocURL:URL?
    var totalTrimCount:Int!
    
    func combineAudios(recordURLs urls:[URL],outputURL toUrl:URL, completion: @escaping ()->()){
        
        var nextClipStartTime = kCMTimeZero
        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        for index in 0 ..< urls.count {
            // loops with index taking values 1,2
            //Build the filename with path
            let asset = AVURLAsset(url: urls[index], options: nil)
            let tracks = asset.tracks(withMediaType: AVMediaTypeAudio)
            if (tracks.count == 0) {
                print("\(tracks.count)")
                return
            }
            let timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, asset.duration)
            let clipAudioTrack = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
            
            do {
                try compositionAudioTrack.insertTimeRange(timeRangeInAsset, of: clipAudioTrack, at: nextClipStartTime)
            } catch {
                print("Error with insertTimeRange. Audio error: \(error).")
            }
            
            nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration)
            
        }
        // create the export session
        // no need for a retain here, the session will be retained by the
        // completion handler since it is referenced there
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        
        if (nil == exporter) {
            print("NO")
        }

        
        // configure export session  output with all our parameters
        exporter?.outputURL = toUrl
        exporter?.outputFileType = AVFileTypeAppleM4A
        
        // perform the export
        
        // do it
        exporter!.exportAsynchronously(completionHandler: {
            switch exporter!.status {
            case  AVAssetExportSessionStatus.failed:
                print("export failed \(exporter!.error)")
            case AVAssetExportSessionStatus.cancelled:
                print("export cancelled \(exporter!.error)")
            default:
                print("export complete")
                //这里需要用一个闭包来回调比较好.
                completion()

            }
        })
    }
    
    func deleteRecordFileCombinedAndRenameNewOne(_ urlArr:[URL],fileRenamedURL:URL,toURL:URL,completion: ()->()){
        
        //删除分散的录音文件
        let fileManger = FileManager.default
        for url in urlArr {
            do{
                try fileManger.removeItem(at: url)
            }catch {
                print("error: \(error).")
            }
        }
        
        //rename,将旧的file移动到原位置新建一个name.即可删除原来的文件.
        do {
            try fileManger.moveItem(at: fileRenamedURL, to: toURL)
        }catch {
            print("error: \(error).")
        }
        
        //完成回调
        completion()
        
    }
    
    
    
    func clipAudioByStartAndEndTime(_ start:Float,end:Float) {
        
        //从起点和终点开始,进行剪切.
        //剪切前将lesson中的合并音频移出到"transfer"
        let fileManger = FileManager.default
        
        let srcURL = FileManager.ddRecordURLWithName(audioDocURL!, name: "record0")
        
        let toURL = FileManager.ddRecordURLWithNameInTransfer("recordCombined")! //移动到中转站,等待处理,
        do {
            try fileManger.moveItem(at: srcURL!, to: toURL)
        }catch {
            print("error: \(error).")
        }
        //获取三段截取区间.
        let start1 = CMTimeMake(0, 1)//起点
        //这里获取毫秒级别时间点.CMTimeMake(1, 10); // 1/10 second = 0.1 second
        let start2 = CMTimeMake(Int64(start * 1000), 1000)//第二个点
        let start3 = CMTimeMake(Int64(end * 1000), 1000)//第三个点
        let assetAtTransfer = AVAsset(url:toURL)//获取中转站中的录音文件asset
        let end = assetAtTransfer.duration //终点
        
        let range1 = CMTimeRangeFromTimeToTime(start1, start2)
        let range2 = CMTimeRangeFromTimeToTime(start3, end)
        
        print("start:\(start2)  end:\(start3)")
        
        trimmBeginHandler?()
        
        
        //剪切掉选中的部分,剪切的部分是异步的,所以完成之后回到主线程更新UI.
        exportAssetAndDeleteIt(audioDocURL!, asset: assetAtTransfer, timeRange: range1, fileName: "record0.m4a")
        exportAssetAndDeleteIt(audioDocURL!, asset: assetAtTransfer, timeRange: range2, fileName: "record1.m4a")   
        
    }
    
    /**
     通过时间戳来剪切
     
     - parameter times: 时间戳中不包含音频起点和重点
     */
    func clipAudioByTimes(_ times:[Float]) {
        
        
        //从起点和终点开始,进行剪切.
        //剪切前将lesson中的合并音频移出到"transfer"
        let fileManger = FileManager.default
        
        let srcURL = FileManager.ddRecordURLWithName(audioDocURL!, name: "record0")
        
        let toURL = FileManager.ddRecordURLWithNameInTransfer("recordCombined")! //移动到中转站,等待处理,
        do {
            try fileManger.moveItem(at: srcURL!, to: toURL)
        }catch {
            print("error: \(error).")
        }
        
        
        //获取N段截取区间.
        var cmTimes =  [CMTime]()
        let startTime = CMTimeMake(0, 1)//起点
        cmTimes.append(startTime)
        for time in times {
            //这里获取毫秒级别时间点.CMTimeMake(1, 10); // 1/10 second = 0.1 second
            let middleCMTime = CMTimeMake(Int64(time * 1000), 1000)
            cmTimes.append(middleCMTime)
        }
        let assetAtTransfer = AVAsset(url:toURL)//获取中转站中的录音文件asset
        let endTime = assetAtTransfer.duration //终点
        cmTimes.append(endTime)
        
        //两两成组
        var doubleTimes = [[CMTime]]()
        for _ in 0..<cmTimes.count/2 {
            var arr = [CMTime]()
            
            arr.append(cmTimes.removeFirst())
            arr.append(cmTimes.removeFirst())
            
            doubleTimes.append(arr)
        
        }
        
        //制作range
        var ranges = [CMTimeRange]()
        for i in 0..<doubleTimes.count {
            
            let range = CMTimeRangeFromTimeToTime(doubleTimes[i][0], doubleTimes[i][1])
            ranges.append(range)
        }
        
        trimmBeginHandler?()
        
        self.totalTrimCount = ranges.count
        //循环切出需要的部分.剪切掉选中的部分,剪切的部分是异步的,所以完成之后回到主线程更新UI.
        for i in 0..<ranges.count {
            let name = "record\(i).m4a"
            exportAssetAndDeleteIt(audioDocURL!, asset: assetAtTransfer, timeRange: ranges[i], fileName:name )
            
        }
 
    }
    
    
    
    
    func exportAssetAndDeleteIt(_ savePathURL:URL,asset:AVAsset,timeRange:CMTimeRange,fileName:String){
        //建立剪切部分的保存路径.
        let trimmedSoundFileURL = savePathURL.appendingPathComponent(fileName)
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        
        let filemanager = FileManager.default
        if filemanager.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists")
        }
        
        //将波形图的录音数据放进裁决者
        let exporter = AVAssetExportSession(asset:asset, presetName: AVAssetExportPresetAppleM4A)
        exporter!.outputFileType = AVFileTypeAppleM4A
        exporter!.outputURL = trimmedSoundFileURL
        
        //设定裁决的区间.
        exporter!.timeRange = timeRange
        
        
        // do it
        exporter!.exportAsynchronously(completionHandler: { [weak self] in
            switch exporter!.status {
            case  AVAssetExportSessionStatus.failed:
                print("export failed \(exporter!.error)")
            case AVAssetExportSessionStatus.cancelled:
                print("export cancelled \(exporter!.error)")
            default:
                print("export \(fileName) complete")
                //如果裁决次数为两次(trimCount)有时是多次,说明,两次分割都已经完成.那么,合并音频.
                self?.trimmedCount += 1
                if (self?.trimmedCount == self!.totalTrimCount ){
                    
                    //计数要清零.
                    self?.trimmedCount = 0
                    self?.trimCompeted()
                }
            }
            })
    }
    
    
    func trimCompeted() {
        
        //先删除中转站中的音频.裁剪剩下的音频已经又回到原来的路径.
        FileManager.cleanTransferFiles()
        
        //通知处理源头.裁切完成.
        trimmCompleteHandler?()
    }
    
    
    func combinedAudiosifNeed() {
        //合并之前录的音频,之后设置波形图和滑块数据.方法调用在combineAudioFiles()里面.
        let recordCount = FileManager.recordCountInLessonIndex(audioDocURL!)//获取音频文件数量
        //如果只有一个文件,停止合并.
        if (recordCount <= 1){
            recordCombineCompleteHandler?()
            return
        }
        else {
            //有多个录音文件需要合并,收集这些文件的URL.教给裁决者.
            let toURL = FileManager.ddRecordURLWithNameInTransfer("recordCombined")!
            let fileManager = FileManager.default
            
            if let recordURLs = (try? fileManager.contentsOfDirectory(at: audioDocURL!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())){
                
                combineAudios(recordURLs: recordURLs, outputURL: toURL){
                    [weak self] in
                    //合并完成.删除原路径下的分散的录音.将中转站中的录音移到lessonindex目录下.
                    //成功之后,删除,旧的文件,
                    //同时将新的文件重新命名为"record0.m4a",回到原来的路径,统计Int归零
                    var FileRecordedNumber = 0
                    let newName = "record0"
                    kAudioFileName = "record\(FileRecordedNumber))"
                    
                    FileRecordedNumber += 1
                    
                    let lessonIndexURL = FileManager.ddRecordURLWithName(self!.audioDocURL!, name: newName)
                    
                    self!.deleteRecordFileCombinedAndRenameNewOne(recordURLs, fileRenamedURL: toURL, toURL: lessonIndexURL!){ [weak self] in
                        //删除,移动完成,回调,提示用户
                        
                        self?.recordCombineCompleteHandler?()

                    }
                }
                
            }
        }
        
    }
    
    
     /// 音频合并完成.
    var recordCombineCompleteHandler:( () -> () )?
    
     /// 音频裁切完成.
    var trimmCompleteHandler:( () -> () )?
    
     /// 音频裁切开始.
    var trimmBeginHandler:( () -> () )?
    
   
    
}
