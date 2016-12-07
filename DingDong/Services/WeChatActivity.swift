//
//  WeChatActivity.swift
//  Yep
//
//  Created by nixzhu on 15/9/12.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import MonkeyKing

final class WeChatActivity: AnyActivity {

    enum `Type` {

        case Session
        case Timeline

        var type: String {
            switch self {
            case .Session:
                return DDConfig.ChinaSocialNetwork.WeChat.sessionType
            case .Timeline:
                return DDConfig.ChinaSocialNetwork.WeChat.timelineType
            }
        }

        var title: String {
            switch self {
            case .Session:
                return DDConfig.ChinaSocialNetwork.WeChat.sessionTitle
            case .Timeline:
                return DDConfig.ChinaSocialNetwork.WeChat.timelineTitle
            }
        }

        var image: UIImage {
            switch self {
            case .Session:
                return DDConfig.ChinaSocialNetwork.WeChat.sessionImage
            case .Timeline:
                return DDConfig.ChinaSocialNetwork.WeChat.timelineImage
            }
        }
    }

    init(type: Type, message: MonkeyKing.Message, completionHandler: @escaping MonkeyKing.DeliverCompletionHandler) {

        MonkeyKing.registerAccount(.weChat(appID: DDConfig.ChinaSocialNetwork.WeChat.appID, appKey: DDConfig.ChinaSocialNetwork.WeChat.appKey))

        super.init(
            type: UIActivityType(rawValue: type.type),
            title: type.title,
            image: type.image,
            message: message,
            completionHandler: completionHandler
        )
    }
}

