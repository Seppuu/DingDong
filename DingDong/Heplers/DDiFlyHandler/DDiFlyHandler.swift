////
////  DDiFlyHandler.swift
////  DingDong
////
////  Created by Seppuu on 16/3/29.
////  Copyright © 2016年 seppuu. All rights reserved.
////
//
//import Foundation
//
//class DDiFlyHandler: NSObject,IFlySpeechRecognizerDelegate {
//    
//    
//    var pcmFilePath = "" //语音用音频文件
//    var iFlySpeechRecognizer : IFlySpeechRecognizer? //不带界面的识别对象
//    // var iflyRecognizerView : IFlyRecognizerView?     //带界面的识别对象
//    var uploader: IFlyDataUploader?                  //数据上传对象
//    var result = ""
//    var textForSubTitle = ""
//    var isCanceled = false
//    
//    
//    override init() {
//        super.init()
//        
//        setSpeech()
//        
//    }
//
//    func setSpeech() {
//        
//        uploader = IFlyDataUploader()
//        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
//        let cachePath = paths[0]
//        pcmFilePath = cachePath.stringByAppendingString("asr.pcm")
//
//        initRecognizer()
//    }
//    
//    /**
//     设置识别参数
//     */
//    func initRecognizer() {
//        
//        //1.创建语音听写对象
//        iFlySpeechRecognizer = IFlySpeechRecognizer.sharedInstance() as? IFlySpeechRecognizer //设置听写模式
//        iFlySpeechRecognizer?.setParameter("", forKey:IFlySpeechConstant.PARAMS())
//        
//        //2.设置听写参数
//        iFlySpeechRecognizer?.setParameter("iat", forKey:IFlySpeechConstant.IFLY_DOMAIN())
//        
//        //asr_audio_path是录音文件名,设置value为nil或者为空取消保存,默认保存目录在 Library/cache下。
//        iFlySpeechRecognizer?.setParameter(nil, forKey: IFlySpeechConstant.ASR_AUDIO_PATH())
//        
//        //3.启动识别服务
//        //iFlySpeechRecognizer?.startListening()
//        
//        
//        
//    }
//    
//    func start() {
//        
////        isCanceled = false
////        
////        if((iFlySpeechRecognizer == nil)) {
////            self.initRecognizer()
////        }
////        iFlySpeechRecognizer?.cancel()
////        
////        //设置音频来源为麦克风
////        iFlySpeechRecognizer?.setParameter(IFLY_AUDIO_SOURCE_MIC, forKey: "audio_source")
////        
////        //设置听写结果格式为json
////        iFlySpeechRecognizer?.setParameter("json", forKey: IFlySpeechConstant.RESULT_TYPE())
////        
////        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
////        iFlySpeechRecognizer?.setParameter(nil, forKey: IFlySpeechConstant.ASR_AUDIO_PATH())
////        
////        iFlySpeechRecognizer?.delegate = self
////        
////        let ret = iFlySpeechRecognizer?.startListening()
////        
////        
////        if ((ret) != nil) {
////            
////        }else{
////            print("启动识别服务失败，请稍后重试")//可能是上次请求未结束，暂不支持多路并发
////        }
//        
//        
//    }
//    
//    
//    func stop() {
//        
//        iFlySpeechRecognizer?.stopListening()
//    }
//    
//    func cancel() {
//        
//        iFlySpeechRecognizer?.cancel()
//    }
//    
//    
//    /**
//     识别结果返回代理
//     
//     - parameter results: results识别结果
//     - parameter isLast:  isLast 表示是否最后一次结果
//     */
//    func onResults(results: [AnyObject]!, isLast: Bool) {
//        
//        var resultString = ""
//        let dic:NSDictionary = results[0] as! NSDictionary
//        let keys = dic.allKeys as! [String]
//        for  key in keys {
//            
//            resultString += key
//            
//        }
//        
//        self.result =  resultString
//        let resultFromJson = ISRDataHelper.stringFromJson(result)
//        
//        self.textForSubTitle += resultFromJson
//        
//        
//        if (isLast){
//            print("听写结果:\(self.textForSubTitle)")
//        }
//        
//        //        print("_result=\(self.result)")
//        //        //print("resultFromJson=\(resultFromJson)")
//        //        print("isLast=\(isLast),textViewText=\(textViewText)")
//        
//    }
//    
//    
//    /**
//     识别会话结束返回代理
//     
//     - parameter error: 错误码,error.errorCode=0表示正常结束,非0表示发生错误。
//     */
//    func onError(error: IFlySpeechError!) {
//        
//    }
//    
//    /**
//     停止录音回调
//     */
//    func onEndOfSpeech() {
//        
//    }
//    
//    /**
//     开始识别回调
//     */
//    func onBeginOfSpeech() {
//        
//    }
//    
//    /**
//     音量回调函数
//     
//     - parameter volume:  0-30
//     */
//    func onVolumeChanged(volume: Int32) {
//        
//        
//    }
//    
//    
//    
//    
//    
//}